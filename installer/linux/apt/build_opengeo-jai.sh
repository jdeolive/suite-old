#!/bin/bash

. functions

build_info

JAI_BUILDS=http://download.java.net/media/jai/builds/release
JAIIIO_BUILDS=http://download.java.net/media/jai-imageio/builds/release

# grab files
get_file $JAI_BUILDS/1_1_3/jai-1_1_3-lib-linux-amd64-jdk.bin
get_file $JAI_BUILDS/1_1_3/jai-1_1_3-lib-linux-i586-jdk.bin
get_file $JAIIIO_BUILDS/1.1/jai_imageio-1_1-lib-linux-amd64-jdk.bin
get_file $JAIIIO_BUILDS/1.1/jai_imageio-1_1-lib-linux-i586-jdk.bin

# clean out old sources
pushd opengeo-jai
ls | grep -v debian | xargs rm -rf
popd

# unpack sources
unzip -o files/jai-1_1_3-lib-linux-amd64-jdk.bin -d opengeo-jai
#checkrc $? "unpacking jai amd64"
unzip -o files/jai_imageio-1_1-lib-linux-amd64-jdk.bin -d opengeo-jai
#checkrc $? "unpacking jai imageio amd64"
unzip -o files/jai-1_1_3-lib-linux-i586-jdk.bin -d opengeo-jai
#checkrc $? "unpacking jai i586"
unzip -o files/jai_imageio-1_1-lib-linux-i586-jdk.bin -d opengeo-jai
#checkrc $? "unpacking jai imageio i586"

# build
build_deb opengeo-jai

# publish
publish_deb opengeo-jai
