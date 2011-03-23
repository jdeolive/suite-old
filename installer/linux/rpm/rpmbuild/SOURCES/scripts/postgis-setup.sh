#!/bin/bash

PG_DATA=/var/lib/pgsql/data
PG_CONTRIB=/usr/share/pgsql/contrib

function check_root () {
  if [ ! $( id -u ) -eq 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
  fi
}

function check_pg() {
  local status=$( echo "`service postgresql status`" | awk '{print $NF}' )
  if [ $status != "running..." ]; then
     #attempt to start postgresql, first check if we need to init db
     if [ -e $PG_DATA ] && [ $( ls $PG_DATA | wc -l ) == 0 ]; then
        #init db
        service postgresql initdb
     fi

     service postgresql start
  fi

  status=$( echo "`service postgresql status`" | awk '{print $NF}' )
  if [ $status != "running..." ]; then
     echo "Could not start postgresql. Check above for the error and run /usr/share/opengeo-postgis/setup-postgis.sh once postgresql has been started."
     exit 1
  fi
}

check_root
check_pg

echo "Initializing template_postgis database"
su - postgres -c "createdb template_postgis"
su - postgres -c "createlang plpgsql template_postgis"
su - postgres -c "psql -d template_postgis -f $PG_CONTRIB/postgis-1.5/postgis.sql" > /dev/null
su - postgres -c "psql -d template_postgis -f $PG_CONTRIB/postgis-1.5/spatial_ref_sys.sql" > /dev/null
su - postgres -c "psql -d template_postgis -c \"update pg_database set datistemplate = true where datname = 'template_postgis'\""

# Adds PgAdmin utilities to the 'postgres' database
echo "Installing postgresql admin pack"
su - postgres -c "psql -f $PG_CONTRIB/adminpack.sql -d postgres" > /dev/null

# Create an 'opengeo' user
echo "Creating demo database"
su - postgres -c "createuser --createdb --superuser opengeo"

# Set the user password?
su - postgres -c "psql -d postgres -c \"alter user opengeo password 'opengeo'\""

# create demo database
su - postgres -c "createdb --owner=opengeo --template=template_postgis medford"
su - postgres -c "psql -f /usr/share/opengeo-postgis/medford_taxlots_schema.sql -d medford" > /dev/null
su - postgres -c "psql -f /usr/share/opengeo-postgis/medford_taxlots.sql -d medford" > /dev/null

echo "Updating pg_hba.conf"
PG_HBA=/var/lib/pgsql/data/pg_hba.conf

if [ ! -e $PG_HBA ]; then
  printf "Unable to locate PGDATA directory. Please add the following line to pg_hba.conf to finalize configuration:
    
     local   all         opengeo                           md5
     host    all         opengeo     127.0.0.1/32          md5
"
  exit 0
fi

# back up old file
cp $PG_HBA $PG_HBA.orig
if [ $( cat $PG_HBA | grep opengeo | wc -l ) == 0 ]; then
   sed -i '/# TYPE/a local   all         opengeo                           md5'  $PG_HBA
   sed -i '/# TYPE/a host    all         opengeo     127.0.0.1/32          md5'  $PG_HBA
     
   /etc/init.d/postgresql restart
fi
