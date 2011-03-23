#!/bin/bash

# This script is run by the Hudson OSX installer job.  It is not meant 
# to be run outside Hudson's environment.
#
# This script runs the assemble_installer.sh script, copies the resulting
# binary to a more explicitly named file, creates latest links for trunk
# builds, and cleans up a bit.
#
# This process is bootstrapped in the Hudson jobs build script with the 
# following (REPO_PATH and REVISION are job parameters):
#
#     cd repo
#     if [ -d $REPO_PATH ]; then
#       cd $REPO_PATH
#       svn update -r $REVISION .
#     else
#       mkdir -p $REPO_PATH
#       cd $REPO_PATH
#       svn checkout -r $REVISION http://svn.opengeo.org/suite/${REPO_PATH}/installer .
#     fi
#     cd mac
#     bash hudson_installer_job.sh $REPO_PATH $REVISION $PROFILE

if [ $# -lt 2 ]; then
  echo "Usage: $0 <repo_path> <revision> [profile]"
  exit 1
fi

REPO_PATH=$1
REVISION=$2
PROFILE=$3

DIST_DIR=/Library/WebServer/Documents/suite/$REPO_PATH
if [ ! -e $DIST_DIR ]; then
  mkdir -p $DIST_DIR
fi


bash assemble_installer.sh $REPO_PATH $REVISION $PROFILE
if [ $? -gt 0 ]; then
  exit 1
fi

pro=$(echo $PROFILE|sed 's/\(.\{1,\}\)/-\1/g')
PATH_NAME=$(echo $REPO_PATH|sed 's/\//-/g')
CUR_FILE=${DIST_DIR}/OpenGeoSuite${pro}-${PATH_NAME}-r${REVISION}-b${BUILD_NUMBER}.dmg
BUILD_FILE=`ls OpenGeoSuite*.dmg`

# move to dist dir
if [ -f $BUILD_FILE ]; then
  mv $BUILD_FILE $CUR_FILE
  md5 $CUR_FILE > ${CUR_FILE}.md5
else
  exit 1
fi

# Remove old versions
find $DIST_DIR -maxdepth 1 -name 'OpenGeoSuite*.dmg' -mtime +6 -exec rm {} \;
find $DIST_DIR -maxdepth 1 -name 'OpenGeoSuite*.md5' -mtime +6 -exec rm {} \;

# Remove old symlinks
find $DIST_DIR -maxdepth 1 -type l -exec rm {} \;

# Symlink new version
if  [ $REPO_PATH = "trunk" ]; then
  ln -s $CUR_FILE $DIST_DIR/OpenGeoSuite${pro}-latest.dmg
fi
