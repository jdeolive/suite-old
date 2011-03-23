#!/bin/bash

# Load the common config functions and variables
d=`dirname $0`
source ${d}/pg_config.sh

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

# Stop the database
"$pg_bin_dir/pg_ctl" stop \
  --pgdata "$pg_data_dir" \
  --log "$pg_log" \
  --silent \
  -m fast 

# Catch any failure
rv=$?
if [ $rv -gt 0 ]; then
  echo "PgSQL pg_ctl failed with return value $?"
  exit 1
fi

exit 0

