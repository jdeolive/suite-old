#!/bin/bash

. functions

check_root
remove_deb libgeos-dev libgeos-c1 libgeos-3.2.2
install_deb geos libgeos-3.2.2 libgeos-c1 libgeos-dev
checkrc $? "installing geos libs"
