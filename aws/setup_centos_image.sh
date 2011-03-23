#!/bin/bash

. functions

if [ -z $2 ]; then
  echo "Usage: $0 ARCH IMAGE_SIZE"
  exit 1
fi

ARCH=$1
IMAGE_SIZE=$2

# add the opengeo repo
pushd /etc/yum.repos.d > /dev/null
wget http://yum.opengeo.org/centos/5/x86_64/OpenGeo.repo
check_rc $? "wget OpenGeo.repo"
popd > /dev/null

echo N | yum update
check_rc $? "yum update"

# install the sun jdk
yum -y install java-1.6.0-sun
check_rc $? "yum install java-1.6.0-sun"
ln -sf /usr/lib/jvm/java-1.6.0-sun-* /usr/lib/jvm/java-1.6.0-sun

# install the suite
yum -y install opengeo-suite
check_rc $? "yum install opengeo-suite" 

# ensure the sun jdk is used
sed -i 's#\(JAVA_HOME=\).*#\1"/usr/lib/jvm/java-1.6.0-sun/jre"#g' /etc/sysconfig/tomcat5

# tweak memory settings based on instance size
if [ $IMAGE_SIZE == "m1.large" ]; then
  sudo sed -i 's/\(JAVA_OPTS=.*\)Xms[0-9]\+[[:alpha:]]/\1Xms1024m/g' /etc/sysconfig/tomcat5
  sudo sed -i 's/\(JAVA_OPTS=.*\)Xmx[0-9]\+[[:alpha:]]/\1Xmx2048m/g' /etc/sysconfig/tomcat5
  /etc/init.d/tomcat5 restart
fi
