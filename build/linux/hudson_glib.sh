#!/bin/bash

# Script directory
d=`dirname $0`

# Load versions
source ${d}/hudson_config.sh

function usage() {
  echo "Usage: $0"
  exit 1
}

# Unzip the GLIB source 
getfile ${glib_url} ${buildroot}/${glib_file}
pushd ${buildroot}
if [ -d ${glib_dir} ]; then
  rm -rf ${glib_dir}
fi
tar xvfj ${glib_file}
checkrv $? "GLib untar"
popd

# Configure GLIB
pushd ${buildroot}/${glib_dir}
./configure \
  --prefix=${buildroot}/glib \
  --enable-threads
checkrv $? "GLib configure"
make
if [ -d ${buildroot}/glib ]; then
  rm -rf ${buildroot}/glib
fi
make install 
checkrv $? "GLib install"
popd

# Unzip the pkg-config 
getfile ${pkg_url} ${buildroot}/${pkg_file}
pushd ${buildroot}
if [ -d ${pkg_dir} ]; then
  rm -rf ${pkg_dir}
fi
tar xvfj ${pkg_file}
checkrv $? "pkg-config untar"
popd

# Configure pkg-config
pushd ${buildroot}/${pkg_dir}
export PATH=${buildroot}/glib/bin:${PATH}
export LD_LIBRARY_PATH=${buildroot}/glib/lib
./configure \
  --prefix=${buildroot}/glib 
checkrv $? "pkg-config configure"
make && make install 
checkrv $? "pkg-config install"
popd

# Unzip the GTK source 
getfile ${gtk_url} ${buildroot}/${gtk_file}
pushd ${buildroot}
if [ -d ${gtk_dir} ]; then
  rm -rf ${gtk_dir}
fi
tar xvfj ${gtk_file}
checkrv $? "GTK untar"
popd

# Configure GTK
pushd ${buildroot}/${gtk_dir}
./configure \
  --prefix=${buildroot}/glib 
checkrv $? "GTK configure"
make && make install 
checkrv $? "GTK install"
popd

exit 0
