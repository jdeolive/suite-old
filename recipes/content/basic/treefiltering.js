// the `panel` and `tree` variables are declared here for easy debugging
var panel, tree;

Ext.onReady(function() {

    panel = new GeoExt.MapPanel({
        title: "MapPanel",
        renderTo: "map-id",
        layers: [
            new OpenLayers.Layer.WMS(
                "Transportation",
                "http://maps.opengeo.org/geowebcache/service/wms",
                {layers: "openstreetmap"}
            ),
            new OpenLayers.Layer.WMS(
                "Global Imagery",
                "http://maps.opengeo.org/geowebcache/service/wms",
                {layers: "bluemarble"},
                {visibility: false}
            ),
            new OpenLayers.Layer.WMS(
                "State Boundaries",
                "http://maps.opengeo.org/geowebcache/service/wms",
                {layers: "topp:states", format: "image/png"}
            )
        ],
        center: [-120, 48],
        zoom: 5
    });
    
    tree = new Ext.tree.TreePanel({
        renderTo: "tree-id",
        border: false,
        enableDD: true,
        root: new GeoExt.tree.LayerContainer({
            text: "State Boundaries",
            layerStore: panel.layers,
            leaf: false,
            expanded: true,
            loader: {
                filter: function(record) {
                    return record.get("layer").name.indexOf("State Boundaries") !== -1
                }
            }
            
        })
    });

});