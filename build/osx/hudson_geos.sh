#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0 <srcdir> <destdir>"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

srcdir=$1

if [ "x$2" = "x" ]; then
  destdir=$webroot
else
  destdir=$2
fi
 
if [ ! -d $srcdir ]; then
  echo "Source directory is missing."
  exit 1
else 
  pushd $srcdir
fi

./autogen.sh
export CXX=g++-4.0 
export CC=gcc-4.0 
export CXXFLAGS="-O2 -arch i386 -arch ppc -mmacosx-version-min=10.4" 
export CFLAGS="-O2 -arch i386 -arch ppc -mmacosx-version-min=10.4" 
./configure --prefix=${buildroot}/geos --disable-dependency-tracking
make clean && make all
checkrv $? "GEOS build"

rm -rf ${buildroot}/geos
mkdir ${buildroot}/geos
make install
pushd ${buildroot}/geos
rm -f ${destdir}/geos-osx.zip
zip -r9 ${destdir}/geos-osx.zip *
checkrv $? "GEOS zip"
popd

popd

exit 0
    
