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

# Unsip the 
if [ ! -f ${buildroot}/${proj_nad} ]; then
  curl http://download.osgeo.org/proj/${proj_nad} > ${buildroot}/${proj_nad}
fi
pushd nad
unzip -o ${buildroot}/${proj_nad}
popd

./autogen.sh
export CXX=g++-4.0 
export CC=gcc-4.0 
export CXXFLAGS="-O2 -arch i386 -arch ppc -mmacosx-version-min=10.4"
export CFLAGS="-O2 -arch i386 -arch ppc -mmacosx-version-min=10.4"
./configure --prefix=${buildroot}/proj --disable-dependency-tracking
make clean all
checkrv $? "Proj build"

rm -rf ${buildroot}/proj
mkdir ${buildroot}/proj
make install

pushd ${buildroot}/proj
rm -f ${destdir}/proj-osx.zip
zip -r9 ${destdir}/proj-osx.zip *
checkrv $? "Proj zip"
popd

popd

exit 0
    
