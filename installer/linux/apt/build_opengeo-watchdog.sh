#!/bin/bash

. functions

build_info

# grab files
get_svn $REPO_PATH watchdog watchdog

# clean out old files
rm -rf opengeo-watchdog/watchdog

svn export svn/$REPO_PATH/watchdog opengeo-watchdog/watchdog
checkrc $? "exporting watchdog scripts"

# build
build_deb opengeo-watchdog

# publish
publish_deb opengeo-watchdog
