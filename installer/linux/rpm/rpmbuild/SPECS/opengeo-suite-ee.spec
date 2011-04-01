Name: opengeo-suite-ee
Version: 2.4.1
Release: 1
Summary: OpenGeo Suite Enterprise Edition.
Group: Applications/Engineering
License: see http://geoserver.org
Requires(post): bash
Requires(preun): bash
Requires: opengeo-suite >= 2.4.1

%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0

%description
The OpenGeo Suite Enterprise Edition provides additional modules and extensions
 geared toward enterprise and production systems.  

%prep

%install
   rm -rf $RPM_BUILD_ROOT

   LIB=$RPM_BUILD_ROOT/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib
   mkdir -p $LIB
   cp -rp  $RPM_SOURCE_DIR/opengeo-suite-ee/*.jar  $LIB

%post
  service tomcat5 restart

%preun

%postun
  service tomcat5 restart

%clean

%files
%defattr(-,root,root,-)
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/analytics-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/control-flow-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/monitoring-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/antlr-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/asm-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/asm-attrs-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/cglib-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/cglib-nodep-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/commons-vfs-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/dom4j-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/ehcache-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/ejb3-persistence-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/geoip-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/hibernate-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/hibernate-annotations-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/hibernate-commons-annotations-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/hibernate-entitymanager-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/jcommon-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/jfreechart-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/joda-time-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/jta-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/persistence-api-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/poi-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/spring-orm-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/wicket-datetime-*.jar
/var/lib/tomcat5/webapps/geoserver/WEB-INF/lib/
