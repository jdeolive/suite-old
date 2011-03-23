#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0"
  exit 1
}

# Unzip the PgAdmin source 
getfile ${pgadmin_url} ${buildroot}/${pgadmin_file}
pushd ${buildroot}
if [ -d ${pgadmin_dir} ]; then
  rm -rf ${pgadmin_dir}
fi
tar xvfz ${pgadmin_file}
checkrv $? "PgAdmin untar"
popd

export LD_LIBRARY_PATH=${buildroot}/pgsql_build/lib
export PATH=${buildroot}/pgsql_build/bin:${PATH}

pushd ${buildroot}/${pgadmin_dir}
./configure \
  --prefix=${buildroot}/pgadmin \
  --with-pgsql=${buildroot}/pgsql_build \
  --with-wx=${buildroot}/wxwidgets 
checkrv $? "PgAdmin configure"
make 
checkrv $? "PgAdmin build"
if [ -d ${buildroot}/pgadmin ]; then
  rm -rf ${buildroot}/pgadmin
fi
make install
checkrv $? "PgAdmin install"
popd

exit

pushd ${buildroot}/${pgsql_dir}/contrib
make && make install
checkrv $? "PgSQL contrib build"
popd

exit 0
    
