Pre-built Binary Files
----------------------

The platform-dependent parts of the Suite currently require pre-built
binaries to be brought into the assembly process. 

 * GDAL libraries 
 * PostgreSQL binaries
 * PostGIS binaries
 * Windows JRE

The binaries are stored on data.opengeo.org:

 http://data.opengeo.org/suite/
 arachnia:/sites/data.opengeo.org/htdocs/suite/

The naming scheme for zip files includes version number, build number and
platform, for example:

 * suite-gdal-1.4.1-1-win.zip
 * suite-gdal-1.4.1-1-osx.zip
 * suite-gdal-1.4.1-1-lin.zip
 * pgsql-8.4.3-postgis-1.5.1-1-win.zip
 * pgsql-8.4.3-postgis-1.5.1-1-osx.zip

Zip File Information
--------------------

PgSQL/PostGIS Windows files come separately and are combined at assembly time.
PgSQL Windows zip file from EDB come with a ./pgsql/ prefix.
PostGIS Windows zip file comes without a prefix.

PgSQL/PostGIS OSX files come in a single zip file.
PgSQL/PostGIS OSX zip file comes without a prefix.

JRE Windows zip file comes with a ./jre/ prefix
JRE Linux zip file comes with a ./jre/ prefix

GDAL Windows zip file comes without a prefix.

In OSX, the user applications pgShapeLoader and pgAdmin come in the 
root of the zip file and contain all their dependencies and 
may be relocated into /Applications if so desired.

In Windows, the user applications shp2pgsql-gui.exe and pgadmin.exe will be in 
the ./bin directory alongside their shared dependencies, and should be 
addressed with shortcuts, not relocated.



