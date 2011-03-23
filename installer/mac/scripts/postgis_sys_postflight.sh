#!/bin/bash

# This script checks the existence of a data area, creates one if one
# does not exist, initializes it, starts the server, and installs
# the PostGIS template database.

postgres_ver=8.4
postgis_ver=1.5
postgres_dir=/opt/opengeo/pgsql/$postgres_ver
postgres_data=$postgres_dir/data
postgres_user=_opengeo
postgres_group=_opengeo
postgres_superuser=postgres

# Environment
export DYLD_LIBRARY_PATH=$postgres_dir/lib

# Utility variables
pgbin="$postgres_dir/bin"
pgman="$postgis_dir/share/man/"
pglog="$postgres_data/server.log"
pgis="$postgres_dir/share/postgresql/contrib/postgis-$postgis_ver"
su="su $postgres_user -c"
pgsu=$postgres_superuser

#
# Check for the data area
#
if [ ! -f "$postgres_data/PG_VERSION" ]
then
  if [ ! -d "$postgres_data" ]
  then
    mkdir "$postgres_data"
  else
    rm -rf "$postgres_data"
    mkdir "$postgres_data"
  fi
  initdb=1
else
  # Don't touch misversioned data area!
  pgver=`cat $postgres_data/PG_VERSION`
  if [ "$pgver" != "$postgres_ver" ]
  then
    exit 1
  fi
fi

#
# Standardize ownership
#
chown -R $postgres_user "$postgres_data"
chgrp -R $postgres_group "$postgres_data"

if [ $initdb ]
then
  $su "$pgbin/initdb --username=$pgsu --pgdata $postgres_data --encoding=UTF8 >> /dev/null"
fi

launchctl load /Library/LaunchDaemons/org.opengeo.postgis
launchctl start org.opengeo.postgis
sleep 5

if [ $initdb ]
then
  $su "$pgbin/createdb -U $pgsu template_postgis >> $pglog"
  $su "$pgbin/createlang -U $pgsu plpgsql template_postgis >> $pglog"
  $su "$pgbin/psql -U $pgsu -d template_postgis -f $pgis/postgis.sql >> $pglog"
  $su "$pgbin/psql -U $pgsu -d template_postgis -f $pgis/spatial_ref_sys.sql >> $pglog"
  $su "$pgbin/psql -U $pgsu -d template_postgis -c \"update pg_database set datistemplate=true where datname='template_postgis'\" >> $pglog"
fi

exit 0
