#!/bin/bash
# postinst script for geoserver
#

fin=0
myhost=`echo $(/sbin/ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')`
username="admin"
password="admin"
exit=0
set -e

function check_root () {
  printf "Checking permissions..."
  [ ! $( id -u ) -eq 0 ] \
    && { echo "error: not root.\nPlease run 'sudo $0'";
       exit 1; }
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
  ----------------------
  1. hostname or ip        : $myhost
  2. geoserver username    : $username
  3. geoserver password    : $password

  9. accept config and continue
  0. abort/quit

  choice: "

  read menuchoice

case "$menuchoice" in
    "1")
        printf "please provide the ipaddress or hostname of this machine\ndo *NOT* put http:// or a / after (no spaces)\n"
        respond "hostname" "$myhost" "3"
        myhost=$choice
        ;;

    "2")
        printf "please choose a username to log into geoserver with\n"
        respond "username" "$username" "3"
        username=$choice
        ;;

    "3")
        printf "please choose a password to log into geoserver with\n"
        respond "password" "$password" "3"
        password=$choice
        ;;

    "9")
        fin="1"
        #TODO configure a check to prevent rerunning this

cat << EOF > /usr/share/opengeo-suite-data/geoserver_data/security/users.properties
$username=$password,ROLE_ADMINISTRATOR
# These are sample users you may uncomment if you want to test locking down wfs (see service.properties)
#wfst=wfst,ROLE_WFS_READ,ROLE_WFS_WRITE
#wfs=wfs,ROLE_WFS_READ
EOF

if [ ! -d "/var/lib/tomcat5/webapps/geoserver" ]; then
       unzip  -o /var/lib/tomcat5/webapps/geoserver.war  -d /var/lib/tomcat5/webapps/geoserver  > /dev/null 2>&1
        sed -i -e "s/MYHOST/$myhost/g" /var/lib/tomcat5/webapps/geoserver/WEB-INF/web.xml
fi

if [ ! `cat /etc/sysconfig/iptables | grep 8080 |wc -l`]; then
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
        echo "aborting, changes not saved"
        exit 255
    ;;
  esac
}

check_root
while [ $fin -eq 0 ]; do
  menu
done

exit 0
