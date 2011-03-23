#!/bin/bash

# This script downloads the binary artefacts from other build processes and 
# assembles them in the ./binaries/root directory where they are packaged into
# a self-extracting bin file with makeself.sh

if [ $# -lt 3 ]; then
  echo "Usage: $0 <arch> <repo_path> <revision>"
  exit 1
fi

arch=$1
REPO_PATH=$2
REVISION=$3

id=$(echo $REPO_PATH|sed 's/\//-/g')
id=${id}-r${REVISION}

jre_version=1.6.0.20

dashboard_url=http://suite.opengeo.org/builds/${REPO_PATH}/dashboard-${id}-lin${arch}.zip
suite_url=http://suite.opengeo.org/builds/${REPO_PATH}/opengeosuite-${id}-bin.tar.gz
ext_url=http://suite.opengeo.org/builds/${REPO_PATH}/opengeosuite-${id}-ext.tar.gz
jre_url=http://data.opengeo.org/suite/suite-jre-${jre_version}-lin${arch}.tgz
pgsql_url=http://linuxbuild${arch}.dev.opengeo.org/suite/pgsql-postgis-linux${arch}.tar.gz
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
# Retrieve the Linux JRE
#
getfile $jre_url binaries/jre.tgz
tar xfz binaries/jre.tgz -C binaries/suite/*
checkrv $? "JRE untar"

#
# Repackage the Suite component 
#
pushd binaries/suite
NAME=`ls`
mv ${NAME} suite
if [ -f suite/version.ini ]; then
  cat suite/version.ini
  svn_revision=`grep svn_revision suite/version.ini | cut -f2 -d= | tr -d ' '`
  suite_version=`grep suite_version suite/version.ini | cut -f2 -d= | tr -d ' '`
  echo $suite_version > ../root/VERSION
fi
tar cfz ../root/opengeosuite-bin.tar.gz suite
checkrv $? "Suite retar"
rm -rf *
popd

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
pushd binaries
tar cfz ./root/pgsql-postgis.tar.gz pgsql
checkrv $? "PgSQL retar"
rm -rf pgsql
popd

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

makeself-2.1.5/makeself.sh ./binaries/root $binfile "OpenGeo Suite" ./install.sh

exit

