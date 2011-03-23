#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0 <destdir> <32|64>"
  exit 1
}

# Check for one argument
if [ $# -lt 2 ]; then
  usage
fi

workdir=`pwd`
destdir=$1
arch=$2

# Check that we have a mostly-built pgsql in the buildroot...
if [ -d ${buildroot}/pgsql ]; then
  rm -rf ${buildroot}/pgsql
fi
if [ -d ${buildroot}/pgsql_build ]; then
  cp -r ${buildroot}/pgsql_build ${buildroot}/pgsql
else
  echo "No pgsql_build directory!"
  exit 1
fi


# Copy in other files
for d in openssl geos proj pgadmin wxwidgets; do
  cp -r ${buildroot}/${d}/* ${buildroot}/pgsql
done

# Tar up the results 
binfile=pgsql-postgis-linux${arch}.tar.gz
pushd ${buildroot}
if [ -f ${workdir}/${binfile} ]; then
  rm -f ${workdir}/${binfile}
fi
tar cvfz ${workdir}/${binfile} pgsql
checkrv $? "Bundle tgz"
echo "Wrote ${binfile} to $workdir"
popd

# Move the results to the web directory
mv -fv ${workdir}/${binfile} ${destdir}
checkrv $? "Move tarball to web"

# Exit cleanly
exit 0
