#!/bin/bash

dashboard="/Applications/OpenGeo/OpenGeo Dashboard.app"
configini="$dashboard/Contents/Resources/config.ini"

if [ -d "$dashboard" ] 
then
  sed -i .bak 's/@SUITE_EXE@/\/opt\/opengeo\/suite\/opengeo-suite/g' "$configini"
  sed -i .bak 's/@SUITE_DIR@/\/opt\/opengeo\/suite/g' "$configini"
  sed -i .bak 's/@GEOSERVER_DATA_DIR@/\/opt\/opengeo\/suite\/data_dir/g' "$configini"
  sed -i .bak 's/@PGSQL_PORT@/54321/g' "$configini"
  sed -i .bak 's/@PGADMIN_PATH@/\/Applications\/OpenGeo\/pgAdmin3.app/g' "$configini"
  sed -i .bak 's/@PGSHAPELOADER_PATH@/\/Applications\/OpenGeo\/pgShapeLoader.app/g' "$configini"
fi

sleep 2

open "/Applications/OpenGeo/OpenGeo Dashboard.app"
exit 0
