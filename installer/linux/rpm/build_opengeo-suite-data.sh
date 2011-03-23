#!/bin/bash

. functions

build_info

# grab files
get_svn $REPO_PATH data_dir data_dir

# clean out old files
clean_src

# copy over files
mkdir ${PKG_SOURCE_DIR}
svn export svn/$REPO_PATH/data_dir ${PKG_SOURCE_DIR}/data_dir
checkrc $? "unpacking data directory"

# build
build_rpm

# publish
publish_rpm

