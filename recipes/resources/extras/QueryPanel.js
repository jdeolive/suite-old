/**
 * Copyright (c) 2009 The Open Planning Project
 */

/**
 * @include widgets/FilterBuilder.js
 */

/** api: (define)
 *  module = gxp
 *  class = QueryPanel
 *  base_link = `Ext.Panel <http://extjs.com/deploy/dev/docs/?class=Ext.Panel>`_
 */
Ext.namespace("gxp");

/** api: constructor
 *  .. class:: QueryPanel(config)
 *   
 *      Create a panel for assembling and issuing feature requests.
 */
gxp.QueryPanel = Ext.extend(Ext.Panel, {

    /** api: config[layerStore]
     *  ``GeoExt.data.WFSCapabilitiesStore``
     *  A store with records representing each WFS layer to be queried.
     */
    
    /** api: config[layout]
     *  ``String``
     *  Defaults to "form."
     */
    layout: "form",
    
    /** private: property[selectedLayer]
     *  ``Ext.data.Record``
     *  The currently selected record in the layers combo.
     */
    selectedLayer: null,
    
    /** private: property[featureStore]
     *  ``GeoExt.data.FeatureStore``
     *  After a query has been issued, this will be a store with records based
     *  on the return from the query.
     */
    featureStore: null,
    
    /** api: property[attributeStore]
     *  ``GeoExt.data.AttributeStore``
     *  The attributes associated with the currently selected layer.
     */
    attributeStore: null,
    
    /** api: property[symbolizerType]
     *  ``String`` (Point|Line|Polygon) The symbolizer type
     *  of features of the selected layer. If the layer has multiple geometry
     *  fields, the type of the first geometry field will be returned.
     */
    symbolizerType: null,

    /** private: property[geometryName]
     *  ``String``
     *  Name of the first geometry attribute found when the attributes store
     *  loads.
     */
    geometryName: null,
    
    /** private: method[initComponent]
     */
    initComponent: function() {
        
        this.addEvents(
            
            /** api: events[ready]
             *  Fires when the panel is ready to issue queries (after the
             *  internal attribute store has loaded).
             *
             *  Listener arguments:
             *  * panel - :class:`gxp.QueryPanel` This query panel.
             *  * store - ``GeoExt.data.FeatureStore`` The feature store.
             */
            "ready",

            /** api: events[beforelayerchange]
             *  Fires before a new layer is selected.  Return false to stop the
             *  layer selection from changing.
             *
             *  Listener arguments:
             *  * panel - :class:`gxp.QueryPanel` This query panel.
             *  * record - ``Ext.data.Record`` Record representing the newly
             *      selected layer.
             */
            "beforelayerchange",

            /** api: events[layerchange]
             *  Fires when a new layer is selected, as soon as this panel's
             *  ``attributesStore`` and ``symbolizerType`` attributes are set.
             *
             *  Listener arguments:
             *  * panel - :class:`gxp.QueryPanel` This query panel.
             *  * record - ``Ext.data.Record`` Record representing the selected
             *      layer.
             */
            "layerchange",

            /** api: events[beforequery]
             *  Fires before a query for features is issued.  If any listener
             *  returns false, the query will not be issued.
             *
             *  Listener arguments:
             *  * panel - :class:`gxp.QueryPanel` This query panel.
             */
            "beforequery",

            /** api: events[query]
             *  Fires when a query for features is issued.
             *
             *  Listener arguments:
             *  * panel - :class:`gxp.QueryPanel` This query panel.
             *  * store - ``GeoExt.data.FeatureStore`` The feature store.
             */
            "query",

            /** api: events[storeload]
             *  Fires when the feature store loads.
             *
             *  Listener arguments:
             *  * panel - :class:`gxp.QueryPanel` This query panel.
             *  * store - ``GeoExt.data.FeatureStore`` The feature store.
             *  * records - ``Array(Ext.data.Record)`` The records that were
             *      loaded.
             *  * options - ``Object`` The loading options that were specified.
             */
            "storeload"

        );        
        
        this.createFilterBuilder(this.layerStore.getAt(0));
        
        this.items = [{
            xtype: "combo",
            name: "layer",
            fieldLabel: "Layer",
            store: this.layerStore,
            value: this.layerStore.getAt(0).get("name"),
            displayField: "title",
            valueField: "name",
            mode: "local",
            allowBlank: true,
            editable: false,
            triggerAction: "all",
            listeners: {
                beforeselect: function(combo, record, index) {
                    return this.fireEvent("beforelayerchange", this, record);
                },
                select: function(combo, record, index) {
                    this.createFilterBuilder(record);
                },
                scope: this
            }
        }, this.filterBuilder];
        
        gxp.QueryPanel.superclass.initComponent.apply(this, arguments);

    },
    
    /** private: method[createFilterBuilder]
     *  :param record: ``Ext.data.Record``  A record representing the feature
     *      type.
     *  
     *  Remove any existing filter builder and create a new one.  This method
     *  also sets the currently selected layer and stores the name for the
     *  first geometry attribute found when the attribute store loads.
     */
    createFilterBuilder: function(record) {
        this.selectedLayer = record;
        var owner = this.filterBuilder && this.filterBuilder.ownerCt;
        if (owner) {
            owner.remove(this.filterBuilder, true);
        }

        var protocol = record.get("layer").protocol;
        this.attributeStore = new GeoExt.data.AttributeStore({
            url: Ext.urlAppend(protocol.url, Ext.urlEncode({
                "VERSION": protocol.version,
                "REQUEST": "DescribeFeatureType",
                "TYPENAME": record.get("name")
            })),
            listeners: {
                load: function(store) {
                    this.geometryName = null;
                    store.filterBy(function(r) {
                        // TODO: To be more generic, we would look for GeometryPropertyType as well.
                        var match = /gml:((Multi)?(Point|Line|Polygon|Curve|Surface)).*/.exec(r.get("type"));
                        if (match && !this.geometryName) {
                            this.geometryName = r.get("name");
                            this.symbolizerType = match[1].replace("Multi", "").replace("Curve",
                                    "Line").replace("Surface", "Polygon");
                            this.fireEvent("layerchange", this, record);
                        }
                        return !match;
                    }, this);
                    this.createFeatureStore();
                },
                scope: this
            },
            autoLoad: true
        });

        this.filterBuilder = new gxp.FilterBuilder({
            attributes: this.attributeStore,
            allowGroups: false,
            anchor: "-50px"
        });
        
        if(owner) {
            owner.add(this.filterBuilder);
            owner.doLayout();
        }
        
    },
    
    /** api: method[getFilter]
     *  Get the filter representing the conditions in the panel.  Returns false
     *  if neither spatial nor attribute query is checked.
     */
    getFilter: function() {
        return this.filterBuilder.getFilter();
    },
    
    /** private: method[getFieldType]
     *  :param attrType: ``String`` Attribute type.
     *  :returns: ``String`` Field type
     *
     *  Given a feature attribute type, return an Ext field type if possible.
     *  Note that there are many unhandled xsd types here.
     *  
     *  TODO: this should go elsewhere (AttributeReader)
     */
    getFieldType: function(attrType) {
        return ({
            "xsd:boolean": "boolean",
            "xsd:int": "int",
            "xsd:integer": "int",
            "xsd:short": "int",
            "xsd:long": "int",
            "xsd:date": "date",
            "xsd:string": "string",
            "xsd:float": "float",
            "xsd:double": "float"
        })[attrType];
    },
    
    /** private: method[createFeatureStore]
     *  Create the feature store for the selected layer.  Queries cannot be
     *  issued until this store has been created.  This method is called
     *  when the required attribute store loads.
     */
    createFeatureStore: function() {
        var fields = [];
        this.attributeStore.each(function(record) {
            fields.push({
                name: record.get("name"),
                type: this.getFieldType(record.get("type"))
            });
        }, this);
        
        var layer = this.selectedLayer;
        var protocol = layer.get("layer").protocol;
        this.featureStore = new GeoExt.data.FeatureStore({
            proxy: new GeoExt.data.ProtocolProxy({
                protocol: protocol
            }),
            listeners: {
                load: function(store, records, options) {
                    this.fireEvent("storeload", this, store, records, options);
                },
                scope: this
            }
        });
        this.fireEvent("ready", this, this.featureStore);
    },
    
    /** api: method[query]
     *  Issue a request for features.  Should not be called until the "ready"
     *  event has fired.  If called before ready, no query will be issued.
     */
    query: function() {
        if (this.featureStore) {
            if (this.fireEvent("beforequery", this) !== false) {
                var protocol = this.featureStore.proxy.protocol;
                protocol.defaultFilter = this.getFilter();
                this.featureStore.load();
                this.fireEvent("query", this, this.featureStore);
            }
        }
    },

    /** private: method[beforeDestroy]
     *  Private method called during the destroy sequence.
     */
    beforeDestroy: function() {
        if (this.map && this.map.events) {
            this.map.events.un({
                moveend: this.updateMapExtent,
                scope: this
            });
        }
        gxp.QueryPanel.superclass.beforeDestroy.apply(this, arguments);
    }

});

/** api: xtype = gx_querypanel */
Ext.reg('gx_querypanel', gxp.QueryPanel); 