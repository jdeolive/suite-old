.. _geoexplorer.introduction:

Introduction
============

.. note:: This section is a brief introduction to GeoExplorer.  For more detail, please see the section on :ref:`geoexplorer.using`.

#. Launch GeoExplorer.  This is typically available in your browser at ``http://localhost:8080/geoexplorer/``, although your setup may differ.

   .. figure:: images/geoexplorer.png
      :align: center
   
      *GeoExplorer*

#. Click the :guilabel:`Add Layers` button in the :ref:`geoexplorer.workspace.layerspanel` to bring up the :guilabel:`Available Layers` dialog.
    
   .. figure:: using/images/add_button.png
      :align: center
       
      *Add Layers button*
    
#. In the :guilabel:`Available Layers` dialog, select the layers to be added to your map.

   .. figure:: using/images/add_dialog.png
      :align: center
       
      *Adding layers to GeoExplorer*

#. If desired, add a new :term:`WMS` server by clicking the :guilabel:`Add A New Server` button and entering a WMS URL.

   .. note:: An example of a WMS URL is: ``http://terraservice.net/ogccapabilities.ashx?version=1.1.1&request=GetCapabilities``
    
   .. figure:: using/images/add_newserver.png
      :align: center
   
      *Adding a new WMS server*
       
#. Compose your map by ordering layers in the :ref:`geoexplorer.workspace.layerspanel`.
    
   .. figure:: images/workspace_draglayers.png
      :align: center
   
      *Ordering layers*
       
#. Launch the :ref:`geoexplorer.using.export` tool to generate a map application and the HTML code that you can embed into a web page.

   .. figure:: using/images/export_tools.png
      :align: center

      *Selecting the map tools*

   .. figure:: using/images/export_html.png
      :align: center

      *Exporting a map*

#. Paste the HTML code into your web page.

   .. figure:: using/images/export_embed.png
      :align: center

      *Embedded map inside a web page*