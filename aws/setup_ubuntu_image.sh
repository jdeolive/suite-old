#!/bin/bash

. functions

if [ -z $1 ]; then
  echo "Usage: $0 IMAGE_SIZE [BUILD_PROFILE]"
  exit 1
fi

IMAGE_SIZE=$1
BUILD_PROFILE=$2

# add the repos for sun jdk and opengeo
sudo bash -c "echo 'deb http://archive.canonical.com/ lucid partner' >> /etc/apt/sources.list"

wget -qO- http://apt.opengeo.org/gpg.key | sudo apt-key add - 
check_rc $? "apt-key add"

sudo bash -c "echo 'deb http://apt.opengeo.org/ubuntu lucid main' >> /etc/apt/sources.list"
check_rc $? "adding opengeo ubuntu repo"

# add the ee repo if ncessary
if [ "$BUILD_PROFILE" == "ee" ]; then
  sudo bash -c "echo 'deb http://aws:aws@apt-ee.opengeo.org/ubuntu lucid main' >> /etc/apt/sources.list"
fi

sudo apt-get update
check_rc $? "apt-get update"

# populate the debconf database so we can run headless
echo "postfix postfix/main_mailer_type select No configuration" | sudo debconf-set-selections
echo "sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true" | sudo debconf-set-selections 
echo "opengeo-geoserver opengeo_geoserver/proxyurl string " | sudo debconf-set-selections 
echo "opengeo-geoserver opengeo_geoserver/username string " | sudo debconf-set-selections 
echo "opengeo-geoserver opengeo_geoserver/password string " | sudo debconf-set-selections 
echo "opengeo-postgis opengeo_postgis/configure_postgis select true " | sudo debconf-set-selections 

check_rc $? "debconf-set-selections"

# install the sun jdk
sudo apt-get -y install sun-java6-jdk
check_rc $? "apt-get -y install sun-java6-jdk" 
update-java-alternatives -s java-6-sun

# install the suite
sudo apt-get -y install opengeo-suite
check_rc $? "apt-get -y install opengeo-suite" 

if [ "$BUILD_PROFILE" == "ee" ]; then
  sudo apt-get -y install opengeo-suite-ee
  check_rc $? "apt-get -y install opengeo-suite-ee" 
fi

# tweak memory settings based on instance size
if [ $IMAGE_SIZE == "m1.large" ] || [ $IMAGE_SIZE == "m1.xlarge" ] || [ $IMAGE_SIZE == "m2.xlarge" ]; then
  sudo sed -i 's/\(JAVA_OPTS=.*\)Xms[0-9]\+[[:alpha:]]/\1Xms1024m/g' /etc/default/tomcat6
  sudo sed -i 's/\(JAVA_OPTS=.*\)Xmx[0-9]\+[[:alpha:]]/\1Xmx2048m/g' /etc/default/tomcat6
  sudo service tomcat6 restart 
fi
