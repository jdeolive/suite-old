#!/bin/bash

d=`dirname $0`
source ${d}/pg_config.sh

# Read the pg port from the ini file or set
# up the defaults
pg_check_ini

# Make sure the executables are there
bin=$(pg_check_bin)
if [ "$bin" != "good" ]; then
  echo "Cannot find PgSQL component: $bin"
  exit 1
fi

# We want to run all these as postgres superuser
export PGUSER=postgres
export PGPORT=$pg_port

function create_db() {
  "$pg_bin_dir/createdb" --owner=$USER --template=template_postgis $1 >> "$pg_log"
  rv=$?
  if [ $rv -gt 0 ]; then
    echo "Create database failed with return value $rv"
    exit 1
  fi
}

# Create the Medford Database
create_db medford

# Create the GeoServer/Analytics database
create_db geoserver

function exec_sql() {
  "$pg_bin_dir/psql" -f "$1" -d medford -U $USER >> "$pg_log"
}

# Load the SQL files, preferring the _schema.sql files first
for sql in $pg_data_load_dir/*_schema.sql; do
  exec_sql "$sql"
done
for sql in `ls $pg_data_load_dir/* | grep -v "_schema.sql"`; do
  exec_sql "$sql"
done

exit 0

