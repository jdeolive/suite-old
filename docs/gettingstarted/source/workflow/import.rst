.. _workflow.import:

Step 2: Import Your Data
========================

The next step is to serve your data with GeoServer.  GeoServer comes with a **Layer Importer** application to make this process easy.  The Layer Importer can import data from shapefiles, PostGIS databases, and ArcSDE/Oracle Spatial databases (with appropriate extension files installed).

.. note:: This example workflow uses the PostGIS data from the previous step (:ref:`workflow.load`), however, if you skipped that step, you can import shapefiles here in much the same way.

#. First, make sure the OpenGeo Suite is running.  You can do this by clicking on the :guilabel:`Start` button in the :ref:`dashboard`.

#. Open the GeoServer Layer Importer.  You can do this in the Dashboard by clicking :guilabel:`Import data`, next to GeoServer.  Alternately, you can click on the :guilabel:`Importer` link inside main menu on the GeoServer UI.

#. Select the type of data you wish to import.

   .. note:: In order to enable ArcSDE and Oracle Spatial support in the Layer Importer, external files are required from your current database installation.  For ArcSDE, the files ``jsde*.jar`` and ``jpe*.jar`` are required.  For Oracle spatial, ``ojdbc*.jar`` is required.  Copy the file(s) into ``webapps/geoserver/WEB-INF/lib`` from the root of your installation, and then restart.  If successful, you will see extra options on this page.

   .. figure:: img/importer_datasource.png
      :align: center

      *Importing from PostGIS*

#. You may be asked to log into GeoServer.  Enter your current username and password and click :guilabel:`Login`.  (The default username and password is ``admin`` and ``geoserver`` although the :ref:`dashboard.prefs` page will show the current credentials.)

   .. figure:: img/importer_login.png
      :align: center

      *Logging in to the GeoServer admin interface*

#. Fill out the form.  First select a :guilabel:`Workspace` from the list.  A workspace is the name for a group of layers, and usually signifies a project name.  You may wish to create a new workspace if you'd like, by clicking on :guilabel:`create a new workspace`.

   .. warning:: The workspace name should not contain spaces.

   .. figure:: img/importer_createworkspace.png
      :align: center

      *Logging in to the GeoServer admin interface*

#. Select a :guilabel:`Name` for the GeoServer store.  Since this step just connects to the PostGIS database, naming this the same as your PostGIS database (by default this is your username) is a sensible default.

#. Enter a description in the :guilabel:`Description` field.  This too can be whatever you'd like it to be.

#. Under :guilabel:`Connection Parameters`, enter the following information:

   .. list-table::
      :widths: 20 80

      * - **Host**
        - localhost
      * - **Port**
        - 54321
      * - **Database**
        - [your username on your host operating system]
      * - **User name**
        - postgres
      * - **Password**
        - [blank]

#. When finished, click :guilabel:`Next`.

   .. figure:: img/importer_postgisconnection.png
      :align: center

      *Connection details*

#. On the next screen, a list of spatial tables will be displayed.  This list should correspond to the shapefiles that you loaded in :ref:`workflow.load`.  Check all of the boxes that you would like to serve with GeoServer and click :guilabel:`Import Data`.

   .. figure:: img/importer_selectresources.png
      :align: center

      *A listing of spatial layers found in the database*

#. A progress bar will display, loading each table into GeoServer.  When finished, the results will be displayed.  If there were any errors, they will be described in this list with a yellow exclamation mark.  

   .. figure:: img/importer_results.png
      :align: center

      *The results of the import*

#. You can see a preview of how each layer looks in either OpenLayers, Google Earth, or Styler, by clicking the appropriate link in the :guilabel:`Preview` column next to that layer.  If you would like to view a layer's configuration, click the :guilabel:`Name` of the layer.  If there were any problems during the import process (such as problems :ref:`workflow.load.projection`) they will be displayed in this list.

Your database tables have been turned into GeoServer layers.  If you wish to import data from other sources, you may repeat this process.