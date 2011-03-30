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
get_svn $REPO_PATH data_dir data_dir

# clean out old files
rm -rf opengeo-suite-ee/*.jar
rm -rf opengeo-suite-ee/*.properties

# unpack jars
unpack_jars $ANALYTICS
unpack_jars $CFLOW

# copy over analytics files
cp svn/$REPO_PATH/data_dir/monitoring/* opengeo-suite-ee

# build
build_deb opengeo-suite-ee

# publish
publish_deb opengeo-suite-ee ee
