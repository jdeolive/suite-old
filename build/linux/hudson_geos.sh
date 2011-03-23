#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0 <srcdir>"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

srcdir=$1

 
if [ ! -d $srcdir ]; then
  echo "Source directory '$srcdir' is missing."
  exit 1
else 
  pushd $srcdir
fi

./autogen.sh
./configure --prefix=${buildroot}/geos 
make clean && make 
checkrv $? "GEOS build"
if [ -d ${buildroot}/geos ]; then
  rm -rf ${buildroot}/geos
fi
make install
checkrv $? "GEOS install"

# Exit srcdir
popd

exit 0
    
