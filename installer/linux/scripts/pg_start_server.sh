#!/bin/bash

# Load the common config functions and variables
d=`dirname $0`
source ${d}/pg_config.sh

# Read the pg_port from the ini file if it exists
# and/or set the defaults
pg_check_ini

# Read the existence of a data directory
data=$(pg_check_data)

# There's a configured and ready directory?
if [ "$data" != "good" ]; then
  echo "PostGIS data directory missing: $pg_data_dir"
  exit 1
fi

# Check for PgSQL
bin=$(pg_check_bin)
if [ "$bin" != "good" ]; then
  echo "Cannot find PgSQL component: $bin"
  exit 1
fi

# We need to trick pgautovacuum into using the right superuser
export PGUSER=postgres
export LD_LIBRARY_PATH="$pg_lib_dir"

# Start the database
"$pg_bin_dir/pg_ctl" start \
  --pgdata "$pg_data_dir" \
  --log "$pg_log" \
  --silent \
  -w \
  -o "-p $pg_port -i"

# Catch any failure
rv=$?
if [ $rv -gt 0 ]; then
  echo "PgSQL pg_ctl failed with return value $rv"
  exit 1
fi

exit 0

