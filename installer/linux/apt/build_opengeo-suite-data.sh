#!/bin/bash

. functions

build_info

# grab files
get_svn $REPO_PATH data_dir data_dir

# clean out old files
rm -rf opengeo-suite-data/data_dir

svn export svn/$REPO_PATH/data_dir opengeo-suite-data/data_dir
checkrc $? "unpacking data directory"

# build
build_deb opengeo-suite-data

# publish
publish_deb opengeo-suite-data
