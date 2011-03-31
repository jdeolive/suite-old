Name: opengeo-postgis
Version: 2.3.3
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
  sh /usr/share/opengeo-postgis/postgis-setup.sh --headless
  
%preun
  sh /usr/share/opengeo-postgis/postgis-uninstall.sh --headless

%postun

# remove files
# remove users


%clean

%files
%defattr(-,root,root,-)
%dir "/usr/share/opengeo-postgis/*"

