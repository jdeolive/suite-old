#!/bin/bash

# Load the common config functions and variables
d=`dirname $0`
source ${d}/pg_config.sh

data=$(pg_check_data)

# There's a configured and ready directory already!
if [ "$data" = "good" ]; then
  echo "PostGIS data directory already exists: $pg_data_dir"
  exit 1
fi

# There's a configured directory for an old version!
if [ "$data" = "wrong_version" ]; then
  echo "PostGIS data directory has wrong version ($pg_data_version): $pg_data_dir"
  exit 1
fi

bin=$(pg_check_bin)
if [ "$bin" != "good" ]; then
  echo "Cannot find PgSQL component: $bin"
  exit 1
fi

# Remove any vestigal directory that is already there
if [ -d "$pg_data_dir" ]; then
  rm -rf "$pg_data_dir"
  mkdir "$pg_data_dir"
fi

"$pg_bin_dir/initdb" \
  --pgdata="$pg_data_dir" \
  --username=postgres \
  --encoding=UTF8 >> "$pg_log"

# Catch any failure
rv=$?
if [ $rv -gt 0 ]; then
  echo "PgSQL initdb failed with return value $rv"
  exit 1
fi

exit 0

