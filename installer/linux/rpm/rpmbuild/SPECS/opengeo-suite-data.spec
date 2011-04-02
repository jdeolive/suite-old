Name: opengeo-suite-data
Version: 2.4.1
Release: 1
Summary: Sample geospatial data required for use with the OpenGeo Suite.
Group: Unspecified
License: see http://opengeo.org
Requires(post): bash
Requires(preun): bash
Requires: tomcat5
Patch: medford_taxlots_datastore.patch

%define _rpmdir ../ 
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm 
%define _unpackaged_files_terminate_build 0

%description
A customized GeoServer data directory containing data required for use with 
the OpenGeo Suite.  


%prep
  cd $RPM_SOURCE_DIR/opengeo-suite-data/data_dir
%patch -p1
  cd ../../../

%install
  rm -rf $RPM_BUILD_ROOT
  mkdir -p $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoserver_data
  mkdir -p $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoexplorer_data
  cp -rp  $RPM_SOURCE_DIR/opengeo-suite-data/data_dir/* $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoserver_data/.
  #cp $RPM_SOURCE_DIR/opengeo-suite-data/debian/datastore.xml $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoserver_data/workspaces/medford/Taxlots/datastore.xml
  find $RPM_BUILD_ROOT/usr/share/opengeo-suite-data -iname .svn  -print0 | xargs -0 rm -rf
%post
chown tomcat. /usr/share/opengeo-suite-data -R

%preun

%postun
# remove files
# remove users


%clean

%files
%defattr(-,root,root,-)
/usr/share/opengeo-suite-data
