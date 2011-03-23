#!/bin/bash

. functions

check_root

rpm -ev proj-devel
rpm -ev proj

pushd build/proj
ls | grep "proj-[0-9]" | xargs rpm -ivh
rpm -ivh proj-devel-*

rpm -qa | grep proj
