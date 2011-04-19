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

# we have to configure postgis manually after install since without a 
# controlling terminal debconf won't continue
echo "opengeo-postgis opengeo_postgis/configure_postgis select false " | sudo debconf-set-selections 

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

# configure postgis

# first need to enable trust for postgres user
PG_HBA=/etc/postgresql/8.4/main/pg_hba.conf
sudo cp $PG_HBA $PG_HBA.bak 
sudo sed -i 's/ident/trust/g' $PG_HBA
sudo /etc/init.d/postgresql-8.4 restart

createdb -U postgres template_postgis
createlang -U postgres plpgsql template_postgis
psql -U postgres -d template_postgis -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql
psql -U postgres -d template_postgis -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql
psql -U postgres -d template_postgis -c "update pg_database set datistemplate = true where datname = 'template_postgis'"
createuser -U postgres --createdb --superuser opengeo

createdb -U postgres --owner=opengeo --template=template_postgis medford
createdb -U postgres --owner=opengeo --template=template_postgis medford
psql -U postgres -f /usr/share/opengeo-postgis/medford_taxlots_schema.sql -d medford > /dev/null
psql -U postgres -f /usr/share/opengeo-postgis/medford_taxlots.sql -d medford > /dev/null
createdb -U postgres --owner=opengeo --template=template_postgis geoserver

sudo mv $PG_HBA.bak $PG_HBA
sudo cp $PG_HBA $PG_HBA.orig
sudo sed -i '/# TYPE/a local   all         opengeo                           md5'  $PG_HBA

sudo chown postgres:postgres $PG_HBA
sudo /etc/init.d/postgresql-8.4 restart
