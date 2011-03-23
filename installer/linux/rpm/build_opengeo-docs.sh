#!/bin/bash

. functions

echo $RPM_SOURCE_DIR

# grab files
DOCS=opengeosuite-$BRANCH-$REV-doc.zip
get_file $BUILDS/$REPO_PATH/$DOCS yes

# clean out old files
clean_src

# unpack
unzip files/$DOCS -d $PKG_SOURCE_DIR
checkrc $? "unpacking docs"

# build
build_rpm

# publish
publish_rpm

