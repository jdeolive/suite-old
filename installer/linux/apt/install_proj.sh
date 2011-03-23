#!/bin/bash

. functions

check_root
remove_deb libproj-dev libproj0 proj-data
install_deb proj proj-data libproj0 libproj-dev
checkrc $? "installing proj libs"
