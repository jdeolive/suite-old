    map = new OpenLayers.Map({
        div: "${markupId}",
        projection: new OpenLayers.Projection("EPSG:900913"),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        units: "m",
        numZoomLevels: 18,
        maxResolution: 156543.0339,
        maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34)
    });

        
    var osm = new OpenLayers.Layer.OSM();
    //var gmap = new OpenLayers.Layer.Google("Google Streets", {visibility: false});
    
    var wms = new OpenLayers.Layer.WMS(
        "Requests", "../wms",
        {'layers': 'analytics:requests_agg', 'format':'image/png', 'transparent':true},
        {
           // 'opacity': 0.4, visibility: false,
            'isBaseLayer': false
        }
    );
    
    //map.addLayers([osm]);
    map.addLayers([osm, wms]);
    map.addControl(new OpenLayers.Control.LayerSwitcher());
    map.zoomToMaxExtent();
    //map.zoomIn();
    