Name:		geos
Version:	3.2.2
Release:	1%{?dist}
Summary:	GEOS is a C++ port of the Java Topology Suite

Group:		Applications/Engineering
License:	LGPLv2
URL:		http://trac.osgeo.org/geos/
Source0:	http://download.osgeo.org/%{name}/%{name}-%{version}.tar.bz2
Patch0:		geos-gcc43.patch
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires:	doxygen libtool
%if "%{?dist}" != ".el4"
BuildRequires:	swig ruby
BuildRequires:	python-devel ruby-devel
%endif

%{!?python_sitearch: %define python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(1)")}
%{!?ruby_sitearch: %define ruby_sitearch %(ruby -rrbconfig -e 'puts Config::CONFIG["sitearchdir"]')}

%description
GEOS (Geometry Engine - Open Source) is a C++ port of the Java Topology 
Suite (JTS). As such, it aims to contain the complete functionality of 
JTS in C++. This includes all the OpenGIS "Simple Features for SQL" spatial 
predicate functions and spatial operators, as well as specific JTS topology 
functions such as IsValid()

%package devel
Summary:	Development files for GEOS
Group:		Development/Libraries
Requires:	%{name} = %{version}-%{release}

%description devel
GEOS (Geometry Engine - Open Source) is a C++ port of the Java Topology 
Suite (JTS). As such, it aims to contain the complete functionality of 
JTS in C++. This includes all the OpenGIS "Simple Features for SQL" spatial 
predicate functions and spatial operators, as well as specific JTS topology 
functions such as IsValid()

This package contains the development files to build applications that 
use GEOS

%if "%{?dist}" != ".el4"
%package python
Summary:	Python modules for GEOS
Group:		Development/Libraries
Requires:	%{name} = %{version}-%{release}

%description python
Python module to build applications using GEOS and python

%package ruby
Summary:	Ruby modules for GEOS
Group:		Development/Libraries
Requires:	%{name} = %{version}-%{release}

%description ruby
Ruby module to build applications using GEOS and ruby
%endif

%prep
%setup -q
%patch0 -p0 -b .gcc43

%build

# fix python path on 64bit
sed -i -e 's|\/lib\/python|$libdir\/python|g' configure
sed -i -e 's|.get_python_lib(0|.get_python_lib(1|g' configure

# disable internal libtool to avoid hardcoded r-path
for makefile in `find . -type f -name 'Makefile.in'`; do
sed -i 's|@LIBTOOL@|%{_bindir}/libtool|g' $makefile
done

%configure --disable-static --disable-dependency-tracking \
%if "%{?dist}" != ".el4"
           --enable-python \
           --enable-ruby
%endif

make %{?_smp_mflags}

# Make doxygen documentation files
cd doc
make doxygen-html

%install
rm -rf %{buildroot}
make DESTDIR=%{buildroot} install

%check

# test module
make %{?_smp_mflags} check || exit 0

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%doc AUTHORS COPYING NEWS README TODO
%{_libdir}/libgeos-%{version}.so
%{_libdir}/libgeos_c.so.*
%exclude %{_libdir}/*.a

%files devel
%defattr(-,root,root,-)
%doc doc/doxygen_docs
%{_bindir}/geos-config
%{_includedir}/*
%{_libdir}/libgeos.so
%{_libdir}/libgeos_c.so
%exclude %{_libdir}/*.la
%exclude %{_libdir}/*.a

%if "%{?dist}" != ".el4"
%files python
%defattr(-,root,root,-)
%dir %{python_sitearch}/%{name}
%exclude %{python_sitearch}/%{name}/_%{name}.a
%exclude %{python_sitearch}/%{name}/_%{name}.la
%{python_sitearch}/%{name}.pth
%{python_sitearch}/%{name}/*.py
%{python_sitearch}/%{name}/*.py?
%{python_sitearch}/%{name}/_%{name}.so

%files ruby
%defattr(-,root,root,-)
%exclude %{ruby_sitearch}/%{name}.a
%exclude %{ruby_sitearch}/%{name}.la
%{ruby_sitearch}/%{name}.so
%endif

%changelog
* Thu Jul 1 2010 Devrim GUNDUZ <devrim@gunduz.org> - 3.2.2-1
- Initial packaging for RHEL-6
