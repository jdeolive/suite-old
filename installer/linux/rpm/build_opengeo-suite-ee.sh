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
ANALYTICS=opengeosuite-ee-$BRANCH-$REV-analytics.zip
IMPORTER=opengeosuite-ee-$BRANCH-$REV-importer.zip
CFLOW=opengeosuite-$BRANCH-$REV-control-flow.zip

get_file $BUILDS/$REPO_PATH/$ANALYTICS yes
get_file $BUILDS/$REPO_PATH/$IMPORTER yes
get_file $BUILDS/$REPO_PATH/$CFLOW yes

# clean out old files
clean_src

# unpack
mkdir $PKG_SOURCE_DIR
unpack_jars $ANALYTICS
unpack_jars $IMPORTER
unpack_jars $CFLOW

# build
build_rpm

# publish
publish_rpm ee

