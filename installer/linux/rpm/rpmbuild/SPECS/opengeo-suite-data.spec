Name: opengeo-suite-data
Version: 2.4.1
Release: 1
Summary: Sample geospatial data required for use with the OpenGeo Suite.
Group: Unspecified
License: see http://opengeo.org
Requires(post): bash
Requires(preun): bash
Requires: tomcat5
Patch0: medford_taxlots_datastore.patch
Patch1: db_properties.patch

%define _rpmdir ../ 
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm 
%define _unpackaged_files_terminate_build 0

%description
A customized GeoServer data directory containing data required for use with 
the OpenGeo Suite.  


%prep
  cd $RPM_SOURCE_DIR/opengeo-suite-data/data_dir
%patch0 -p1
%patch1 -p1
  cd ../../../

%install
  rm -rf $RPM_BUILD_ROOT
  mkdir -p $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoserver_data
  mkdir -p $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoexplorer_data
  cp -rp  $RPM_SOURCE_DIR/opengeo-suite-data/data_dir/* $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoserver_data/.
  #cp $RPM_SOURCE_DIR/opengeo-suite-data/debian/datastore.xml $RPM_BUILD_ROOT/usr/share/opengeo-suite-data/geoserver_data/workspaces/medford/Taxlots/datastore.xml
  find $RPM_BUILD_ROOT/usr/share/opengeo-suite-data -iname .svn  -print0 | xargs -0 rm -rf

%pre
  GS_DATA=/usr/share/opengeo-suite-data/geoserver_data
  GS_DATA_SAV=${GS_DATA}.sav

  function backup_dir() {
    if [ -e ${GS_DATA}/$1 ]; then
      cp -r ${GS_DATA}/$1 ${GS_DATA_SAV}
    fi
  }

  if [ "$1" == "2" ]; then

    # on upgrade we want to save the users existing geoserver config
    if [ -e ${GS_DATA_SAV} ]; then
      # should not be here
      mv ${GS_DATA_SAV} ${GS_DATA}.old
    fi

    # create a temp directory to store those files the user may have changed
    mkdir ${GS_DATA_SAV}

    # xml configuration files
    cp ${GS_DATA}/*.xml ${GS_DATA_SAV}

    # logs
    backup_dir logs

    # security config
    backup_dir security

    # user_projections
    backup_dir user_projections

    # monitoring
    backup_dir monitoring

    # proxy
    backup_dir proxy

    # uploader
    backup_dir uploader
  fi

%post
  GS_DATA=/usr/share/opengeo-suite-data/geoserver_data
  GS_DATA_SAV=${GS_DATA}.sav

  # check for upgrade, if upgrading we want to perserve the configuration
  if [ "$1" == "2" ]; then
    if [ -e $GS_DATA_SAV ]; then   
      # first do the version checks for things we actually want to upgrade
      OLD_VER=`rpm -q --queryformat="%{VERSION}\n" opengeo-suite-data | sort | head -n 1`

      if [ $OLD_VER == "2.3.3" ]; then
        # we want to change the monitoring config
        if [ -e ${GS_DATA_SAV}/monitoring ]; then
          mv ${GS_DATA_SAV}/monitoring ${GS_DATA_SAV}/monitoring.bak
        fi
      fi

      # copy the saved configuration over
      cp -rfp $GS_DATA_SAV/* $GS_DATA

      # remove the saved copy
      rm -rf $GS_DATA_SAV
    fi
  fi

  chown tomcat. /usr/share/opengeo-suite-data -R


%preun

%postun
# remove files
# remove users


%clean

%files
%defattr(-,root,root,-)
/usr/share/opengeo-suite-data
