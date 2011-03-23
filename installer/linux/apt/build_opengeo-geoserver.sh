#!/bin/bash

. functions

build_info

# grab files
GEOSERVER=opengeosuite-$BRANCH-$REV-war-geoserver.zip
get_file $BUILDS/$REPO_PATH/$GEOSERVER yes

# clean out old files
rm -rf opengeo-geoserver/geoserver.war

# unpack
mkdir tmp
unzip files/$GEOSERVER -d tmp
mv tmp/opengeosuite-*/geoserver.war opengeo-geoserver
checkrc $? "unpacking geoserver war"
rm -rf tmp

# build
build_deb opengeo-geoserver

# publish
publish_deb opengeo-geoserver
