#!/bin/bash

. functions

build_info

# grab files
GEOSERVER=opengeosuite-$BRANCH-$REV-war-geoserver.zip
get_file $BUILDS/$REPO_PATH/$GEOSERVER yes

# clean out old files
clean_src

# unpack
mkdir $PKG_SOURCE_DIR
mkdir tmp
unzip files/$GEOSERVER -d tmp
mv tmp/opengeosuite-*/geoserver.war $PKG_SOURCE_DIR
checkrc $? "unpacking geoserver war"
rm -rf tmp

# build
build_rpm

# publish
publish_rpm

