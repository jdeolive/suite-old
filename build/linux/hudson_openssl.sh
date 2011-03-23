#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

# Build .so files with version information embedded as Debian likes
pushd ${d} && here=`pwd` && popd
patchfile=${here}/openssl-so-version.patch

function usage() {
  echo "Usage: $0"
  exit 1
}

# Unzip the OpenSSL source 
getfile ${openssl_url} ${buildroot}/${openssl_file}
pushd ${buildroot}
if [ -d ${openssl_dir} ]; then
  rm -rf ${openssl_dir}
fi
tar xfz ${openssl_file}
checkrv $? "OpenSSL untar"
popd

pushd ${buildroot}/${openssl_dir}
patch -p1 < ${patchfile}
./config \
  shared \
  --prefix=${buildroot}/openssl 
checkrv $? "OpenSSL configure"
make 
checkrv $? "OpenSSL build"
if [ -d ${buildroot}/openssl ]; then
  rm -rf ${buildroot}/openssl
fi
make install
popd

exit 0
    
