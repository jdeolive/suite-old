#!/bin/bash

. functions

build_info

# grab files
get_file http://data.opengeo.org/suite/medford_taxlots.zip

# clean out old files 
clean_src 
 
# unpack 
unzip files/medford_taxlots -d $PKG_SOURCE_DIR 
checkrc $? "unpacking medford scripts"
 
# build 
build_rpm

# publish
publish_rpm

