#!/bin/bash

# This script is run by the Hudson Linux installer jobs.  It is not meant 
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
#     cd linux
#     bash hudson_installer_job.sh 32 $REPO_PATH $REVISION

if [ $# -lt 3 ]; then
  echo "Usage: $0 <arch> <repo_path> <revision>"
  exit 1
fi

ARCH_TYPE=$1
REPO_PATH=$2
REVISION=$3

rm *.bin

DIST_DIR=/var/www/suite/$REPO_PATH
if [ ! -e $DIST_DIR ]; then
  mkdir -p $DIST_DIR
fi

bash assemble_installer.sh $ARCH_TYPE $REPO_PATH $REVISION
if [ $? -gt 0 ]; then
  exit 1
fi

PATH_NAME=$(echo $REPO_PATH|sed 's/\//-/g')
CUR_FILE=${DIST_DIR}/OpenGeoSuite-${PATH_NAME}-r${REVISION}-b${BUILD_NUMBER}-x${ARCH_TYPE}.bin

BUILD_FILE=`ls OpenGeoSuite*.bin`

# Copy datestamped version
if [ -f $BUILD_FILE ]; then
  cp $BUILD_FILE $CUR_FILE
  if [ $? -gt 0 ]; then
    exit 1
  fi
else
  exit 1
fi

# Remove old versions
find $DIST_DIR -maxdepth 1 -name 'OpenGeoSuite*.bin' -mtime +4 -exec rm {} \;

# Symlink new version if from trunk
if  [ $REPO_PATH = "trunk" ]; then
  rm -f $DIST_DIR/OpenGeoSuite-latest.bin
  ln -s $CUR_FILE $DIST_DIR/OpenGeoSuite-latest.bin
fi
