#!/bin/bash

. /usr/share/opengeo-postgis/functions

check_root
check_pg

HEADLESS=`check_headless $1`
if [ "$HEADLESS" != "true" ]; then
  printf "\nThis script installs PostGIS extensions specific to the OpenGeo Suite. This 
includes a template postgis database and a demo database containing some sample
tables.

Choosing 'Yes' will cause the adminpack extension to be installed as well. You 
may choose 'No' here but should note that this may cause some of the components
of the OpenGeo Suite to be disabled or function sub-optimally.

Would you like to configure PostGIS for the OpenGeo Suite? [Y|n]: " 

  read GO
  
  while [ 1 ]; do
    if [ -z "$GO" ]; then
      GO="y"
    fi
    GO=`echo $GO | tr '[A-Z]' '[a-z]'`
    if [ "$GO" == "y" ] || [ "$GO" == "yes" ] || [ "$GO" == "n" ] || [ "$GO" == "no" ] ; then
      break
    fi
  
    printf "\nSorry, did not understand '$GO'. Would you like to configure PostGIS for the OpenGeo Suite? [Y|n]: " 
    read GO
  done

  if [ "$GO" == "n" ] || [ "$GO" == "no" ]; then
    exit 0
  fi
fi

pg_setup_access $HEADLESS
if [ $? == 1 ]; then
    printf "\nNOTICE: Unable to configure PostGIS for the OpenGeo Suite. Please run the following script post install:

      sh $0

"
    exit 0
fi

# install postgresql admin pack
if [ $( pg_run "psql -w -c \"select count(*) from pg_proc where proname = 'pg_logdir_ls'\"" "no" | head -n 3 | tail -n 1 | sed 's/ *//g' ) == "0" ]; then
  echo "Installing postgresql admin pack"
  pg_run "psql -w -f $PG_CONTRIB/adminpack.sql -d postgres" 
  touch $OG_POSTGIS/adminpack
fi

pg_check_db template_postgis
if [ "$?" != "0" ]; then
  echo "Creating template_postgis database"
  pg_run "createdb -w template_postgis"
  pg_run "createlang -w plpgsql template_postgis"
  
  POSTGIS_SQL=""
  SPATIAL_REF_SYS_SQL=""
  if [ -d $PG_CONTRIB/postgis-1.5 ]; then
     POSTGIS_SQL=$PG_CONTRIB/postgis-1.5/postgis.sql
     SPATIAL_REF_SYS_SQL=$PG_CONTRIB/postgis-1.5/spatial_ref_sys.sql
  else 
     # look for file as installed by postgis 1.4
     if [ -e $PG_CONTRIB/postgis.sql ]; then
        POSTGIS_SQL=$PG_CONTRIB/postgis.sql
        SPATIAL_REF_SYS_SQL=$PG_CONTRIB/spatial_ref_sys.sql
     else
       # lookf or default on centos 5, which is postgis 1.3 style
       if [ -e $PG_CONTRIB/lwpostgis.sql ]; then
        POSTGIS_SQL=$PG_CONTRIB/lwpostgis.sql
        SPATIAL_REF_SYS_SQL=$PG_CONTRIB/spatial_ref_sys.sql
     fi
  fi

  pg_run "psql -w -d template_postgis -f $POSTGIS_SQL"
  pg_run "psql -w -d template_postgis -f $SPATIAL_REF_SYS_SQL"

  pg_run "psql -w -d template_postgis -c \"update pg_database set datistemplate = true where datname = 'template_postgis'\""
  touch $OG_POSTGIS/template_postgis
fi

# create an 'opengeo' user
echo "Creating opengeo user"
pg_run "createuser -w --createdb --superuser opengeo"
if [ "$?" == "0" ]; then
  # set the password
  pg_run "psql -w -d postgres -c \"alter user opengeo password 'opengeo'\""

  # update pg_hba.conf
  PG_HBA=/var/lib/pgsql/data/pg_hba.conf

  if [ ! -e $PG_HBA ]; then
    printf "Unable to locate pg_hba.conf. Please add the following lines to finalize opengeo user:
    
     local   all         opengeo                           md5
     host    all         opengeo     127.0.0.1/32          md5
"
  else
    if [ $( cat $PG_HBA | grep opengeo | wc -l ) == 0 ]; then
       echo "Updating pg_hba.conf"

       # back up old file
       cp $PG_HBA $PG_HBA.orig

       sed -i '/# TYPE/a local   all         opengeo                           md5'  $PG_HBA
       sed -i '/# TYPE/a host    all         opengeo     127.0.0.1/32          md5'  $PG_HBA
     
   fi
  fi

  touch $OG_POSTGIS/opengeo_user
fi

# create demo database
pg_check_db "medford"
if [ "$?" != "0" ]; then
  echo "Creating medford database"
  pg_run "createdb -w --owner=opengeo --template=template_postgis medford"
  pg_run "psql -w -f /usr/share/opengeo-postgis/medford_taxlots_schema.sql -d medford"
  pg_run "psql -w -f /usr/share/opengeo-postgis/medford_taxlots.sql -d medford" 
  touch $OG_POSTGIS/medford_db
fi

# create geoserver database
pg_check_db "geoserver"
if [ "$?" != "0" ]; then
  echo "Creating geoserver database"
  pg_run "createdb -w --owner=opengeo --template=template_postgis geoserver"
  touch $OG_POSTGIS/geoserver_db
fi

/etc/init.d/postgresql restart
