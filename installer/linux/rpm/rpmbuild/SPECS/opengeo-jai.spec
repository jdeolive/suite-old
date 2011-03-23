Name: opengeo-jai
Version: 1.1.3
Release: 1
Summary:  A set of Java toolkits to provide enhanced image rendering abilities.
Group: System Environment/Libraries
License: see copyright
Requires(post): bash
Requires(preun): bash
Requires: tomcat5, java-1.6.0-openjdk

%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0

%description
Java Advanced Imaging API (JAI) provides a set of object-oriented interfaces 
that supports a simple, high-level programming model which allows images to 
be manipulated easily in Java applications and applets.  Java Advanced 
Imaging Image I/O Tools provides JAI read and write operations which use the 
Java Image I/O Framework.  These toolkits provide enhanced image rendering to 
the OpenGeo Suite.

%install
        rm -rf $RPM_BUILD_ROOT
        mkdir -p $RPM_BUILD_ROOT/usr/lib/opengeo-jai
        echo "using $sourcefiles for package contents"
        cp -rp  $RPM_SOURCE_DIR/opengeo-jai/* $RPM_BUILD_ROOT/usr/lib/opengeo-jai/.

%post
        if [ -d /usr/lib/jvm/java-6-sun ]; then
                cp -rp /usr/lib/opengeo-jai/* /usr/lib/jvm/java-6-sun/.
        fi

        if [ -d /usr/lib/jvm/java-1.6.0-openjdk ]; then
                cp -rp /usr/lib/opengeo-jai/* /usr/lib/jvm/java-1.6.0-openjdk/.
        fi


%postun
# remove files
# remove users
locations="/usr/lib/jvm/java-6-sun \
/usr/lib/jvm/java-1.6.0-openjdk"

filelist="jre/lib/amd64/libclib_jiio.so \
jre/lib/i386/libmlib_jai.so \
jre/lib/ext/clibwrapper_jiio.jar \
jre/lib/ext/jai_core.jar \
jre/lib/ext/jai_codec.jar \
jre/lib/ext/jai_imageio.jar \
jre/lib/ext/mlibwrapper_jai.jar"
        for i in $locations; do
                if [ -d $i ]; then
                        for a in $filelist; do rm -f $i/$a ; done
                fi
        done


%clean

%files
%defattr(-,root,root,-)
%dir "/usr/lib/opengeo-jai/*"
%dir "/usr/lib/opengeo-jai/jre/*"
%dir "/usr/lib/opengeo-jai/jre/lib/*"
%dir "/usr/lib/opengeo-jai/jre/lib/amd64/*"
%dir "/usr/lib/opengeo-jai/jre/lib/ext/*"
%dir "/usr/lib/opengeo-jai/jre/lib/i386/*"


