#!/bin/bash

. functions

build_info

VER=1.8.0
PGADMIN=pgadmin3-$VER

# grab files
get_file http://wwwmaster.postgresql.org/redir/198/h/pgadmin3/release/v$VER/src/$PGADMIN.tar.gz
cp files/$PGADMIN.tar.gz $RPM_SOURCE_DIR

get_svn $REPO_PATH installer/common/postgis pgadmin_postgis
cp svn/$REPO_PATH/pgadmin_postgis/* $RPM_BUILD_DIR

# build
build_rpm yes

# publish
publish_rpm

