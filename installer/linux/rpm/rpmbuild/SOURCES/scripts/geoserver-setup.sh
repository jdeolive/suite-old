#!/bin/bash
# postinst script for geoserver
#

fin=0

# get current values from geoserver_data
GS_DATA=/usr/share/opengeo-suite-data/geoserver_data

if [ -e $GS_DATA ]; then
  host="`cat $GS_DATA/global.xml | grep "<proxyBaseUrl>" | sed 's#</\?proxyBaseUrl>##g' | sed 's#.*://##g' | sed 's#/.*##g'`"
  admin="`cat $GS_DATA/security/users.properties | grep -v "^ *#" | grep ".*=.*, *ROLE_ADMINISTRATOR" | head -n 1`"
  user="`echo $admin | sed 's/ *=.*//g'`"
  pass="`echo $admin | sed 's/.*= *//g' | sed 's/,.*//g'`"

  #save old values in order to replace them later
  old_host=$host
  old_user=$user
  old_pass=$pass
else
  #host=`echo $(/sbin/ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')`
  host=""
  user="admin"
  pass="geoserver"
fi

exit=0
set -e

function check_root () {
  if [ ! $( id -u ) -eq 0 ]; then
    printf "This script must be run as root. Exiting.\n"
    exit 1
  fi
}

function randpass() {
  [ "$2" == "0" ] && CHAR="[:alnum:]" || CHAR="[:graph:]"
    cat /dev/urandom | tr -cd "$CHAR" | head -c ${1:-32}
    echo
}

respond() {
  printf "$1: [$2] "
  read choice
  if [  "$choice" = "" ] || [ ${#choice} -lt $3  ]; then
    choice=$2
  fi
}


menu() {

  printf "
  GeoServer Post Configuration.

  Select an entry from the following list:
  ----------------------
  1. Proxy URL             : $host
  2. Admin username        : $user
  3. Admin password        : $pass

  9. Accept and continue
  0. Abort and quit

  choice: "

  read menuchoice

case "$menuchoice" in
    "1")
        printf "Please provide the URL that GeoServer is accessed through publicly.\n"
        printf "This value is required in cases where GeoServer is accessed though an\n"
        printf "external proxy. Enter 'none' to leave value unset.\n"
        respond "hostname" "$host" "3"
        host=$choice
        if [ -z $host ] || [ "$host" == "none" ]; then
          host=""
        else
          host=`echo $host | sed s#http://##g | sed 's#/.*##g'`
        fi
        ;;

    "2")
        printf "Please choose a username for the GeoServer admin account.\n"
        respond "username" "$user" "3"
        user=$choice
        ;;

    "3")
        printf "Please choose a password for the GeoServer admin account.\n"
        respond "password" "$pass" "3"
        pass=$choice
        ;;

    "9")
        printf "Saving changes.\n"
        fin="1"
        #TODO configure a check to prevent rerunning this


# update the proxy base url in global.xml
GLOBAL_XML=$GS_DATA/global.xml
if [ -z $host ]; then
  # user is unsetting value, remove the old element if it exists
  sed -i 's/.*<proxyBaseUrl>.*//g' $GLOBAL_XML

elif [ $( grep "<proxyBaseUrl>" $GLOBAL_XML | wc -l ) != 0 ]; then

  # user specified value and an old entry already exists

  if [ ! -z $old_host ]; then
    # the old value is not empty
    sed -i "s#\(.*<proxyBaseUrl>.*\)$old_host\(.*\)#\1$host\2#g" $GLOBAL_XML
  else
    # the old value is empty
    sed -i "s#\(.*\)<proxyBaseUrl>.*#\1<proxyBaseUrl>http://$host/geoserver</proxyBaseUrl>#g" $GLOBAL_XML
  fi

else 

  # uset specified value but no element in file exists

  sed -i "s#</global>#  <proxyBaseUrl>http://$host/geoserver</proxyBaseUrl>#g" $GLOBAL_XML
  echo "</global>" >> $GLOBAL_XML

fi

# update user/pass in security/users.properties
USERS_PROPS=$GS_DATA/security/users.properties
if [ ! -z $old_user ]; then
  if [ ! -z $old_pass ]; then
    sed -i "s#$old_user *= *$old_pass#$user=$pass#g" $USERS_PROPS
  else
    sed -i "s#$old_user *=#$user=$pass#g" $USERS_PROPS
  fi
else
  # no old user , append the new one
  echo "$user=$pass,ROLE_ADMINISTRATOR" >> $USERS_PROPS
fi

if [ ! -d "/var/lib/tomcat5/webapps/geoserver" ]; then
       unzip  -o /var/lib/tomcat5/webapps/geoserver.war  -d /var/lib/tomcat5/webapps/geoserver  > /dev/null 2>&1
fi

if [ -e /etc/sysconfig/iptables ] && [ ! `cat /etc/sysconfig/iptables | grep 8080 |wc -l` ]; then
	iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
	iptables-save > /etc/sysconfig/iptables
fi

if [ -e /sbin/service ]; then
	/sbin/service tomcat5 restart
else
	/etc/init.d/tomcat5 restart
fi
    ;;

    "0")
        echo "Aborting, changes not saved."
        exit 255
    ;;
  esac
}

#check_root
while [ $fin -eq 0 ]; do
  menu
done

exit 0
