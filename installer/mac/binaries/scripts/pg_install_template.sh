#!/bin/bash

d=`dirname $0`
source ${d}/pg_config.sh

# Read the pg port from the ini file or set 
# up the defaults
pg_check_ini

bin=$(pg_check_bin)
if [ "$bin" != "good" ]; then
  echo "Cannot find PgSQL component: $bin"
  exit 1
fi

pg_share=`"$pg_bin_dir/pg_config" --sharedir`
postgis="${pg_share}/contrib/postgis-${postgis_version}/postgis.sql"
if [ ! -f "$postgis" ]
then
  echo "PostGIS SQL file $postgis does not exist"
  exit 1
fi

srs="${pg_share}/contrib/postgis-${postgis_version}/spatial_ref_sys.sql"
if [ ! -f "$srs" ]
then
  echo "PostGIS spatial ref sys $srs does not exist"
  exit 1
fi

# We want to run all these as postgres superuser
export PGUSER=postgres
export PGPORT=$pg_port

"$pg_bin_dir/createdb" template_postgis >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Create database failed with return value $rv"
  exit 1
fi

"$pg_bin_dir/createlang" plpgsql template_postgis >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Create language failed with return value $rv"
  exit 1
fi

"$pg_bin_dir/psql" -d template_postgis -f "$postgis" >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Load postgis.sql failed with return value $rv"
  exit 1
fi

"$pg_bin_dir/psql" -d template_postgis -f "$srs" >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Load spatial_ref_sys.sql failed with return value $rv"
  exit 1
fi

"$pg_bin_dir/psql" -d template_postgis -c "update pg_database set datistemplate = true where datname = 'template_postgis'" >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Set template database flag failed with return value $rv"
  exit 1
fi

exit 0

