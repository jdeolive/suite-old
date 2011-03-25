Name: opengeo-data-tools
Version: 2.4.1
Release: 1
Summary: OpenGeo Suite Data Tools
Group: Applications/Engineering
License: see http://opengeo.org
Requires(post): bash
Requires(preun): bash
Requires: opengeo-geoserver >= 2.4.1

%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0

%description
Tools to make remote data management easier with GeoServer. This includes an
 interface for uploading data and a batch configuration tool.

%prep

%install
   rm -rf $RPM_BUILD_ROOT

   LIB=$RPM_BUILD_ROOT/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib
   mkdir -p $LIB
   cp -rp  $RPM_SOURCE_DIR/opengeo-data-tools/*.jar  $LIB

%post
  service tomcat5 restart

%preun

%postun
  service tomcat5 restart

%clean

%files
%defattr(-,root,root,-)
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/importer-*.jar
