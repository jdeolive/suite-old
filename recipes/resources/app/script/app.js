Ext.namespace("og");

og.IFrameComponent = Ext.extend(Ext.BoxComponent, {
    
    url: "about:blank",
    
    setSrc: function(url) {
        this.el.dom.contentWindow.location.href = url;
    },
    
    onRender: function(ct, position) {
        this.el = ct.createChild({
            tag: "iframe", 
            id: "iframe-" + this.id, 
            frameborder: 0,
            width: "100%",
            height: "100%", 
            src: this.url
        });
    }
    
});

og.Recipes = Ext.extend(Ext.util.Observable, {
    
    recipeBase: null,
    
    recipeStore: null,
    
    recipeList: null,
    
    recipeFrame: null,
    
    startRecipe: null,
    
    currentRecipe: null,
    
    query: null,
        
    constructor: function(config) {
        
        this.query = {components: {
            "GeoServer": true,
            "GeoWebCache": true,
            "OpenLayers": true,
            "GeoExt": true
        }};
        this.initialConfig = config;
        Ext.apply(this, this.configFromUrl(), config);
        
        // require index in config
        var parts = this.index.split("/");
        parts.pop();
        var dir = parts.join("/");
        var loc = window.location.pathname;
        parts = loc.split("/");
        parts.pop();
        this.recipeBase = parts.join("/") + "/" + dir;
        
        this.addEvents("recipeload");
        
        og.Recipes.superclass.constructor.call(this);
        
        var queue = [
            this.initRecipeStore,
            function(done) {
                Ext.onReady(function() {
                    this.initViewport();
                    done();
                }, this)
            }
        ];
        
        this.dispatch(queue, function() {
            this.loadRecipe(this.startRecipe)            
        });

    },
    
    configFromUrl: function() {
        var config = {};
        // pull any recipe id
        var id = window.location.hash.substring(1);
        if (id) {
            config.startRecipe = id;
        }
        return config;
    },
    
    initRecipeStore: function(done) {
        this.recipeStore = new Ext.ux.data.PagingJsonStore({
            url: this.index,
            root: "recipes",
            autoLoad: {params: {start: 0, limit: 10}},
            fields: [
                "id",
                "title",
                "description",
                "components",
                "reference",
                "sourcepath",
                {name: "source", type: "boolean", defaultValue: true}
            ],
            idIndex: 0,
            listeners: {
                load: done
            }
        });
    },
    
    initRecipeList: function() {
        var loading = false;
        this.recipeList = new Ext.DataView({
            store: this.recipeStore,
            itemSelector: "div.recipe",
            overClass: "over",
            selectedClass: "selected",
            singleSelect: true,
            tpl: new Ext.XTemplate(
                '<tpl for=".">',
                    '<div class="recipe">',
                        '<h3>{title}</h3>',
                        '<p>{description}</p>',
                    '</div>',
                '</tpl>'
            ),
            listeners: {
                selectionchange: function(view, selections) {
                    var recs = view.getSelectedRecords();
                    if (recs.length && !loading) {
                        loading = true;
                        this.loadRecipe(recs[0].get("id"));
                        loading = false;
                    }
                },
                scope: this
            }
        });
          
    },
    
    initViewport: function() {

        Ext.QuickTips.init();
        this.initRecipeList();
        this.initRecipeTree();
        this.initRecipeFrame();
        this.initSourcePanel();
        this.initReferenceFrame();
        
        this.pagingBar = new Ext.PagingToolbar({
            store: this.recipeStore,
            displayInfo: false,
            pageSize: 10
        });
        
        this.viewport = new Ext.Viewport({
            layout: "border",
            defaults: {border: false},
            items: [{
                region: "north",
                xtype: "box",
                cls: "header",
                autoEl: {
                    tag: "div",
                    cls: "header",
                    html: "<h1><a class='recipe-link' title='Go to Recipe Book Home' href='#index'>&nbsp;</a></h1>"
                }
            }, {
                region: "west",
                xtype: "tabpanel",
                cls: "west",    
                border: true,
                plain: true,
                activeTab: 0,
                height: "100%",
                autoScroll: true,
                items:[
                    this.recipeTree, {
                    title: "Search",
                    layout: "fit",
                    items: [{
                        xtype: "panel",
                        border: false,
                        autoScroll: true,
                        items: [{
                            xtype: "container",
                            cls: "searchbox",
                            items: [{
                                xtype: "textfield",
                                width: "100%",
                                emptyText: "search for recipes",
                                enableKeyEvents: true,
                                listeners: {
                                    keyup: function(field) {
                                        var value = field.getValue();
                                        this.query.keywords = value;
                                        this.filterRecipes();
                                        field.focus();
                                    },
                                    scope: this
                                }
                            }, {
                                xtype: "fieldset",
                                cls: "components",
                                style: "margin-top: 0.5em;",
                                collapsible: true,
                                title: "Components",
                                collapsed: true,
                                layout: "column",
                                columns: 2,
                                defaults: {
                                    xtype: "checkbox",
                                    hideLabel: true,
                                    columnWidth: '0.5',
                                    listeners: {
                                        check: function(box, checked) {
                                            this.query.components[box.getName()] = checked;
                                            this.filterRecipes();
                                        },
                                        scope: this
                                    }
                                },
                                items: [this.createComponentCheckboxes()]
                            }]
                        }, {
                            xtype: "panel",
                            border: false,
                            items: [this.recipeList],
                            bbar: this.pagingBar,
                            listeners: {
                                render: function(cmp) {
                                    cmp.toolbars[0].refresh.hide();
                                }
                            }
                        }]
                    }]
                }]
            }, {
                region: "center",
                cls: "entry",
                height: "100%",
                layout: "fit",
                unstyled: true,
                items: [{
                    xtype: "tabpanel",
                    border: false,
                    plain: true,
                    activeTab: 0,
                    height: "100%",
                    autoScroll: true,
                    deferredRender: false,
                    items: [
                        this.recipeFrame,
                        this.sourcePanel,
                        this.referenceFrame
                    ]
                }]
            }],
            listeners: {
                afterrender: {
                    fn: function() {
                        this.configureRecipeLinks();
                    },
                    scope: this,
                    delay: 1
                }
            }
        });
        
        
        
    },
    
    initRecipeTree: function() {
        
        var selecting = false;
        var highlight = function(id) {
            var node = this.recipeTree.getNodeById(id);
            if (node) {
                node.ensureVisible();
                selecting = true;
                this.recipeTree.getSelectionModel().select(node);
                selecting = false;
            }
        };

        this.recipeTree = new Ext.tree.TreePanel({
            title: "Contents",
            border: false,
            animate: false,
            autoScroll: true,
            selModel: new Ext.tree.DefaultSelectionModel({
                listeners: {
                    selectionchange: function(model, node) {
                        if (node.leaf && !selecting) {
                            this.loadRecipe(node.id);
                        }
                    },
                    scope: this
                }
            }),
            root: {
                nodeType: "async",
                expanded: true,
                text: "Recipes"
            },
            loader: {
                dataUrl: "content/tree.json",
                listeners: {
                    load: function() {
                       // this.recipeTree.root.expand(true);
                        if (this.currentRecipe) {
                            highlight.call(this, this.currentRecipe);
                        }
                    },
                    scope: this
                }
            }
        });
        
        this.on({
            recipeload: highlight,
            scope: this
        });
        
    },
    
    createComponentCheckboxes: function() {
        var components = this.query.components;
        var checkboxes = [];
        for (var name in components) {
            checkboxes.push({
                boxLabel: name,
                name: name,
                checked: components[name]
            });
        }
        return checkboxes;
    },
    
    filterRecipes: function() {
        this.pagingBar.unbind(this.recipeStore);
        var keywords = this.query.keywords;
        keywords = keywords && keywords.trim().split(/\s+/).remove("");
        var components = this.query.components;
        this.recipeStore.filterBy(function(r) {
            var hasComponent = false;
            for (var name in components) {
                if (components[name]) {
                    if (r.get("components").indexOf(name) >= 0) {
                        hasComponent = true;
                    }
                }
            }
            var len = keywords && keywords.length;
            var word, title, description, hasKeyword = !len;
            for (var i=0; i<len; ++i) {
                word = keywords[i].toLowerCase();
                if (word) {
                    title = r.get("title").toLowerCase();
                    description = r.get("description").toLowerCase();
                    if (title.indexOf(word) >= 0 || description.indexOf(word) >= 0) {
                        hasKeyword = true;
                    }                    
                }
            }
            return hasComponent && hasKeyword;
        }, this);
        this.pagingBar.bind(this.recipeStore);
        this.pagingBar.changePage(1);
        this.selectRecipe(this.currentRecipe);
    },
    
    initRecipeFrame: function() {
        this.recipeFrame = new og.IFrameComponent({
            title: "Demo",
            focusOnLoad: true,
            listeners: {
                domready: function() {
                    var doc = this.recipeFrame.getFrameDocument();
                    this.configureRecipeLinks(doc);
                },
                scope: this                
            }
        });
        
    },
    
    initSourcePanel: function() {
        this.sourcePanel = new Ext.Panel({
            title: "Source",
            height: "100%",
            autoScroll: true
        });
    },
    
    initReferenceFrame: function() {
        this.referenceFrame = new og.IFrameComponent({
            title: "Documentation",
            focusOnLoad: true
        });
    },
    
    configureRecipeLinks: function(root) {
        var links = Ext.select("a.recipe-link", false, root);
        links.on({
            click: function(evt, link) {
                var id = link.hash.substring(1);
                this.loadRecipe(id);
                evt.preventDefault();
            },
            scope: this
        });
    },
    
    configureCodeBlocks: function(doc) {
        var blocks = Ext.select("div.code", false, doc);
        blocks.each(function(block) {            
            var id = block.dom.title;
            var panel = new Ext.Panel({
                cls: "code-panel",
                applyTo: block,
                collapsible: true,
                titleCollapse: true,
                collapsed: true,
                title: id
            });
            var script = doc.getElementById(id);
            this.fetchCodeSample(script, function(str) {
                panel.add({
                    xtype: "box",
                    autoEl: {
                        tag: "pre",
                        html: str
                    }
                });
                panel.doLayout();
            })
        }, this);
    },
    
    getRecipeUrl: function(id) {
        return this.recipeBase + "/" + id + ".html";
    },
    
    getSourceUrl: function(id) {
        var rec = this.recipeStore.getById(id);
        if (rec.get("sourcepath") !== "") {
            return this.recipeBase + "/" + rec.get("sourcepath");            
        } else {
            return this.recipeBase + "/" + id + ".html";
        }
    },
    
    getReferenceUrl: function(id) {
        var rec = this.recipeStore.getById(id);
        return this.recipeBase + "/" + rec.get("reference") + ".html";
    },

    selectRecipe: function(id) {
        var index = this.recipeStore.findExact("id", id);
        if (index >= 0) {
            var selected = this.recipeList.getSelectedIndexes();
            if (selected.indexOf(index) === -1) {
                this.recipeList.select(index);                
            }
        } else {
            this.recipeList.clearSelections();
        }
    },
        
    loadRecipe: function(id) {
        window.location.hash = "#" + id;
        if (id !== this.currentRecipe) {
            this.currentRecipe = id;
            this.sourcePanel.removeAll();
            this.recipeFrame.ownerCt.activate(this.recipeFrame);
            this.recipeFrame.setSrc(this.getRecipeUrl(id));
            var rec = this.recipeStore.getById(id);
            if (rec && rec.get("source")) {
                this.loadSource(id);
                this.sourcePanel.ownerCt.unhideTabStripItem(this.sourcePanel);
            } else {
                this.sourcePanel.ownerCt.hideTabStripItem(this.sourcePanel);
            }
            if (rec && rec.get("reference")) {
                this.referenceFrame.ownerCt.unhideTabStripItem(this.referenceFrame);
                this.referenceFrame.setSrc(this.getReferenceUrl(id));
            } else {
                this.referenceFrame.setSrc("about:blank");
                this.referenceFrame.ownerCt.hideTabStripItem(this.referenceFrame);
            }
        }
        this.fireEvent("recipeload", id);
        this.selectRecipe(id);
    },
    
    loadSource: function(id) {
        var loadedId;
        this.sourcePanel.purgeListeners();
        this.sourcePanel.on({
            activate: function(panel) {
                if (id !== loadedId) {
                    Ext.Ajax.request({
                        url: this.getSourceUrl(id),
                        disableCaching: false,
                        success: function(request) {
                            
                            // highlight.js requires div > pre > code
                            var div = document.createElement("div");
                            Ext.DomHelper.append(div, {
                                tag: "pre",
                                cls: "brush: js; html-script: true",
                                html: Ext.util.Format.htmlEncode(request.responseText)
                            });
                            SyntaxHighlighter.highlight({}, div.firstChild);
                            
                            panel.removeAll();
                            panel.add({
                                xtype: "box",
                                height: "100%",
                                autoEl: {
                                    tag: "div",
                                    html: div.innerHTML
                                }
                            });
                            panel.doLayout();
                            loadedId = id;
                        },
                        failure: function() {
                            panel.removeAll();
                            panel.add({
                                xtype: "box",
                                autoEl: {
                                    html: "Unable to load source for " + id
                                }
                            });
                            panel.doLayout();
                        },
                        scope: this
                    });
                }
            },
            scope: this
        });

    },

    dispatch: function(functions, complete, scope) {
        complete = complete || Ext.emptyFn;
        scope = scope || this;
        var requests = functions.length;
        var responses = 0;
        var storage = {};
        function respond() {
            ++responses;
            if(responses === requests) {
                complete.call(scope, storage);
            }
        }
        function trigger(index) {
            window.setTimeout(function() {
                functions[index].apply(scope, [respond, storage]);
            });
        }
        for(var i=0; i<requests; ++i) {
            trigger(i);
        }
    }

});

