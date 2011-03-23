# This spec file and ancilliary files are licensed in accordance with
# The pgAdmin license.
# In this file you can find the default build package list macros.  These can be overridden
# by defining on the rpm command line:
# rpm --define 'macroname value' ... to change the value of the macro.

Summary:	Graphical client for PostgreSQL
Name:		pgadmin3
Version:	1.8.0
Release:	1%{?dist}
License:	Artistic
Group:		Applications/Databases
URL:		http://www.pgadmin.org/
Source:		pgadmin3-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: wxGTK2-devel wxGTK2-stc wxGTK2-xrc postgresql84-devel desktop-file-utils openssl-devel libxml2-devel libxslt-devel

%define beta 1
%{?beta:%define __os_install_post /usr/lib/rpm/brp-compress}

%description
pgAdmin III is a powerful administration and development 
platform for the PostgreSQL database, free for any use.
It is designed to answer the needs of all users,
from writing simple SQL queries to developing complex 
databases. The graphical interface supports all PostgreSQL 
features and makes administration easy. 

The application also includes a query builder, an SQL 
editor, a server-side code editor and much more. 

%package docs
Summary:	Documentation for pgAdmin3
Group:		Applications/Databases
Requires:	%{name} = %{version}

%description docs
This package contains documentation for various languages,
which are in html format.

%prep
%setup -q -n %{name}-%{version}
#%patch1 -p0

%build
export LIBS="-lwx_gtk2u_core-2.8"
%configure --disable-debug --with-wx-version=2.8 --with-wx=/usr
make %{?_smp_mflags} all

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}

make DESTDIR=%{buildroot} install
cp -f $RPM_BUILD_DIR/branding.ini %{buildroot}/%{_datadir}/%{name}/branding/
cp -f $RPM_BUILD_DIR/pgadmin_splash.gif %{buildroot}/%{_datadir}/%{name}/branding/

#cp -f ./src/include/images/elephant48.xpm %{buildroot}/%{_datadir}/%{name}/%{name}.xpm

mkdir -p %{buildroot}/%{_datadir}/applications

desktop-file-install --vendor fedora --dir %{buildroot}/%{_datadir}/applications \
	--add-category X-Fedora\
	--add-category Application\
	--add-category Development\
	./pkg/%{name}.desktop

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root)
%doc BUGS CHANGELOG LICENSE README
%{_bindir}/*
%{_datadir}/%{name}
%{_datadir}/applications/*

%files docs
%defattr(-,root,root)
%doc docs/*

%changelog
* Mon Oct 22 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.8.0-1
- Update to 1.8.0 Gold

* Wed Oct 10 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.8.0-rc1-1
- Update to 1.8.0-rc1

* Tue  Sep 10 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.8.0-beta5-1
- Update to 1.8.0-beta5

* Tue  Sep 4 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.8.0-beta4-1
- Update to 1.8.0-beta4

* Fri Aug 10 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.8.0-beta3-1
- Update to 1.8.0-beta3

* Sat Jul 28 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.8.0-beta2-1
- Update to 1.8.0-beta2

* Fri Jul 13 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.8.0-beta1-1
- Update to 1.8.0-beta1

* Tue Mar 27 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.6.3-1
- Update to 1.6.3

* Mon Jan 8 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.6.2-1
- Update to 1.6.2
- Removed patch1 that is already in this version

* Tue Jan 2 2007 Devrim GUNDUZ <devrim@commandprompt.com> 1.6.1-2
- Rebuilt

* Wed Dec 20 2006 Devrim GUNDUZ <devrim@commandprompt.com> 1.6.1-1
- Update to 1.6.1
- Sync to Fedora Extras spec as much as possible

* Thu Jul 20 2006 Devrim GUNDUZ <devrim@commandprompt.com> 1.4.3-1
- 1.4.3
- Fixed all rpmlint errors and some warnings
- Moved all html docs to a new -docs rpm

* Thu Mar 9 2006 David Fetter <david@fetter.org> 1.4.2-1
- 1.4.2

* Sat Dec 10 2005 Devrim GUNDUZ <devrim@commandprompt.com> 1.4.1-1
- 1.4.1

* Mon Nov 7 2005 Devrim GUNDUZ <devrim@gunduz.org> 1.4.0-1
- 1.4.0 Gold

* Tue Nov 1 2005 Devrim GUNDUZ <devrim@gunduz.org> 1.4.0-RC1
- 1.4.0 RC1 

* Fri Oct 21 2005 Devrim GUNDUZ <devrim@gunduz.org> 1.4.0-beta3
- 1.4.0 beta3

* Tue Oct 18 2005 Devrim GUNDUZ <devrim@gunduz.org> 1.4.0-beta2
- 1.4.0 beta2
- Changed configure parameters.
- Spec file makeup

* Tue Jun 28 2005 Devrim GUNDUZ <devrim@gunduz.org> 1.2.2
- 1.2.2

* Mon Nov 29 2004 Devrim GUNDUZ <devrim@gunduz.org> 1.2.0
- 1.2.0 Gold

* Wed Nov 17 2004 Devrim GUNDUZ <devrim@gunduz.org> 1.2.0-RC2
- 1.2.0 RC2 

* Mon Nov 15 2004 Devrim GUNDUZ <devrim@gunduz.org> 1.2.0-RC1
- 1.2.0 RC1 rebuilt
- Fixed spec file so that beta and rc tags will be considered. (Note: AFAICS my previous rpms were broken :( )

* Thu Nov 4 2004 Devrim GUNDUZ <devrim@gunduz.org> 1.2.0-RC1
- 1.2.0 RC1

* Mon Jun 10 2003 Jean-Michel POURE <pgadmin-hackers@postgresql.org> 1.1.0
- Initial build

