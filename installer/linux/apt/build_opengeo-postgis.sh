#!/bin/bash

. functions

build_info

# grab files
get_file http://data.opengeo.org/suite/medford_taxlots.zip

# clean out oldcripts
pushd opengeo-postgis
rm *.sql
popd

unzip files/medford_taxlots.zip -d opengeo-postgis
checkrc $? "unpacking medford scripts"

# build
build_deb opengeo-postgis

# publish
publish_deb opengeo-postgis
