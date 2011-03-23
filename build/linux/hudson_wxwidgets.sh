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
getfile ${wx_url} ${buildroot}/${wx_file}
pushd ${buildroot}
if [ -d ${wx_dir} ]; then
  rm -rf ${wx_dir}
fi
tar xvfj ${wx_file}
checkrv $? "WxWidgets untar"
popd

pushd ${buildroot}/${wx_dir}
./configure \
  --prefix=${buildroot}/wxwidgets \
  --with-gtk \
  --enable-gtk2 \
  --enable-unicode
checkrv $? "WxWidgets configure"
make && pushd contrib && make && popd
checkrv $? "WxWidgets build"
if [ -d ${buildroot}/wxwidgets ]; then
  rm -rf ${buildroot}/wxwidgets
fi
make install && pushd contrib && make install && popd
checkrv $? "WxWidgets install"
popd

exit 0
    
