.. _geoeditor.introduction:

Introduction
============

The process for data editing can be divided into two categories of operations: preparing and modifying data.  Data preparation involves querying a dataset filtered by location or attribute, while data modification involves generating new spatial features.

Before diving into the specifics of these operations, we introduce the basics concepts of the user interface and managing layers. For those familiar with GeoExplorer's interface, feel free to skip to the :ref:`geoeditor.preparing` section.

Running GeoEditor
-----------------

GeoEditor runs in a browser window.  By default, GeoEditor's URL is `http://localhost:8080/geoeditor <http://localhost:8080/geoeditor>`_

   .. figure:: images/geoeditor.png
      :align: center
   
      *GeoEditor*

GeoEditor Workspace
-------------------

GeoEditor has a single, integrated workspace where you can examine and manipulate your data.  There are three panels and one window:

* The :guilabel:`Layers panel` lists selected layers with associated legend in the :guilabel:`Legend` tab. You can use the Layers panel to manage display options. 
* The :guilabel:`Tools panel` contains tools for selecting, editing, and viewing layers. To view information about any tool, position the pointer over it. The name of the tool appears in a tool tip below the pointer.
* The :guilabel:`Map window` displays the map you’re working on.  Maps windows can display layers and/or query results along with controls for modifying and deleting features.
* The :guilabel:`Query panel` displays query options and results for the currently selected layer. 


Layers panel
~~~~~~~~~~~~

You can add layers by clicking on the (+) button.

The :guilabel:`Available Layers` dialog lists all layers on the current WMS server.  To display information about the layer, click on the (+) next to each layer. Select one or more layers and click ``Add Layers`` to add them to the list and the map window.

.. note:: GeoEditor can only provide access to a single WMS server. To configure GeoEditor to work with a WMS server other than the local GeoServer see :ref:`configuration`.

You can manage the composition of your layers through the :guilabel:`Layers` list. Right click on a layer to zoom to a layer extent, remove a layer from the list/map, or view layer properties.  

    .. list-table::
       :widths: 15 85 

       * - **Button**
         - **Description**
       * - .. image:: /images/managing1.png
         - Click (+) to add layers.
       * - .. image:: /images/managing2.png
         - Click (-) to remove the currently selected layer.
       * - .. image:: /images/managing3.png
         - For a selected layer, presents information and global settings (such as opacity and image format).
  
You can adjust the layer ordering by dragging the order of layers in the list. To toggle visibility you can either use the checkboxes or double click a layer name.

Tools panel
~~~~~~~~~~~

The :guilabel:`Tools panel` contains a number of controls, including access to adding a new feature.  The following tables outlines these buttons and associated functionality.

    .. list-table::
       :widths: 5 20 75 

       * - **Button**
         - **Name**
         - **Description**
       * - .. image:: /images/map_save.png 
         - Bookmark
         - Create a permalink for a GeoEditor loaded with the layers and extent you are currently looking at.
       * - .. image:: /images/pan.png 
         - Pan
         - Enabled by default, use for dragging the map with the mouse and zooming by Shift-Click-Dragging an extent rectangle.
       * - .. image:: /images/map_edit.png 
         - Edit
         - Starts an editing session for an existing feature.
       * - .. image:: /images/pencil_add.png 
         - Add
         - Activates the feature drawing tool. Once selected, you can begin drafting features. 
       * - .. image:: /images/measure.png 
         - Measure
         - Measures distance or area. To measure, click on the map, drawing a line for distance or a polygon for area measurement. Freehand measuring can be activated by pressing and holding the Shift key. When finished, double click on the map.  The total distance or area will be displayed.
       * - .. image:: /images/zoomin.png
         - Zoom In
         - Zooms in by one zoom level.
       * - .. image:: /images/zoomout.png
         - Zoom Out
         - Zooms out by one zoom level.   
       * - .. image:: /images/previousextent.png
         - Previous Extent
         - Zooms to the extent you were previously viewing.
       * - .. image:: /images/nextextent.png
         - Next extent
         - Activated after using the "Zoom to Previous Extent" button, zooms to the next most recent extent.
       * - .. image:: /images/extent.png
         - Visible extent
         - Click to view the largest possible area.

Map Window
~~~~~~~~~~

The map window displays all of the layers listed in the :guilabel:`Layers panel`.  As a preview area, the :guilabel:`Map Window` is used for selecting, modifying and searching features.   

.. figure:: images/introduction1.png
   :align: center
   :width: 600px

   *A map window of medford layers*


Query Panel
~~~~~~~~~~~

The :guilabel:`Query Panel` provides tools for analyzing and preparing features for editing.  The first 100 features that satisfy the specified query the within the current :guilabel:`Map Window` extent are displayed in tabular format.  These results can be sorted, reorganized, and activated to prepare a map for editing. 

.. figure:: images/introduction2.png
   :align: center
   :width: 600px

   *A query for Medford school fields*

 





