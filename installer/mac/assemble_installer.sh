#!/bin/bash

# This script downloads the binary artefacts from other build processes and 
# assembles them in the ./binaries directory where they are packaged into
# .pkg files by Iceberg using the 'freeze' command and finally into the 
# suite .mpkg file with 'freeze' also.

if [ $# -lt 2 ]; then
  echo "Usage: $0 <repo_path> <revision> [profile]"
  exit 1
fi

REPO_PATH=$1
REVISION=$2
PROFILE=$3

id=$(echo $REPO_PATH|sed 's/\//-/g')
id=${id}-r${REVISION}
pro=$(echo $PROFILE|sed 's/\(.\{1,\}\)/\1-/g')

dashboard_version=1.0.0
pgsql_version=8.4

dashboard_url=http://suite.opengeo.org/builds/${REPO_PATH}/dashboard-${id}-osx.zip
suite_url=http://suite.opengeo.org/builds/${REPO_PATH}/opengeosuite-${pro}${id}-mac.zip
ext_url=http://suite.opengeo.org/builds/${REPO_PATH}/opengeosuite-${id}-ext.zip
pgsql_url=http://suite.opengeo.org/osxbuilds/postgis-osx.zip

export PATH=$PATH:/usr/local/bin

#
# Utility function to check return values on commands
#
function checkrv {
  if [ $1 -gt 0 ]; then
    echo "$2 failed with return value $1"
    exit 1
  else
    echo "$2 succeeded return value $1"
  fi
}

#
# Utility function to download only files that have changed since 
# last download.
#
function getfile {

  local url
  local file
  local dodownload

  url=$1
  file=$2
  dodownload=yes

  url_tag=`curl -f -s -I $url | grep ETag | tr -d \" | cut -f2 -d' '`
  checkrv $? "ETag check at $url"

  if [ -f "${file}" ] && [ -f "${file}.etag" ]; then
    file_tag=`cat "${file}.etag"`
    if [ "x$url_tag" = "x$file_tag" ]; then
      echo "$file is already up to date"
      dodownload=no
    fi
  fi

  if [ $dodownload = "yes" ]; then
    echo "downloading fresh copy of $file"
    curl -f $url > $file
    checkrv $? "Download from $url"
    echo $url_tag > "${file}.etag"
  fi

}


#
# Check for expected subdirectories
#
if [ ! -d binaries ]; then
  exit 1
fi
if [ ! -d build ]; then
  mkdir build
fi

#
# Build the uninstaller package
#
#xcodebuild -project "uninstaller/OpenGeo Suite Uninstaller.xcodeproj" -alltargets -configuration Release 
xcodebuild -project "uninstaller/OpenGeo Suite Uninstaller.xcodeproj" -alltargets 
checkrv $? "Uninstaller build"
if [ -d "binaries/OpenGeo Suite Uninstaller.app" ]; then
  rm -rvf "binaries/OpenGeo Suite Uninstaller.app"
fi
mv -v "uninstaller/build/Release/OpenGeo Suite Uninstaller.app" binaries
if [ -d "./build/Uninstaller.pkg" ]; then
   rm -rvf "./build/Uninstaller.pkg"
fi
freeze ./uninstaller.packproj
checkrv $? "Uninstaller packaging"

#
# Retrieve and build the Dashboard pkg
#
getfile $dashboard_url binaries/dashboard.zip
if [ -d "./binaries/OpenGeo Dashboard.app" ]; then
 rm -rf "./binaries/OpenGeo Dashboard.app"
fi
unzip -o binaries/dashboard.zip -d binaries
checkrv $? "Dashboard unzip"
if [ -d "./build/Dashboard.pkg" ]; then
   rm -rf "./build/Dashboard.pkg"
fi
freeze ./dashboard.packproj
checkrv $? "Dashboard packaging"

#
# Retrieve and build the Geoserver pkg
#
getfile $suite_url binaries/suite.zip
if [ -d binaries/suite ]; then
  rm -rf binaries/suite
fi
unzip -o binaries/suite.zip -d binaries/suite
checkrv $? "GeoServer unzip"
chmod 755 binaries/suite/opengeo-suite
cp -vf binaries/scripts/suite_uninstall.sh binaries/suite/
chmod 755 binaries/suite/suite_uninstall.sh
find binaries/suite/data_dir -type d -exec chmod 775 {} ';'
find binaries/suite/data_dir -type f -exec chmod 664 {} ';'

# Read the verison info from the ini file
ini=binaries/suite/version.ini
if [ -f $ini ]; then
  cat $ini
  svn_revision=`grep svn_revision $ini | cut -f2 -d= | tr -d ' '`
  suite_version=`grep suite_version $ini | cut -f2 -d= | tr -d ' '`
else
  svn_revision=r0000
  suite_version=1.9
fi

# Build the pkg
if [ -d "./build/GeoServer.pkg" ]; then
  find ./build/GeoServer.pkg -type f -exec chmod 644 {} ';'
  find ./build/GeoServer.pkg -type d -exec chmod 755 {} ';'
  rm -rf ./build/GeoServer.pkg
  checkrv $? "GeoServer.pkg tidy"
fi
freeze ./geoserver.packproj
checkrv $? "GeoServer packaging"

#
# Retrieve and build the PostGIS pkg
#
getfile $pgsql_url binaries/pgsql.zip
if [ -d binaries/pgsql ]; then
  rm -rf binaries/pgsql
fi
unzip -o binaries/pgsql.zip -d binaries/
checkrv $? "PostGIS unzip"
#
# Copy the startup scripts into pgsql
#
pgscriptdir=binaries/pgsql/scripts
mkdir ${pgscriptdir}
cp -vf binaries/scripts/*.sh ${pgscriptdir}
cp -vf binaries/scripts/postgis ${pgscriptdir}
rm -f ${pgscriptdir}/suite_uninstall.sh
chmod 755 ${pgscriptdir}/*
#
# Move the apps down one directory level
#
if [ -d binaries/pgShapeLoader.app ]; then
  rm -rf binaries/pgShapeLoader.app
fi
mv binaries/pgsql/pgShapeLoader.app/ binaries/
if [ -d binaries/stackbuilder.app ]; then
  rm -rf binaries/stackbuilder.app
fi
mv binaries/pgsql/stackbuilder.app/ binaries/
if [ -d binaries/pgAdmin3.app ]; then
  rm -rf binaries/pgAdmin3.app
fi
mv binaries/pgsql/pgAdmin3.app/ binaries/
#
# Set exec bits on all apps and copy in resources
#
chmod 755 binaries/pgShapeLoader.app/Contents/MacOS/pgShapeLoader*
chmod 755 binaries/pgAdmin3.app/Contents/MacOS/pgAdmin3
chmod 755 binaries/pgAdmin3.app/Contents/SharedSupport/pg_dump
chmod 755 binaries/pgAdmin3.app/Contents/SharedSupport/pg_dumpall
chmod 755 binaries/pgAdmin3.app/Contents/SharedSupport/pg_restore
chmod 755 binaries/pgAdmin3.app/Contents/SharedSupport/psql
cp -vf resources/PostGIS.icns \
       binaries/pgAdmin3.app/Contents/Resources/pgAdmin3.icns
cp -vf ../common/postgis/settings.ini \
       binaries/pgAdmin3.app/Contents/SharedSupport
cp -vf ../common/postgis/branding.ini \
       binaries/pgAdmin3.app/Contents/SharedSupport/branding
cp -vf ../common/postgis/pgadmin_splash.gif \
       binaries/pgAdmin3.app/Contents/SharedSupport/branding
cat ../common/postgis/plugins.ini \
 >> binaries/pgAdmin3.app/Contents/SharedSupport/plugins.ini
#
# Package up the results
#
if [ -d "./build/PostGIS Client.pkg/" ]; then
  rm -rf "./build/PostGIS Client.pkg/"
fi
freeze ./postgisclient.packproj
checkrv $? "PostGIS client packaging"
if [ -d "./build/PostGIS Server.pkg/" ]; then
  rm -rf "./build/PostGIS Server.pkg/"
fi
freeze ./postgisserver.packproj
checkrv $? "PostGIS server packaging"

#
# Build the GeoServer Extensions Package
#
getfile $ext_url binaries/ext.zip
if [ -d binaries/lib ]; then
  rm -rf binaries/lib
fi
unzip -j -o binaries/ext.zip -d binaries/lib
checkrv $? "Ext unzip"
if [ -d "./build/GeoServer Extensions.pkg" ]; then
  find "./build/GeoServer Extensions.pkg" -type f -exec chmod 664 {} ';'
  find "./build/GeoServer Extensions.pkg" -type d -exec chmod 775 {} ';'
  rm -rf "./build/GeoServer Extensions.pkg"
fi
freeze ./geoserverext.packproj
checkrv $? "Ext packaging"

# 
# Build the Suite package
#
if [ -d ./suitebuild ]; then
  rm -rf ./suitebuild
fi
cat ./resources/suite_welcome.html.in | sed "s/@VERSION@/$suite_version/" > ./resources/suite_welcome.html
cat ./suite.packproj | sed "s/@VERSION@/$suite_version/" > ./suite-ver.packproj
mkdir suitebuild
freeze ./suite-ver.packproj
checkrv $? "Suite packaging"

#
# Build the DMG volume
#
VOL="OpenGeo Suite $suite_version"
DMGTMP="tmp-${VOL}.dmg"
DMGFINAL="OpenGeoSuite-${pro}r$svn_revision.dmg"
BACKGROUND="dmg_background.tiff"
APP="OpenGeo Suite.mpkg"

# DMG window dimensions
dmg_width=640
dmg_height=314
dmg_topleft_x=200
dmg_topleft_y=200
dmg_bottomright_x=`expr $dmg_topleft_x + $dmg_width`
dmg_bottomright_y=`expr $dmg_topleft_y + $dmg_height`

# Unmount existing mounts
if [ -d "/Volumes/${VOL}" ]; then
  umount "/Volumes/${VOL}"
fi

# Clean up intermediate steps
find . -name "*.dmg" -exec rm -f {} ';'

# Copy the README-mac.pdf file into the DMG root
README=README.pdf
cp -vf ./binaries/suite/docs/install/pdf/README-mac.pdf ./suitebuild/${README}

# Create the DMG
hdiutil create \
    -srcfolder suitebuild \
    -volname "${VOL}" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    "${DMGTMP}"
checkrv $? "Suite volume create"

# Mount the DMG
sleep 2
device=$(hdiutil attach -readwrite -noverify -noautoopen "${DMGTMP}" | egrep '^/dev/' | sed 1q | awk '{print $1}')
sleep 5

echo "DEVICE: ${device}"

# Copy the background image in
mkdir "/Volumes/${VOL}/.background"
checkrv $? "Suite make background dir"
cp -v resources/${BACKGROUND} "/Volumes/${VOL}/.background/${BACKGROUND}"
checkrv $? "Suite copy background img"

# Set the background image and icon location
echo '
   tell application "Finder"
     tell disk "'${VOL}'"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {'${dmg_topleft_x}', '${dmg_topleft_y}', '${dmg_bottomright_x}', '${dmg_bottomright_y}'}
           set theViewOptions to the icon view options of container window
           set arrangement of theViewOptions to not arranged
           set icon size of theViewOptions to 72
           set background picture of theViewOptions to file ".background:'${BACKGROUND}'"
           set position of item "'${APP}'" of container window to {325, 130}
           set position of item "'${README}'" of container window to {480, 130}
           close
           open
           update without registering applications
           delay 5
           eject
           delay 5
     end tell
   end tell
' | osascript
checkrv $? "Applescript dimension change"

# convert to compressed image, delete temp image
hdiutil convert "${DMGTMP}" -format UDZO -imagekey zlib-level=9 -o "${DMGFINAL}"
checkrv $? "Suite compressing"
if [ -f "${DMGTMP}" ]; then 
  rm -f "${DMGTMP}"
fi

exit 0
