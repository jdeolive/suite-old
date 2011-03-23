#!/bin/bash

# Verbose?
if [ "x$1" == "x" ]; then
  echo "Running in verbose mode..."
  rmopts="v"
  if [ $USER != "root" ]; then
    echo ""
    echo "Please run the uninstall script as root. For example,"
    echo ""
    echo "   sudo $0"
    echo ""
    exit 0
  fi
else
  rmopts=""
fi

# Check for running suite
suite_port=8080
netport=`lsof -iTCP:$suite_port | grep LISTEN | tr -d ' '`
if [ "x$netport" != "x" ]; then
  echo "Shutting down the Suite..."
  /opt/opengeo/suite/opengeo-suite stop > /dev/null
  echo '
   tell application "OpenGeo Dashboard"
   quit
   end tell
   ' | osascript
  sleep 2
fi

# Notify that we're starting...
echo ""
echo "Removing OpenGeo Suite files..."
echo ""

# Remove GUI Apps
if [ -d /Applications/OpenGeo ]; then
  rm -rf$rmopts /Applications/OpenGeo
fi

# Remove Server Apps
if [ -d /opt/opengeo ]; then
  rm -r$rmopts /opt/opengeo
fi

# Remove Config Files
find /Users -name .opengeo -maxdepth 2 -type d -exec /bin/rm -rvf {} ';'

# Remove Path Entries
if [ -f /private/etc/paths.d/opengeo-pgsql ]; then
  rm -f$rmopts /private/etc/paths.d/opengeo-pgsql
fi
if [ -f /private/etc/manpaths.d/opengeo-pgsql ]; then
  rm -f$rmopts /private/etc/manpaths.d/opengeo-pgsql
fi

# Remove receipts entries
if [ -d /Library/Receipts ]; then
  find /Library/Receipts -name "org.opengeo.*" -exec /bin/rm -rvf {} ';'
fi
if [ -d /var/db/receipts ]; then
  find /var/db/receipts -name "org.opengeo.*" -exec /bin/rm -rvf {} ';'
fi

echo ""
echo "The OpenGeo Suite is now uninstalled."
echo ""

