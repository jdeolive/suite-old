.. _workflow.edit:

Step 3: Edit Your Data
======================

.. note:: This step is optional.  If you don't wish to edit any of your existing data, you can skip to the next section, :ref:`workflow.style`.

The OpenGeo Suite contains an application called **GeoEditor** that allows for editing of geospatial data served through GeoServer.

#. To launch GeoEditor, first, make sure the OpenGeo Suite is running.  You can do this by clicking on the :guilabel:`Start` button in the :ref:`dashboard`.

#. Launch GeoEditor by clicking on the :guilabel:`GeoEditor` link.  

#. Your browser will open, and a base map will be displayed.

   .. figure:: img/geoeditor.png
      :align: center

      *GeoEditor*

#. To edit a layer, click on the green plus icon (:guilabel:`Add Layers`) on the top left of the screen (right under the :guilabel:`Layers` tab.

   .. figure:: img/geoeditor_addlayersbutton.png
      :align: center

      *Add Layers*

#. A list of all the layers served through GeoServer will be displayed.  Select a layer to view (or select more than one), click :guilabel:`Add Layers`, then  :guilabel:`Done`.

   .. figure:: img/geoeditor_selectlayers.png
      :align: center

      *Select Layers*

#. If the layer isn't immediately visible, click on the layer name in the :guilabel:`Layers` panel, then right-click and select :guilabel:`Zoom to Layer Extent`.

   .. figure:: img/geoeditor_zoomtolayerextent.png
      :align: center

      *Zoom to Layer Extent*

#. To select the specific layer to be edited, select that layer name in the :guilabel:`Layer` drop down box in the :guilabel:`Feature Query` panel at the bottom left of the browser window.

   .. warning:: Just selecting the layer in the :guilabel:`Layers` panel is not sufficient.

   .. figure:: img/geoeditor_layersadded.png
      :align: center

      *Layers added, with one ready to be edited*


Edit attribute data
-------------------

#. To edit attribute data for the selected layer, first click on the guilabel:`Get Feature Info` button (the blue circle with the white 'i') in the menu bar.  

   .. figure:: img/geoeditor_getfeatureinfobutton.png
      :align: center

      *Get Feature Info*

#. Click on the :guilabel:`Query` button at the bottom of the screen.

   .. figure:: img/geoeditor_query.png
      :align: center

      *Viewing a table of attributes*

#. Click on a feature.  A popup will display, showing the attributes of this feature.  Click the :guilabel:`Edit` button and then click on any of the fields to change the value.

   .. figure:: img/geoeditor_editattribute.png
      :align: center

      *Editing attributes*

#. When done, click :guilabel:`Save`.


Create a feature
----------------

#. To create a new feature in the selected layer, click on the :guilabel:`Create a new feature` icon in the menubar the top of the screen.  Click anywhere in the main window to start drawing the feature.

   .. figure:: img/geoeditor_createnewfeaturebutton.png
      :align: center

      *Create a New Feature*

#. CLick to add points to the feature.  Double-click when done.  (For point data, this will be unecessary.)  Afterwards, a popup will display, where attribute data can be entered.  Enter any attribute data, then click :guilabel:`Save`.

   .. figure:: img/geoeditor_createnewfeature.png
      :align: center

      *Editing the attributes of a new feature*

Delete a feature
----------------

#. To delete a feature, click on the :guilabel:`Get Feature Info` button (the blue circle with the white 'i') in the menu bar.

   .. figure:: img/geoeditor_getfeatureinfobutton.png
      :align: center

      *Get Feature Info*

#. Click on a feature.  A popup will display, showing the attributes of this feature.  Click the :guilabel:`Delete` button.

   .. figure:: img/geoeditor_deletefeature.png
      :align: center

      *Deleting a feature*

#. A confirmation popup will display.  Click :guilabel:`Yes` to confirm deletion.

   .. figure:: img/geoeditor_deleteconfirmation.png
      :align: center

      *Confirmation for deleting a feature*

.. note:: For more information on GeoEditor, please see the GeoEditor Documentation. You can access this by clicking the :guilabel:`GeoEditor Documentation` link in the :ref:`dashboard`.