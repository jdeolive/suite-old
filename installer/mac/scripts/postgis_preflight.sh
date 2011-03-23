#!/bin/bash

# This script creates special postgres user and group to run the 
# server under, and ensures that the shared memory parameters are
# set to the minimums required by PostgreSQL.

# Desired memory values
pg_shmall=65536    # 64kb
pg_shmmax=67108864 # 64Mb

# Current values
shmall=`sysctl -n kern.sysv.shmall`
shmmax=`sysctl -n kern.sysv.shmmax`

function dosysctl {
  if [ "$2" -lt "$3" ]
  then
    if [ -f /private/etc/sysctl.conf ]
    then
      cat /private/etc/sysctl.conf | grep -v $1 > /tmp/sysctl
      mv -f /tmp/sysctl /private/etc/sysctl.conf
    fi
    echo "$1=$3" >> /private/etc/sysctl.conf
    /usr/sbin/sysctl -w $1=$3 > /dev/null
  fi
}

dosysctl kern.sysv.shmall $shmall $pg_shmall
dosysctl kern.sysv.shmmax $shmmax $pg_shmmax

# Add paths
if [ -d /private/etc/paths.d ]
then
  echo "/opt/opengeo/pgsql/8.4/bin" > /private/etc/paths.d/opengeo-pgsql
fi
if [ -d /private/etc/manpaths.d ]
then
  echo "/opt/opengeo/pgsql/8.4/share/man" > /private/etc/manpaths.d/opengeo-pgsql
fi

exit 0
