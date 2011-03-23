#!/bin/bash

# This script downloads the binary artefacts from other build processes and
# assembles them in the ./binaries/root directory where they are packaged into
# a self-extracting bin file with makeself.sh

MYHOME=`pwd`

SUITE_DIR="/opt/suite"
PGSQL_DIR="/opt/pgsql"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <arch> [artifact-id]"
  exit 1
fi

if [ $# -lt 2 ]; then
  id=latest
else
  id=$2
fi

jre_version=1.6.0.20
arch=$1

dashboard_url=http://suite.opengeo.org/builds/dashboard-${id}-lin${arch}.zip
suite_url=http://suite.opengeo.org/builds/opengeosuite-${id}-bin.tar.gz
ext_url=http://suite.opengeo.org/builds/opengeosuite-${id}-ext.tar.gz
jre_url=http://data.opengeo.org/suite/suite-jre-${jre_version}-lin${arch}.tgz
pgsql_url=http://suite.opengeo.org/lin${arch}builds/pgsql-postgis-linux${arch}.tar.gz
# http://suite.opengeo.org/lin32builds/
# http://suite.opengeo.org/lin64builds/

export PATH=$PATH:/usr/local/bin

#
# Utility function to check return values on commands
#
function checkrv {
  if [ $1 -gt 0 ]; then
    echo "$2 failed with return value $1"
    exit 1
  else
    echo "$2 succeeded return value $1"
  fi
}

#
# Utility function to download only files that have changed since
# last download.
#
function getfile {

  local url
  local file
  local dodownload

  url=$1
  file=$2
  dodownload=yes


  url_tag=`curl -f -s -I $url | grep ETag | tr -d \" | cut -f2 -d' ' | tr -d " "`
  checkrv $? "ETag check at $url"

  if [ -f "${file}" ] && [ "x$url_tag" != "x" ] && [ -f "${file}.etag" ]; then
    file_tag=`cat "${file}.etag"`
    if [ "x$url_tag" = "x$file_tag" ]; then
      echo "$file is already up to date"
      dodownload=no
    fi
  fi

  if [ $dodownload = "yes" ]; then
    echo "downloading fresh copy of $file"
    curl -f $url > $file
    checkrv $? "Download from $url"
    echo $url_tag > "${file}.etag"
  fi

}


#
# Check for expected subdirectories
# Clean up and prepare
#
if [ ! -d binaries ]; then
  mkdir binaries
fi
if [ -d binaries/root ]; then
  rm -rf binaries/root
fi
mkdir binaries/root

#
# Retrieve the suite assembly
#
getfile $suite_url binaries/suite.tgz
if [ -d binaries/suite ]; then
  rm -rf binaries/suite
fi
mkdir binaries/suite
tar xfz binaries/suite.tgz -C binaries/suite
checkrv $? "GeoServer untar"


#
# Repackage the Suite component
#
cd $MYHOME/binaries/suite
NAME=`ls`
mv ${NAME} suite
if [ -f suite/version.ini ]; then
  cat suite/version.ini
  svn_revision=`grep svn_revision suite/version.ini | cut -f2 -d= | tr -d ' '`
  suite_version=`grep suite_version suite/version.ini | cut -f2 -d= | tr -d ' '`
  echo $suite_version > ../root/VERSION
fi

if [ -d $MYHOME/binaries/build ]; then
	rm -rf $MYHOME/binaries/build
fi

mkdir $MYHOME/binaries/build
cp -fr $MYHOME/config/suite/* $MYHOME/binaries/build
cd $MYHOME/binaries/build

sed -i -e "s#@SUITE_DIR@#$SUITE_DIR#g" \
       -e "s#@SUITE_EXE@#$SUITE_DIR/opengeo-suite#g" \
       -e "s#@GEOSERVER_DATA_DIR@#$SUITE_DIR/data_dir#g" \
       -e "s#@PGADMIN_PATH@#$PGSQL_DIR/scripts/pgadmin3#g" \
       -e "s#@PGSHAPELOADER_PATH@#$PGSQL_DIR/scripts/pgshapeloader#g" \
       -e "s#@PGSQL_PORT@#54321#g" "`find "$MYHOME/binaries/suite" -type f -name config.ini`"

debuild -uc -us
checkrv $? "Suite build"
cd $MYHOME
rm -rf $MYHOME/binaries/build $MYHOME/binaries/suite

#
# Retrieve the Linux JRE
#
mkdir -p $MYHOME/binaries/suite
getfile $jre_url binaries/jre.tgz
tar xfz binaries/jre.tgz -C $MYHOME/binaries/suite
checkrv $? "JRE untar"

if [ -d $MYHOME/binaries/build ]; then
        rm -rf $MYHOME/binaries/build
fi
mkdir $MYHOME/binaries/build

cp -fr $MYHOME/config/jre/* $MYHOME/binaries/build
cd $MYHOME/binaries/build
debuild -uc -us
checkrv $? "JRE build"
cd $MYHOME
rm -rf $MYHOME/binaries/build $MYHOME/binaries/suite


#
# Retrieve the PostgreSQL build
#
PGSQLFILE=`basename $pgsql_url`
getfile $pgsql_url binaries/$PGSQLFILE
tar xfz binaries/$PGSQLFILE -C binaries
checkrv $? "PgSQL untar"

# Copy branding and settings
cp -vf ../common/postgis/settings.ini \
       binaries/pgsql/share/pgadmin3/
cp -vf ../common/postgis/branding.ini \
       binaries/pgsql/share/pgadmin3/branding/
cp -vf ../common/postgis/pgadmin_splash.gif \
       binaries/pgsql/share/pgadmin3/branding
cat ../common/postgis/plugins.ini \
    >> binaries/pgsql/share/pgadmin3/plugins.ini

# Copy scripts
mkdir binaries/pgsql/scripts
cp -v scripts/* binaries/pgsql/scripts
checkrv $? "PgSQL script copy"
chmod 755 binaries/pgsql/scripts/*

if [ -d $MYHOME/binaries/build ]; then
        rm -rf $MYHOME/binaries/build
fi
mkdir $MYHOME/binaries/build

cp -fr $MYHOME/config/postgis/* $MYHOME/binaries/build
cd $MYHOME/binaries/build
debuild -uc -us
checkrv $? "PostGIS build"
cd $MYHOME
rm -rf $MYHOME/binaries/build $MYHOME/binaries/pgsql


#
# Retrieve and build the Dashboard
#
getfile $dashboard_url binaries/dashboard.zip
if [ -d "./binaries/root/OpenGeo Dashboard" ]; then
 rm -rf "./binaries/root/OpenGeo Dashboard"
fi
unzip -q -o binaries/dashboard.zip -d binaries/suite
checkrv $? "Dashboard unzip"
touch "./binaries/suite/OpenGeo Dashboard/.installed"
pushd binaries/suite
NAME=`ls`
tar cfz "../root/${NAME}.tar.gz" *
checkrv $? "Dashboard retar"
rm -rf *
popd

#
# Retrieve the GeoServer extensions package
#
EXTFILE=`basename $ext_url`
getfile $ext_url binaries/${EXTFILE}
cp binaries/${EXTFILE} binaries/root

#
# Copy in some useful files
#
cp ../common/license.txt binaries/root
cp ./install.sh binaries/root

#
# Build installer script
#
binfile=OpenGeoSuite.bin
if [ "x$svn_revision" != "x" ]; then
  binfile=OpenGeoSuite-r$svn_revision.bin
fi

#makeself-2.1.5/makeself.sh ./binaries/root $binfile "OpenGeo Suite" ./install.sh

