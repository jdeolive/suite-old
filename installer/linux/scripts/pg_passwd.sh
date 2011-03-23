#!/bin/bash

if [ $# -lt 3 ]; then
  echo "Usage: $0 <user> <newpass> <pgpass>"
  exit 1
fi

# Load the common config functions and variables
d=`dirname $0`
source ${d}/pg_config.sh

bin=$(pg_check_bin)
if [ "$bin" != "good" ]; then
  echo "Cannot find PgSQL component: $bin"
  exit 1
fi

export PGPASSWORD=$3

"$pg_bin_dir/psql" \
  --username=postgres \
  --command="ALTER USER $1 PASSWORD '$2'"

# Return the error code
rv=$?

#echo "rv $rv"
exit $rv

