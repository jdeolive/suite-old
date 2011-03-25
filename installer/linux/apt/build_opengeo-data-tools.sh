#!/bin/bash

. functions

build_info

function unpack_jars() {
  mkdir tmp
  unzip files/$1 -d tmp
  mv tmp/opengeosuite-*/*.jar opengeo-data-tools
  checkrc $? "unpacking jars"
  rm -rf tmp
}

# grab files
IMPORTER=opengeosuite-ee-$BRANCH-$REV-importer.zip

get_file $BUILDS/$REPO_PATH/$IMPORTER yes

# clean out old files
rm -rf opengeo-data-tools/*.jar

# unpack
unpack_jars $IMPORTER

# build
build_deb opengeo-data-tools

# publish
publish_deb opengeo-data-tools
