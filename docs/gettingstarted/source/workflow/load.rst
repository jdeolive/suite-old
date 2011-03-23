.. _workflow.load:

Step 1: Load Your Data
======================

.. note:: If you'd like to serve data directly from shapefiles, you can skip to the next section, :ref:`workflow.import`.

The first step of any workflow is to load your data into the OpenGeo Suite.  For the purposes of this workflow, we will assume that your initial data is stored as shapefiles, although there are many types of data formats that are compatible with the OpenGeo Suite.

#. Launch the OpenGeo Suite :ref:`dashboard` and Start the OpenGeo Suite, if you have not already done so.

#. Click on the :guilabel:`Import Shapefiles` link.  This will load :guilabel:`pgShapeLoader` which will allow you to convert shapefiles to a tables in a PostGIS database.  Next, click on the box that is titled "Shape File."

   .. figure:: img/pgshapeloader.png
      :align: center

      *pgShapeLoader*

#. In the folder dialog that appears, navigate to the location of your first shapefile, select it, then click :guilabel:`Open`.

   .. figure:: img/pgshapeloader_selectfile.png
      :align: center

      *Selecting a shapefile to import*

#.  Next, fill out the form:

   .. list-table::
      :widths: 20 80

      * - **Username**
        - postgres
      * - **Password**
        - [blank]
      * - **Server Host**
        - localhost
      * - **Port**
        - **54321**
      * - **Database**
        - [your user name on your host operating system]
      * - **SRID**
        - The projection code for your shapefile

   .. note:: If you don't know the projection code (sometimes known as SRID, SRS, CRS, or EPSG code) see the next section on :ref:`workflow.load.projection`.

   .. figure:: img/pgshapeloader_beforeimport.png
      :align: center

      *Ready to import*

#. When ready, click :guilabel:`Import`.

   .. figure:: img/pgshapeloader_afterimport.png
      :align: center

      *A successful import*

#. The shapefile has been imported as a table in your PostGIS database.  Repeat the same process for any additional shapefiles.

.. _workflow.load.projection:

Determining projections
-----------------------

.. note:: For a workaround that eliminates the need to find the shapefile projection, you can import shapefiles directly into GeoServer.  Please skip to the :ref:`workflow.import` section for details.

There are three ways to determine the projection for a shapefile if it is not known.  You can look at read metadata, search the source site, or search `spatialreference.org <http://spatialreference.org>`_.

Read metadata
~~~~~~~~~~~~~

Shapefiles often have a metadata file included with it.  This metadata file can include information about the data contained in the shapefile, including the projection.  Look for an ``.xml`` file or ``.txt`` file among your shapefile collection and open this file in a text editor.  The projection will usually be a numerical code, possibly with a text prefix.  Examples:  "EPSG:4326" "EPSG:26918" "900913"

Search the source site
~~~~~~~~~~~~~~~~~~~~~~

Data download sites usually display information about the shapefiles on the site itself, sometimes on a page called "metadata" or "information about this data".  The projection will usually be a numerical code, possibly with a text prefix.  Examples:  "EPSG:4326" "EPSG:26918" "900913"

Search spatialreference.org
~~~~~~~~~~~~~~~~~~~~~~~~~~~

`spatialreference.org <http://spatialreference.org>`_ is a web site that offers information on projections.  You can use the site's search box to help determine the projection for your shapefile.

Shapefiles are comprised of multiple files, each with different extensions (``.shp``, ``.shx``, ``.prj`` and others).  Open the file with the ``.prj`` file in a text editor.  This file contains the technical details of the projection.  Copy the first block of text inside quotes and paste it into the search box of spatialreference.org .  Assuming a match, the site will return the likely projection code.  If the first text block fails, try the next block of text inside quotes.  Repeat this process if necessary to obtain the likely projection code.

Workaround
~~~~~~~~~~

If you are still unable to find the projection, you can instead load your shapefiles directly into GeoServer, bypassing PostGIS.  GeoServer may be able to intelligently determine the proper projection.  See the :ref:`workflow.import` section for details.

Verifying data
--------------

To verify that your data was loaded properly, you can use :guilabel:`pgAdmin`, a desktop GUI for database management.

#. Launch pgAdmin by clicking the :guilabel:`PostGIS` link in the Dashboard.

   .. figure:: img/pgadmin.png
      :align: center

      *pgAdmin*

#. Double click on the server instance called :guilabel:`PostGIS (localhost:54321)` in the Object Browser.

   .. note:: If you are asked for a password, you can leave it blank.

#. Expand the tree to view :menuselection:`PostGIS (localhost:54321) --> Databases -> [username] -> Schemas -> public -> Tables`.  You should see a listing of tables corresponding to the shapefiles that you loaded.

   .. note:: There will be two extra tables in the list, :guilabel:`geometry_columns`, and :guilabel:`spatial_ref_sys`.  Those two tables are automatically created by PostGIS.

   .. figure:: img/pgadmin_tables.png
      :align: center

      *Database table listing*

For more information about pgAdmin and PostGIS, please see the PostGIS Documentation. You can access this by clicking the :guilabel:`PostGIS Documentation` link in the :ref:`dashboard`.