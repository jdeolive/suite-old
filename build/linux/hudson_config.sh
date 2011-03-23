# Where do we build into (our --prefix)
buildroot=$HOME/buildroot/
webroot=/var/www/htdocs
export buildroot

# Versions we are going to continuously integrate...
geos_version=3.2
postgis_version=1.5
proj_version=4.7
pgsql_version=8.4.4
pgadmin_version=1.10.3
wx_version=2.8.11
openssl_version=0.9.8o
glib_version=2.24
gtk_version=2.20
pkg_version=0.19

# Special binaries
proj_nad=proj-datumgrid-1.5.zip

# Standard paths
geos_svn=http://svn.osgeo.org/geos/branches
postgis_svn=http://svn.osgeo.org/postgis/branches
proj_svn=http://svn.osgeo.org/metacrs/proj/branches

glib_base_url=http://ftp.gnome.org/pub/gnome/sources
glib_dir=glib-${glib_version}.1
glib_file=${glib_dir}.tar.bz2
glib_url=${glib_base_url}/glib/${glib_version}/${glib_file}

pkg_dir=pkg-config-${pkg_version}
pkg_file=${pkg_dir}.tar.bz2
pkg_url=${glib_base_url}/pkg-config/${pkg_version}/${pkg_file}

gtk_dir=gtk+-${gtk_version}.1
gtk_file=${gtk_dir}.tar.bz2
gtk_url=${glib_base_url}/gtk+/${gtk_version}/${gtk_file}

openssl_dir=openssl-${openssl_version}
openssl_file=${openssl_dir}.tar.gz
openssl_url=http://www.openssl.org/source/${openssl_file}

pgsql_dir=postgresql-${pgsql_version}
pgsql_file=${pgsql_dir}.tar.bz2
pgsql_url=http://ftp9.us.postgresql.org/pub/mirrors/postgresql/source/v${pgsql_version}/${pgsql_file}

pgadmin_dir=pgadmin3-${pgadmin_version}
pgadmin_file=${pgadmin_dir}.tar.gz
pgadmin_url=http://ftp9.us.postgresql.org/pub/mirrors/postgresql/pgadmin3/release/v${pgadmin_version}/src/${pgadmin_file}

wx_dir=wxWidgets-${wx_version}
wx_file=${wx_dir}.tar.bz2
wx_url=http://cdnetworks-us-2.dl.sourceforge.net/project/wxwindows/${wx_version}/${wx_file}

# Ensure the buildroot is ready
if [ ! -d $buildroot ]; then
  mkdir $buildroot
fi

function checkrv {
  if [ $1 -gt 0 ]; then
    echo "$2 failed with return value $1"
    exit 1
  else
    echo "$2 succeeded with return value $1"
  fi
}

function getfile {

  local url
  local file
  local dodownload

  url=$1
  file=$2
  dodownload=yes

  url_tag=`curl -L -f -s -I $url | grep ETag | tr -d \" | cut -f2 -d' '`
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
    curl -L -f $url > $file
    checkrv $? "Download from $url"
    echo $url_tag > "${file}.etag"
  fi

}


