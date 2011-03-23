#!/bin/bash

. functions

check_root

rpm -ev geos-devel
rpm -ev geos

pushd build/geos
ls | grep "geos-[0-9]" | xargs rpm -ivh
rpm -ivh geos-devel-*

rpm -qa | grep geos
