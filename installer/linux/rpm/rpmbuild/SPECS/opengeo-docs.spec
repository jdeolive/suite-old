Name: opengeo-docs
Version: 2.4.3
Release: 1
Summary: Full documentation for the OpenGeo Suite.
Group: Documentation
License: see http://opengeo.org
Requires(post): bash
Requires(preun): bash

%define _rpmdir ../ 
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm 
%define _unpackaged_files_terminate_build 0

%description
Contains HTML documentation for the following components of the OpenGeo Suite: 
PostGIS, GeoServer, GeoWebCache, GeoExplorer, Styler, and GeoEditor.  Also 
includes a Getting Started Guide for an introduction to the OpenGeo Suite.

%install
  rm -rf $RPM_BUILD_ROOT
  mkdir -p $RPM_BUILD_ROOT/usr/share
  cp -rp  $RPM_SOURCE_DIR/opengeo-docs/opengeo-docs $RPM_BUILD_ROOT/usr/share/.
%post

%preun

%postun
# remove files
# remove users


%clean

%files
%defattr(-,root,root,-)
/usr/share/opengeo-docs
