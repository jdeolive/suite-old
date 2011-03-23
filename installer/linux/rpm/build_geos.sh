#!/bin/bash

. functions

build_info

GEOS=geos-3.2.2

# grab files
get_file http://download.osgeo.org/geos/$GEOS.tar.bz2

cp files/$GEOS.tar.bz2 $RPM_SOURCE_DIR

# build
build_rpm yes

# publish
publish_rpm
