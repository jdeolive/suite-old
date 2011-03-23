#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0"
  exit 1
}

# Unzip the PostgreSQL source 
getfile ${pgsql_url} ${buildroot}/${pgsql_file}
pushd ${buildroot}
if [ -d ${pgsql_dir} ]; then
  rm -rf ${pgsql_dir}
fi
tar xvfj ${pgsql_file}
checkrv $? "PgSQL untar"
popd

export LD_LIBRARY_PATH=${buildroot}/openssl/lib
export PATH=${buildroot}/openssl/bin:${PATH}

pushd ${buildroot}/${pgsql_dir}
./configure \
  --prefix=${buildroot}/pgsql_build \
  --with-openssl \
  --with-ldap \
  --with-pam \
  --with-gssapi
checkrv $? "PgSQL configure"
make && 
pushd contrib &&
make && 
popd
checkrv $? "PgSQL build"
if [ -d ${buildroot}/pgsql_build ]; then
  rm -rf ${buildroot}/pgsql_build
fi
make install &&
pushd contrib &&
make install &&
popd 
checkrv $? "PgSQL install"
popd

exit 0
    
