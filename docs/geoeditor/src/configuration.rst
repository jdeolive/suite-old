.. _geoeditor.configuration:

Configuration
=============
GeoEditor is configured to work with your local GeoServer with default map settings. However, you can customize these options by modifying :guilabel:`GeoEditor/index.html`. 

WMS Configuration
-----------------
WMS is standard protocol for requesting geospatial data dynamically rendered as an image. The images get returned as tiles which cover the area of the map container. GeoEditor loads capabilities from a single WMS, as specified in index.html with the parameter :guilabel:`wms`.

.. code-block:: javascript

    wms: "/geoserver/wms",

Because the OpenGeo Suite GeoEditor runs on the same origin as GeoServer, our WMS value is a relative URL. For GeoEditor to load capabilities form a different host than one that serves GeoEditor, you need to specify an absolute URL for the WMS, and configure a proxy. 

.. code-block:: javascript

    proxy: "/proxy/?url=",
    
For a proxy that works with mod_python, see the following: :ref:`http://svn.opengeo.org/util/proxy/proxy.py`. 

Map Configuration
-----------------
The map, and map parameters loaded at startup can also be configured.  

.. code-block:: javascript

    map: {
        projection: "EPSG:4326",
        maxResolution: 1.40625,
        numZoomLevels: 22,
        center: [0, 0],
        zoom: 1,
        layers: [{
            name: "world",
            title: "Base Map",
            format: "image/png"
        }]
    },
    
For example, if the number of 22 zoom levels seems gratuitous, you can specify a more conservative range of 18. 

