#!/bin/bash

. functions

build_info

function unpack_jars() {
  mkdir tmp
  unzip files/$1 -d tmp
  mv tmp/opengeosuite-*/*.jar $PKG_SOURCE_DIR
  checkrc $? "unpacking jars"
  rm -rf tmp
}

# grab files
IMPORTER=opengeosuite-ee-$BRANCH-$REV-importer.zip

get_file $BUILDS/$REPO_PATH/$IMPORTER yes

# clean out old files
clean_src

# unpack
mkdir $PKG_SOURCE_DIR
unpack_jars $IMPORTER

# build
build_rpm

# publish
publish_rpm
