#!/bin/bash

postgres_user=_opengeo
postgres_group=_opengeo

# Shut down the service first
launchctl stop org.opengeo.postgis
launchctl unload /Library/LaunchDaemons/
rm /Library/LaunchDaemons/org.opengeo.postgis
launchctl load /Library/LaunchDaemons/

# Really hammer it if it's still running
pgpid=`cat /opt/opengeo/pgsql/8.4/data/postmaster.pid | head -n1`
if [ $pgpid ]
then
  kill $pgpid
  sleep 2
fi

rm -rf /Applications/OpenGeo
rm /etc/paths.d/opengeo-pgsql
rm /etc/manpaths.d/opengeo-pgsql
rm -rf /opt/opengeo
dscl . -delete /Groups/$postgres_group
dscl . -delete /Users/$postgres_user

