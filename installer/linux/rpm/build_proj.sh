#!/bin/bash

. functions

build_info

# grab files
get_file http://download.osgeo.org/proj/proj-4.7.0.tar.gz
get_file http://download.osgeo.org/proj/proj-datumgrid-1.5.zip

cp files/proj-4.7.0.tar.gz $RPM_SOURCE_DIR
cp files/proj-datumgrid-1.5.zip $RPM_SOURCE_DIR

# build
build_rpm yes

# publish
publish_rpm

