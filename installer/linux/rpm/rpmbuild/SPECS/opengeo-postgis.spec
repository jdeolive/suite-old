Name: opengeo-postgis
Version: 2.4.1
Release: 1
Summary: Robust, spatially-enabled object-relational database built on PostgreSQL.
Group: Applications/Database
License: see http://opengeo.org
Requires(post): bash
Requires(preun): bash
Requires: postgresql84, postgresql84-contrib, postgis, pgadmin3

%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0

%description
PostGIS adds support for geographic objects to the PostgreSQL 
object-relational database, allowing it to be used as a spatial database for 
geographic information systems (GIS). PostGIS follows the OGC "Simple Features 
Specification for SQL" specification and has been certified as compliant with 
the "Types and Functions" profile.  PostGIS is a core component of the OpenGeo 
Suite.


%install
  rm -rf $RPM_BUILD_ROOT
  mkdir -p $RPM_BUILD_ROOT/usr/share/opengeo-postgis
  cp -rp  $RPM_SOURCE_DIR/opengeo-postgis/*.sql $RPM_BUILD_ROOT/usr/share/opengeo-postgis/.
  cp -rp $RPM_SOURCE_DIR/scripts/opengeo-postgis/* $RPM_BUILD_ROOT/usr/share/opengeo-postgis/.

%post
  OG_POSTGIS=/usr/share/opengeo-postgis

  # if a tmp marker exists from previous install, move it back before the 
  # next install
  if [ -e $OG_POSTGIS/geoserver_db.tmp ]; then
    mv $OG_POSTGIS/geoserver_db.tmp $OG_POSTGIS/geoserver_db
  fi

  # run the install
  sh $OG_POSTGIS/postgis-setup.sh --headless

  if [ "$1" == "2" ]; then
    # special case for upgrading from 2.3.3, move the geoserver_db marker 
    # so that the old packages uninstall does not see it and remove it
    OLD_VER=`rpm -q --queryformat="%{VERSION}\n" opengeo-postgis | sort | head -n 1` 
    if [ "$OLD_VER" == "2.3.3" ] &&  [ -e $OG_POSTGIS/geoserver_db ]; then
       mv $OG_POSTGIS/geoserver_db $OG_POSTGIS/geoserver_db.tmp
    fi
  fi
  
%preun
  OG_POSTGIS=/usr/share/opengeo-postgis

  # move back any temp markers
  if [ -e $OG_POSTGIS/geoserver_db.tmp ]; then
    mv $OG_POSTGIS/geoserver_db.tmp $OG_POSTGIS/geoserver_db
  fi

  # only uninstall on erase, not upgrade
  if [ "$1" == "0" ]; then
    sh $OG_POSTGIS/postgis-uninstall.sh --headless
  fi

%postun

# remove files
# remove users


%clean

%files
%defattr(-,root,root,-)
%dir "/usr/share/opengeo-postgis/*"

