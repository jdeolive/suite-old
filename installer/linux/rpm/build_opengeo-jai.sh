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

# clean
clean_src

# unpack sources
unzip -o files/jai-1_1_3-lib-linux-amd64-jdk.bin -d ${PKG_SOURCE_DIR}
#checkrc $? "unpacking jai amd64"
unzip -o files/jai_imageio-1_1-lib-linux-amd64-jdk.bin -d ${PKG_SOURCE_DIR}
#checkrc $? "unpacking jai imageio amd64"
unzip -o files/jai-1_1_3-lib-linux-i586-jdk.bin -d ${PKG_SOURCE_DIR}
#checkrc $? "unpacking jai i586"
unzip -o files/jai_imageio-1_1-lib-linux-i586-jdk.bin -d ${PKG_SOURCE_DIR}
#checkrc $? "unpacking jai imageio i586"

# build 
build_rpm

# publish
publish_rpm

