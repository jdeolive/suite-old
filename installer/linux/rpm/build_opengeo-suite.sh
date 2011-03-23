#!/bin/bash

. functions

build_info

WARS=opengeosuite-$BRANCH-$REV-war.zip

# grab files
get_file $BUILDS/$REPO_PATH/$WARS yes

# clean out old files
clean_src

# unpack
mkdir $PKG_SOURCE_DIR
mkdir tmp
unzip files/$WARS -d tmp
mv tmp/opengeosuite-*/*.war $PKG_SOURCE_DIR
checkrc $? "unpacking suite wars"
rm -rf tmp

# build
build_rpm

# publish
publish_rpm

