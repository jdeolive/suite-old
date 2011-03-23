Summary:        Geographic Information Systems Extensions to PostgreSQL
Name:           postgis
Version:        1.5.2
Release:        1
License:        GPL v2
Group:          Applications/Databases
Source:         %{name}-%{version}.tar.gz
Source1:	%{name}.rpmlintrc
Vendor:         The PostGIS Project
Packager:       Otto Dassau <dassau@gbd-consult.de>
URL:            http://postgis.refractions.net/
BuildRequires:  postgresql84-devel postgresql84 proj-devel proj geos-devel >= 2.1.1
BuildRequires:  gcc-c++ libxslt-devel dos2unix flex
Requires:       postgresql84
Requires:	postgresql84-server
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)

%description
PostGIS adds support for geographic objects to the PostgreSQL object-relational
database. In effect, PostGIS "spatially enables" the PostgreSQL server,
allowing it to be used as a backend spatial database for geographic information
systems (GIS), much like ESRI's SDE or Oracle's Spatial extension. PostGIS
follows the OpenGIS "Simple Features Specification for SQL" and will be
submitted for conformance testing at version 1.0.

%if 0%{?mandriva_version} < 2007
%debug_package
%endif

%package utils
Summary:        The utils for PostGIS
Group:          Applications/Interfaces
Requires:       %{name} = %{version} perl-DBD-Pg

%description utils
The postgis-utils package provides the utilities for PostGIS.

%prep
%setup -q

%define sqldir %{_datadir}/postgresql

%build
%configure --datadir=%{sqldir} --mandir=%{_mandir} --with-gui
make LPATH="%{_libdir}/postgresql" \
	shlib="%{name}.so"

%install
make install DESTDIR=%{buildroot}
install -d %{buildroot}%{sqldir}
install -m 755 *.sql %{buildroot}%{sqldir}
install -d %{buildroot}%{_bindir}
install -m 755 utils/*.pl %{buildroot}%{_bindir}

#JD: issue on centos with the perl Pg module, remove all developer scripts
rm %{buildroot}%{_bindir}/test_*.pl
rm %{buildroot}%{_bindir}/profile*.pl
install -d %{buildroot}%{_mandir}/man1/
install -m 644 doc/man/*.1 %{buildroot}%{_mandir}/man1/

perl -e '
foreach $d (split "\n",`find -type d`)
{
  next if $d eq ".";
  foreach $f ("TODO", "README")
  {
    my $r = "$f.$d"; $r =~ s/\.\///; $r =~ s/\//_/g; rename "$d/$f",$r;
    rename "$d.txt/$f",$r;
  }
}
'
dos2unix README.java_ejb2
dos2unix README.extras_tiger_geocoder
if ! [ -s TODO.loader ]; then
  rm TODO.loader
fi

ls -R

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%doc COPYING CREDITS NEWS README* TODO* doc/html/* loader/README.* 
%doc doc/ZMSgeoms.txt doc/postgis_comments.sql
%{_bindir}/*
%{_mandir}/man1/*
%{_libdir}/pgsql/*.so*
%defattr(755,root,root)
%{sqldir}/
%defattr(644,root,root)
%{sqldir}/*.sql
/usr/share/pgsql/contrib/postgis-1.5/postgis.sql
/usr/share/pgsql/contrib/postgis-1.5/postgis_upgrade_13_to_15.sql
/usr/share/pgsql/contrib/postgis-1.5/postgis_upgrade_14_to_15.sql
/usr/share/pgsql/contrib/postgis-1.5/postgis_upgrade_15_minor.sql
/usr/share/pgsql/contrib/postgis-1.5/spatial_ref_sys.sql
/usr/share/pgsql/contrib/postgis-1.5/uninstall_postgis.sql

%files utils
%defattr(755,root,root)
%{_bindir}/create_undef.pl
%{_bindir}/postgis_restore.pl

%changelog
* Fri Mar 19 2010 Otto Dassau 1.5.1
- update to current version
* Fri Feb 19 2010 Otto Dassau 1.5.0
- update to current version
- remove fixwarnings.diff patch
- added doc/postgis_comment.sql
* Thu Dec 31 2009 Otto Dassau 1.4.1
- update to current version
* Thu Sep 04 2009 Otto Dassau 1.4.0
- update to current version
- sqldir is now /usr/share/postgresql/contrib
* Wed Jan 28 2009 Otto Dassau 1.3.5
- update to current version
* Tue Nov 25 2008 Otto Dassau 1.3.4
- update to current version
* Mon Jul 14 2008 Otto Dassau 1.3.3
- added rpmlintrc file
* Wed Jul 09 2007 Dirk Stöcker <opensuse@dstoecker.de> 1.3.1
- adapted to openSUSE build service
* Tue Dec 22 2005 Devrim GUNDUZ 1.1.0
- Final fixes for 1.1.0
* Tue Dec 06 2005 Devrim GUNDUZ 1.10
- Update to 1.1.0
* Mon Oct 03 2005 Devrim GUNDUZ
- Make PostGIS build against pgxs so that we don't need PostgreSQL sources.
- Fixed all build errors except jdbc (so, defaulted to 0)
- Added new files under utils
- Removed postgis-jdbc2-makefile.patch (applied to -head)
* Tue Sep 27 2005 Devrim GUNDUZ 1.0.4
- Update to 1.0.4
* Sun Apr 20 2005 Devrim GUNDUZ 1.0.0
- 1.0.0 Gold
* Sun Apr 17 2005 Devrim GUNDUZ
- Modified the spec file so that we can build JDBC2 RPMs...
- Added -utils RPM to package list.
* Fri Apr 15 2005 Devrim GUNDUZ
- Added preun and postun scripts.
* Sat Apr 09 2005 Devrim GUNDUZ
- Initial RPM build
- Fixed libdir so that PostgreSQL installations will not complain about it.
- Enabled --with-geos and modified the old spec.


