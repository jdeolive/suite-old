.. _geoexplorer.glossary:

Glossary
========

.. glossary::

   GetCapabilities
     WMS request that returns a capabilities document, a list of all layers and functions supported by the WMS server.  GeoExplorer reads the capabilities document of a server in order to determine the available layers.

   GetFeatureInfo
     WMS request that returns a list of attributes and values for the data at a given location.

   GetLegendGraphic
     WMS request that returns a graphic rendered in the style of a given layer.

   GeoExt
     A JavaScript toolkit for creating rich web mapping applications.  GeoExt is built using OpenLayers and ExtJS.  Learn more at `geoext.org <http://geoext.org>`_.

   GXP
     A repository for high level application components useful for assembling applications for viewing, editing, styling, and configuring data with GeoServer. GXP components are built with GeoExt.

   OGC
     The `Open Geospatial Consortium <http://www.opengeospatial.org/>`_ (OGC) is a standards organization that develops specifications for geospatial services.

   SLD
     The `Styled Layer Descriptor <http://www.opengeospatial.org/standards/ogc>`_ (SLD) specification from the OGC is an XML-based standard for the symbolization and coloring (display) of geographic features through WMS.  SLD is the style language used by GeoServer. 

   WMS
     The `Web Map Service <http://www.opengeospatial.org/standards/wms>`_ (WMS) specification from the OGC defines an interface for requesting rendered map images across the web.  WMS can refer either to the protocol itself or a server that understands that protocol.

   WMS-C
     The `Web Map Service - Caching <http://wiki.osgeo.org/wiki/WMS_Tile_Caching>`_ (WMS-C) proposal is a WMS optimized for the delivery of saved/cached images. 

   WFS-T
     The `Web Feature Service - Transactional <http://www.opengeospatial.org/standards/wfs>`_ (WFS-T) is an OGC standard that describes a method for the editing of geographic features.