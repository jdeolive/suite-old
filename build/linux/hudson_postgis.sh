#!/bin/bash

# Script directory
d=`dirname $0`

# Find script directory
pushd ${d}
p=`pwd`
popd

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0 <srcdir>"
  exit 1
}

# Check for one argument
if [ $# -lt 1 ]; then
  usage
fi

# Enter source directory
srcdir=$1
if [ ! -d $srcdir ]; then
  echo "Source directory '$srcdir' is missing."
  exit 1
else
  pushd $srcdir
fi

# Set up paths necessary to build
export PATH=${buildroot}/pgsql_build/bin:${buildroot}/geos/bin:${buildroot}/proj/bin:${PATH}
export LD_LIBRARY_PATH=${buildroot}/pgsql_build/lib:${buildroot}/proj/lib:${buildroot}/geos/lib

# Configure PostGIS
./autogen.sh
checkrv $? "PostGIS autogen"
./configure \
  --with-pgconfig=${buildroot}/pgsql_build/bin/pg_config \
  --with-geosconfig=${buildroot}/geos/bin/geos-config \
  --with-projdir=${buildroot}/proj \
  --with-xml2config=/usr/bin/xml2-config \
  --with-gui
checkrv $? "PostGIS configure"

# Build PostGIS
make clean && make && make install
checkrv $? "PostGIS build"

# Exit cleanly
exit 0
    
