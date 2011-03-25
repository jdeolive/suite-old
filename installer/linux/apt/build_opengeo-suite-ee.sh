#!/bin/bash

. functions

build_info

function unpack_jars() {
  mkdir tmp
  unzip files/$1 -d tmp
  mv tmp/opengeosuite-*/*.jar opengeo-suite-ee
  checkrc $? "unpacking jars"
  rm -rf tmp
}

# grab files
ANALYTICS=opengeosuite-ee-$BRANCH-$REV-analytics.zip
CFLOW=opengeosuite-$BRANCH-$REV-control-flow.zip

get_file $BUILDS/$REPO_PATH/$ANALYTICS yes
get_file $BUILDS/$REPO_PATH/$CFLOW yes

# clean out old files
rm -rf opengeo-suite-ee/*.jar

# unpack
unpack_jars $ANALYTICS
unpack_jars $CFLOW

# build
build_deb opengeo-suite-ee

# publish
publish_deb opengeo-suite-ee ee
