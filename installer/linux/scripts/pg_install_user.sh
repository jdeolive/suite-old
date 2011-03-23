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

# Update the postgres database to include the adminpack
"${pg_bin_dir}/psql" -f ${pg_share_dir}/contrib/adminpack.sql -d $PGUSER >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Adminpack install failed with return value $rv"
  exit 1
fi

# Create the User Database

# Create the User
"${pg_bin_dir}/createuser" --createdb --superuser $USER >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Create user failed with return value $rv"
  exit 1
fi

# Create the User Database
"${pg_bin_dir}/createdb" --owner=$USER --template=template_postgis $USER >> "$pg_log"
rv=$?
if [ $rv -gt 0 ]; then
  echo "Create user failed with return value $rv"
  exit 1
fi

exit 0

