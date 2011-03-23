#!/bin/bash

function check_root () {
  if [ ! $( id -u ) -eq 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
  fi
}

function check_pg() {
  local status=$( echo "`service postgresql status`" | awk '{print $NF}' )
  if [ $status != "running..." ]; then
     service postgresql start
  fi

  status=$( echo "`service postgresql status`" | awk '{print $NF}' )
  if [ $status != "running..." ]; then
     echo "Postgresql is not running and could not be started. Unable to clean up postgis." 
     exit 1
  fi
}

check_root
old_status=$( echo "`service postgresql status`" | awk '{print $NF}' )
check_pg

PG_CONTRIB=/usr/share/pgsql/contrib

# turn off error trapping, one of these may fail
set +e

su - postgres -c "psql -d template_postgis -c \"update pg_database set datistemplate = false where datname = 'template_postgis'\""
su - postgres -c "dropdb medford"
su - postgres -c "dropdb template_postgis"
su - postgres -c "dropuser opengeo"
su - postgres -c "psql -f $PG_CONTRIB/uninstall_adminpack.sql -d postgres"

# turn it back on
set -e

if [ $old_status == "stopped" ]; then
  service postgresql stop
fi
