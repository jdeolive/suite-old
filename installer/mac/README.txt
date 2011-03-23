#!/bin/bash

# Useful Apple Packaging References
# ========================================
#
# Guidelines for Developers
# http://developer.apple.com/tools/installerpolicy.html
#
# Packagemaker Howto
# http://s.sudre.free.fr/Stuff/PackageMaker_Howto.html
#
# Packagemaker Man Page
# http://developer.apple.com/mac/library/documentation/Darwin/Reference/ManPages/man1/packagemaker.1.html
#
# Software Delivery Guide
# http://developer.apple.com/mac/library/documentation/DeveloperTools/Conceptual/SoftwareDistribution/Introduction/Introduction.html
#
# Receipts
# ========
#
# The presence or absense of a receipt determines whether the Apple 
# Installer runs in install or upgrade mode. In Leopard and earlier,
# receipts were in /Library/Receipts. In Snow Leopard and up, they
# are in /var/db/receipts
#
#
# OpenGeo Suite Mac Requirements
# ========================================
#
# Get the Titanium SDK
# --------------------
#
# http://www.appcelerator.com/products/download/
#
# Get the Iceberg package maker
# -----------------------------
#
# http://s.sudre.free.fr/Software/Iceberg.html
#
#
# OpenGeo Suite Mac Layout
# ========================
# 
# The Mac install is made up of multiple pkg installers that are bundled into
# a single mpkg for installation. Note that both server components include a 
# VERSION file, so that components can be kept in synch in the future (avoid
# installing a new version of one component next to old version of another).
#
# PostGIS Server.pkg
#  /opt/opengeo/pgsql/*
#  /opt/opengeo/suite/VERSION
#  /Library/LaunchDaemons/org.opengeo.postgis
#  Preinstall scripts to alter shmmem and create
#    /etc/paths.d/opengeo-postgis
#    /etc/manpaths.d/opengeo-postgis
#
# GeoServer.pkg
#  /opt/opengeo/geoserver/*
#  /opt/opengeo/suite/VERSION
#  /Library/LaunchDaemons/org.opengeo.geoserver
#  Preinstall scripts to find existing data_dir and preserve it
#  Preinstall scripts to wipe out existing OpenGeo Suite.app
#  Postinstall scripts to bring in any existing data_dir
#
# PostGIS Client.pkg
#  /Applications/OpenGeo/pgShapeLoader.app
#  /Applications/OpenGeo/pgAdmin III.app
#
# DashBoard.pkg
#  Preinstall scripts to wipe out any existing OpenGeo Dashboard.app
#  /Applications/OpenGeo/OpenGeo Dashboard.app
#
# OpenGeo Suite.mpkg
#  Master package container.
#

# OpenGeo Suite Mac Build
# =======================
#
# See the hudson_installer.sh build script for details of the build process...
#
# Build the Suite Distribution
# ----------------------------
#
#  From the root of the suite source tree build a distribution with the commands:
#
  cd ../..
  mvn clean install -Dfull
  mvn assembly:attached
  cd installer/mac.new
#
# Upon success the artifact 'target/suite-<VERSION>-mac.zip' will be created.
#

# Build the Dashboard
# -------------------
#
# Change directory to the 'dashboard' module directly under the root 
# of the suite source tree.
#
  cd ../../dashboard
#
# Ensure the 'tibuild.py' script is on your PATH. It is located under:
#  
dashboard=1
if [ $dashboard ]; then

  titanium_version=1.0.0
  export PATH=$PATH:/Library/Application\ Support/Titanium/sdk/osx/$titanium_version
#
# Build the dashboard app by executing the following command:
#
  tibuild.py -d . \
             -s /Library/Application\ Support/Titanium \
             -a /Library/Application\ Support/Titanium/sdk/osx/$titanium_version/ \
             OpenGeo\ Dashboard/
fi

#
# Note: If the command errors out with a message about 
# "OpenGeo Dashboard.dmg" that is OK.
#
# Upon success the directory "OpenGeo Dashboard.app" will be created. 
# To test that the artifact was built properly execute the command:
#
#  open OpenGeo\ Dashboard.app
#
# This should run the dashboard.
#
