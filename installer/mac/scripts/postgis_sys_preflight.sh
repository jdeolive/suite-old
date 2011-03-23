#!/bin/bash

# This script creates special postgres user and group to run the 
# server under, and ensures that the shared memory parameters are
# set to the minimums required by PostgreSQL.

# Account names and install locations
postgres_user=_opengeo
postgres_group=_opengeo
postgres_dir=/opt/opengeo/pgsql/8.4

# Desired memory values
pg_shmall=65536    # 64kb
pg_shmmax=67108864 # 64Mb



#
# Find the current group id if there is one.
#
group_id=`dscl . -list /Groups PrimaryGroupID | grep $postgres_group | sed 's/$postgres_group *\([0-9]\)/\1/'`

#
# Find the current user id if there is one.
#
user_id=`dscl . -list /Users UniqueID | grep $postgres_user | sed 's/$postgres_user *\([0-9]\)/\1/'`

#
# No existing group! Make one.
#
if [ "x$group_id" = "x" ]
then
  max_group_id=`dscl . -list /Groups PrimaryGroupID | sed 's/[A-Za-z0-9_]* *\([-0-9]\)/\1/' | sort -g | tail -n1`
  group_id=`expr $max_group_id + 1`

  dscl . -create /Groups/$postgres_group
  dscl . -create /Groups/$postgres_group PrimaryGroupID $group_id
fi

if [ "x$user_id" = "x" ]
then
  # No existing id, so create one 
  max_user_id=`dscl . -list /Users UniqueID | sed 's/[A-Za-z0-9_]* *\([-0-9]\)/\1/' | sort -g | tail -n1`
  user_id=`expr $max_user_id + 1`

  dscl . -create /Users/$postgres_user
  dscl . -create /Users/$postgres_user UniqueID $user_id
  dscl . -create /Users/$postgres_user PrimaryGroupID $group_id
  dscl . -create /Users/$postgres_user UserShell /bin/bash
  dscl . -create /Users/$postgres_user RealName "PostgreSQL Server"
  dscl . -create /Users/$postgres_user NFSHomeDirectory $postgres_dir/data
  dscl . -create /Users/$postgres_user Password \*

fi

# Update the shared memory values to support PostgreSQL!


# Current values
shmall=`sysctl -n kern.sysv.shmall`
shmmax=`sysctl -n kern.sysv.shmmax`

function dosysctl {
  if [ "$2" -lt "$3" ]
  then
    if [ -f /etc/sysctl.conf ]
    then
      cat /etc/sysctl.conf | grep -v $1 > /tmp/sysctl
      mv -f /tmp/sysctl /etc/sysctl.conf
    fi
    echo "$1=$3" >> /etc/sysctl.conf
    /usr/sbin/sysctl -w $1=$3 > /dev/null
  fi
}

dosysctl kern.sysv.shmall $shmall $pg_shmall
dosysctl kern.sysv.shmmax $shmmax $pg_shmmax

exit 0
