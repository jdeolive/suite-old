#!/bin/bash

. /usr/share/opengeo-postgis/functions

check_root
old_status=$( echo "`service postgresql status`" | awk '{print $NF}' )
check_pg

HEADLESS=`check_headless $1`
pg_setup_access $HEADLESS
if [ $? == 1 ]; then
    echo "NOTICE: Unable to remove OpenGeo Suite configuration for PostGIS. Please run this script ($0) manually and then uninstall again."
    exit 1
fi

# turn off error trapping, one of these may fail
set +e

if [ -f $OG_POSTGIS/medford_db ]; then
  echo "Dropping medford database"
  pg_run "dropdb -w medford"
  [ "$?" == "0" ] && rm $OG_POSTGIS/medford_db
fi

if [ -f $OG_POSTGIS/geoserver_db ]; then
  echo "Dropping geoserver database"
  pg_run "dropdb -w geoserver"
  [ "$?" == "0" ] && rm $OG_POSTGIS/geoserver_db
fi

if [ -f $OG_POSTGIS/opengeo_user ]; then
  echo "Dropping opengeo user"
  pg_run "dropuser -w opengeo"
  [ "$?" == "0" ] && rm $OG_POSTGIS/opengeo_user
fi

if [ -f $OG_POSTGIS/adminpack ]; then
  echo "Uninstalling admin pack"
  pg_run "psql -w -f $PG_CONTRIB/uninstall_adminpack.sql -d postgres"
  [ "$?" == "0" ] && rm $OG_POSTGIS/adminpack
fi

if [ -f $OG_POSTGIS/template_postgis ]; then
  echo "Dropping template_postgis database"
  pg_run "psql -w -d template_postgis -c \"update pg_database set datistemplate = false where datname = 'template_postgis'\""
  pg_run "dropdb -w template_postgis"
  [ "$?" == "0" ] && rm $OG_POSTGIS/template_postgis
fi

# turn it back on
set -e

if [ $old_status == "stopped" ]; then
  service postgresql stop
fi
