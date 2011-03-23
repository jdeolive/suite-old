#!/bin/bash

gs10app1="/Applications/OpenGeo Suite.app/"
gs10app2="/Applications/OpenGeo Dashboard.app/"
gs10del=1

gs10data="/Applications/OpenGeo Suite.app/Contents/Resources/Java/data_dir/"
gs15data="/opt/opengeo/suite/data_dir/"

gssave=/tmp/opengeo_data_dir.sav

#
# Remove any existing package
#
if [ -f "$gssave" ]
then 
  rm "$gssave"
fi

#
# Preferentially save more recent data directory
#
if [ -d "$gs15data" ]
then
  mv "$gs15data" "$gssave"
else
  # 
  # No 1.5 data? How about 1.0 data?
  # 
  if [ -d "$gs10data" ]
  then
    mv "$gs10data" "$gssave"
  fi
fi

#
# Optionally delete the original applications
#
if [ $gs10del ]
then
  rm -rf "$gs10app1"
  rm -rf "$gs10app2"
fi
