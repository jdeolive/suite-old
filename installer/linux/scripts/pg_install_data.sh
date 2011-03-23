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

# Create the Medford Database
"$pg_bin_dir/createdb" --owner=$USER --template=template_postgis medford >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Create database failed with return value $rv"
  exit 1
fi

# Load the SQL files
for sql in $pg_data_load_dir/*; do
  "$pg_bin_dir/psql" -f "$sql" -d medford -U $USER >> "$pg_log"
done

exit 0

