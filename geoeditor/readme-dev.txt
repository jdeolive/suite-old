===============================
Running and deploying GeoEditor
===============================

These instructions describe how to deploy GeoEditor assuming you have a copy
of the application source code from subversion.

Getting a copy of the application
---------------------------------

To get a copy of the application source code, use subversion::

    you@prompt:~$ svn checkout http://svn.opengeo.org/tike/editor/trunk/ geoeditor


Running in development mode
---------------------------

The application can be run in development or distribution mode.  In development
mode, individual scripts are available to a debugger.  In distribution mode,
scripts are concatenated and minified.

To run the application in development mode, change into the build directory and
run ant::

    you@prompt:~$ cd geoeditor/build
    you@prompt:~/geoeditor/build$ ant dev

If the build succeeds, everything you need to run the application will be in the
new build/GeoEditor directory.  Browse to this directory in your browser (e.g.
http://localhost/~you/geoeditor/build/GeoEditor).


Preparing the application for deployment
----------------------------------------

Running GeoEditor as described above is not suitable for production because
JavaScript files will be loaded dynamically. Before moving your application to a
production environment, follow the steps below.

1. Copy any changes to the app configuration you made in GeoEditor/index.html
into the geoeditor/src/html/index.html file. Just copy the changes to the
JavaScript - do not copy the entire contents of the file.

2. If you have not already set up JSTools, do so following the instructions you
find on the JSTools project page: http://pypi.python.org/pypi/JSTools

3. Run ant to build the application for distribution.

For example, to create a directory that can be moved to your production
environment, do the following::

    you@prompt:~$ cd geoeditor/build
    you@prompt:~/geoeditor/build$ ant

Move the GeoEditor directory (from the build directory) to your production
environment.

If you want to create a zip archive of the application, instead run the
following:::

    you@prompt:~/geoeditor/build$ ant zip


Connecting GeoEditor to a local GeoServer
-----------------------------------------

The easiest way to run GeoEditor is to place it in the www folder of a
GeoServer data dir. This requires the production build described above (built by
running `ant`).

1. Copy the build/GeoEditor directory to $GEOSERVER_DATA_DIR/www/

2. Modify the "wms" configuration value in GeoEditor/index.html to reflect the
path to your GeoServer WMS endpoint (usually "/geoserver/wms").

3. Modify the "wfs" configuration value in GeoEditor/index.html to reflect the
path to your GeoServer WFS endpoing (usually "/geoserver/wfs").

4. Open the index.html page in a browser (e.g.
http://localhost:8080/geoserver/www/GeoEditor/index.html)

