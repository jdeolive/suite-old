#!/bin/bash

. functions

build_info

# grab files
get_file http://download.osgeo.org/proj/proj-4.7.0.tar.gz
get_file http://download.osgeo.org/proj/proj-datumgrid-1.5.zip

# clean out old sources
pushd proj
ls | grep -v debian | xargs rm -rf
popd

# unpack sources
rm -rf proj-4.7.0
tar xzvf files/proj-4.7.0.tar.gz
mv proj-4.7.0/* proj
checkrc $? "unpacking proj sources"
rmdir proj-4.7.0

unzip files/proj-datumgrid-1.5.zip -d proj/nad 
checkrc $? "unpacking datum files"

# build
build_deb proj

# publish
publish_deb proj
