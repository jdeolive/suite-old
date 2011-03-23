#!/bin/bash

export PATH=/bin:/usr/bin:${PATH}

# Check parameters
function usage() {
  echo "Usage: $0 <srcdir>"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

# Script directory
d=`dirname $0`

# Load version information and utility functions
source ${d}/hudson_config.sh

srcdir=$1

# Enter the source directory
if [ ! -d $srcdir ]; then
  exit 1
else
  pushd $srcdir
fi

# Fetch the NAD grids files
if [ ! -f ${buildroot}/${proj_nad} ]; then
  curl http://download.osgeo.org/proj/${proj_nad} > ${buildroot}/${proj_nad}
fi
pushd nad
# Unzip the NAD grids files
if [ ! -f ${buildroot}/${proj_nad} ]; then
  unzip -o ${buildroot}/${proj_nad}
  checkrv $? "Proj unzip NAD file"
fi
popd

# Patch a current build issue with MinGW and proj
#patch -p0 < ../suite-build/proj_mutex.patch
#checkrv $? "Proj mutex patch"

# Build proj
./configure --prefix=${buildroot}/proj 
make clean all
checkrv $? "Proj build"

# Clean the install directory
rm -rf ${buildroot}/proj
mkdir ${buildroot}/proj
make install

# Zip up the artifacts for posterity
pushd ${buildroot}/proj
rm -f ${webroot}/proj-win.zip
zip -r9 ${webroot}/proj-win.zip *
checkrv $? "Proj zip"
popd

# Leave the source directory
popd

# Done
exit 0

