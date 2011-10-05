package org.opengeo.data.importer.web;

import static org.geoserver.ows.util.ResponseUtils.urlEncode;

import org.apache.wicket.Component;
import org.apache.wicket.PageParameters;
import org.apache.wicket.ResourceReference;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.form.AjaxSubmitLink;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.link.ExternalLink;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IChainingModel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.model.StringResourceModel;
import org.geoserver.catalog.LayerInfo;
import org.geoserver.web.GeoServerApplication;
import org.geoserver.web.demo.PreviewLayer;
import org.geoserver.web.wicket.CRSPanel;
import org.geoserver.web.wicket.GeoServerDataProvider.Property;
import org.geoserver.web.wicket.GeoServerDialog;
import org.geoserver.web.wicket.GeoServerDialog.DialogDelegate;
import org.geoserver.web.wicket.GeoServerTablePanel;
import org.geoserver.web.wicket.Icon;
import org.geoserver.web.wicket.SRSToCRSModel;
import org.geoserver.web.wicket.SimpleAjaxLink;
import org.opengeo.data.importer.ImportItem;
import org.opengeo.data.importer.ImportItem.State;

public class ImportItemTable extends GeoServerTablePanel<ImportItem> {

    GeoServerDialog dialog;
    
    public ImportItemTable(String id, ImportItemProvider dataProvider, boolean selectable) {
        super(id, dataProvider, selectable);
        add(dialog = new GeoServerDialog("dialog")); 
    }

    @Override
    protected Component getComponentForProperty(String id, final IModel itemModel, Property property) {
        //ImportItem item = (ImportItem) itemModel.getObject();
        
        if (property == ImportItemProvider.NAME) {
              return new LayerLinkPanel(id, itemModel);
            //PageParameters pageParams = new PageParameters();
            //return new SimpleBookmarkableLink(id, ResourceConfigurationPage.class, 
//                    property.getModel(itemModel), pageParams);
            //return new Label(id, property.getModel(itemModel));
            /*if (item.getS() == LayerStatus.COMPLETED) {
                //link to the layer configuration page
                LayerInfo layer = layerSummary.getLayer();
                PageParameters pageParams = new PageParameters();
                pageParams.put(ResourceConfigurationPage.WORKSPACE, 
                    layer.getResource().getStore().getWorkspace().getName());
                pageParams.put(ResourceConfigurationPage.NAME, layer.getResource().getName());
                
                return new SimpleBookmarkableLink(id, ResourceConfigurationPage.class, 
                    property.getModel(itemModel), pageParams);
            }
            else {
                return new Label(id, property.getModel(itemModel));
            }*/
        }
//        if (property == ImportItemProvider.FORMAT) {
//            return new Label(id, new PropertyModel(property.getModel(itemModel), "name"));
//        }
        if (property == ImportItemProvider.STATUS) {
            return new Icon(id, new StatusIconModel(property.getModel(itemModel)), 
                new StatusDescriptionModel(property.getModel(itemModel)));
        }
        if (property == ImportItemProvider.ACTION) {
            ImportItem.State state = (State) property.getModel(itemModel).getObject();
            switch(state) {
                case COMPLETE:
                    //link to map preview
                    return new LayerPreviewPanel(id, itemModel);
                case NO_CRS:
                    //provide link to choose crs
                    return new NoCRSPanel(id, itemModel);
                    //return createFixCRSLink(id, itemModel);
                case READY:
                    //return advanced option link
                    return new AdvancedOptionPanel(id, itemModel);
                default:
                    return new WebMarkupContainer(id);
            }
            
//            if (item.getState() == ImportItem.State.COMPLETE) {
//                //link to map preview
//                return new LayerPreviewPanel(id, itemModel);
//            }
//            else {
//                //link to configuration
//                return new Link(id) {
//                    @Override
//                    public void onClick() {
//                        setResponsePage(new ResourceConfigurationPage(item.getLayer(), true));
//                    }
//                };
//                return new SimpleAjaxLink(id, new Model("Fix...")) {
//                    
//                    @Override
//                    protected void onClick(AjaxRequestTarget target) {
//                        dialog.showOkCancel(target, new DialogDelegate() {
//                            
//                            @Override
//                            protected boolean onSubmit(AjaxRequestTarget target, Component contents) {
//                                return true;
//                            }
//                            
//                            @Override
//                            protected Component getContents(String id) {
//                                return new NoCRSPanel(id, new PropertyModel(layerSummary, "crs"));
//                            }
//                        });
//                    }
//                };

//            if (layerSummary.getStatus() == LayerStatus.NO_FORMAT) {
//                return new FormatPanel(id, new PropertyModel(layerSummary, "format")) {
//                    @Override
//                    protected void onApply(AjaxRequestTarget target) {
//                        target.addComponent(ImportItemTable.this);
//                    }
//                };
//            }
//            if (layerSummary.getStatus() == LayerStatus.NO_CRS) {
//                return new SimpleAjaxLink(id, new Model("Fix...")) {
//                    
//                    @Override
//                    protected void onClick(AjaxRequestTarget target) {
//                        dialog.showOkCancel(target, new DialogDelegate() {
//                            
//                            @Override
//                            protected boolean onSubmit(AjaxRequestTarget target, Component contents) {
//                                return true;
//                            }
//                            
//                            @Override
//                            protected Component getContents(String id) {
//                                return new NoCRSPanel(id, new PropertyModel(layerSummary, "crs"));
//                            }
//                        });
//                    }
//                };
//            }
//            
//            if (layerSummary.getStatus() == LayerStatus.COMPLETED) {
//                return new LayerPreviewPanel(id, layerSummary);
//            }
//            
//            return new WebMarkupContainer(id);
        }
        return null;
    }

    SimpleAjaxLink createFixCRSLink(String id, final IModel<ImportItem> itemModel) {
        return new SimpleAjaxLink(id, new Model("Fix...")) {
            @Override
            protected void onClick(AjaxRequestTarget target) {
                dialog.showOkCancel(target, new DialogDelegate() {

                    @Override
                    protected boolean onSubmit(AjaxRequestTarget target, Component contents) {
                        ImporterWebUtils.importer().changed(itemModel.getObject());
                        target.addComponent(ImportItemTable.this);
                        return true;
                    }

                    @Override
                    protected Component getContents(String id) {
                        return new NoCRSPanel(id, 
                            new SRSToCRSModel(new PropertyModel(itemModel, "layer.resource.sRS")));
                    }
                });
            }
        };
    }

    static abstract class StatusModel<T> implements IChainingModel<T> {
        
        IModel chained;

        protected StatusModel(IModel model) {
            this.chained = model;
        }
        
        public void setObject(T object) {
        }

        public void detach() {
            chained.detach();
        }

        public void setChainedModel(IModel<?> model) {
            this.chained = model;
        }

        public IModel<?> getChainedModel() {
            return chained;
        }
    }
    static class StatusIconModel extends StatusModel<ResourceReference> {

        StatusIconModel(IModel model) {
            super(model);
        }
        
        public ResourceReference getObject() {
            ImportItem.State state = (ImportItem.State) chained.getObject();
            switch(state) {
            case READY:
                return new ResourceReference(GeoServerApplication.class, "img/icons/silk/bullet_go.png");
            case RUNNING:
                return new ResourceReference(ImportItemTable.class, "indicator.gif");
            case COMPLETE:
                return new ResourceReference(GeoServerApplication.class, "img/icons/silk/accept.png");
            case NO_BOUNDS:
            case NO_CRS:
            //case NO_FORMAT:
                return new ResourceReference(GeoServerApplication.class, "img/icons/silk/error.png");
            case ERROR:
                return new ResourceReference(GeoServerApplication.class, "img/icons/silk/delete.png");
            }
            return null;
        }
    }
    class StatusDescriptionModel extends StatusModel<String> {

        StatusDescriptionModel(IModel model) {
            super(model);
        }

        public String getObject() {
            ImportItem.State state = (ImportItem.State) chained.getObject();
            return new StringResourceModel(
                state.name().toLowerCase(), ImportItemTable.this, null).getString();
        }
    }

//    class FormatDelegate extends DialogDelegate {
//
//        LayerSummary layer;
//        
//        public FormatDelegate(LayerSummary layer) {
//            this.layer = layer;
//        }
//        
//        @Override
//        protected Component getContents(String id) {
//            // TODO Auto-generated method stub
//            return null;
//        }
//
//        @Override
//        protected boolean onSubmit(AjaxRequestTarget target, Component contents) {
//
//        }
//    }
    
//    static class FormatPanel extends Panel {
//
//        public FormatPanel(String id, IModel model) {
//            super(id);
//            add(new FormatDropDownChoice("format", model).add(
//                new AjaxFormComponentUpdatingBehavior("onchange") {
//                    @Override
//                    protected void onUpdate(AjaxRequestTarget target) {}
//                }));
//            add(new AjaxLink("apply") {
//                @Override
//                public void onClick(AjaxRequestTarget target) {
//                    onApply(target);
//                }
//            });
//        }
//        
//        protected void onApply(AjaxRequestTarget target) {
//        }
//    }
//    
//    static class FormatDropDownChoice extends DropDownChoice<LayerFormat> {
//
//        public FormatDropDownChoice(String id, IModel model) {
//            super(id, model, new FormatsModel());
//            setChoiceRenderer(new IChoiceRenderer<LayerFormat>() {
//                public Object getDisplayValue(LayerFormat object) {
//                    return getIdValue(object, -1);
//                }
//
//                public String getIdValue(LayerFormat object, int index) {
//                    return object.getName();
//                }
//            });
//        }
//    }
//    
//    static class FormatsModel extends LoadableDetachableModel<List<LayerFormat>> {
//
//        @Override
//        protected List<LayerFormat> load() {
//            return LayerFormat.all();
//        }
//        
//    }
//
    class NoCRSPanel extends Panel {

        public NoCRSPanel(String id, final IModel<ImportItem> model) {
            super(id, model);

            Form form = new Form("form");
            add(form);

            form.add(new CRSPanel("crs", 
                new SRSToCRSModel(new PropertyModel(model, "layer.resource.srs"))));

            form.add(new AjaxSubmitLink("apply") {
                @Override
                protected void onSubmit(AjaxRequestTarget target, Form<?> form) {
                    ImporterWebUtils.importer().changed(model.getObject());
                    target.addComponent(ImportItemTable.this);
                }
            });
        }
    }

    static class LayerLinkPanel extends Panel {
        public LayerLinkPanel(String id, final IModel<ImportItem> model) {
            super(id);
            
            add(new Link<ImportItem>("link", model) {
                @Override
                public void onClick() {
                    ImportItem item = getModelObject();

                    PageParameters pp = new PageParameters();
                    pp.put("id", item.getTask().getContext().getId());

                    setResponsePage(new LayerPage(item.getLayer(), pp) {
                        protected void onSuccessfulSave() {
                            super.onSuccessfulSave();

                            //update the item
                            ImporterWebUtils.importer().changed(model.getObject());
                        };
                    });
                }
            }.add(new Label("name", new PropertyModel(model, "layer.name"))));
        }
    }

    static class LayerPreviewPanel extends Panel {
        public LayerPreviewPanel(String id, IModel<ImportItem> model) {
            super(id);
            
            LayerInfo layer = model.getObject().getLayer();
            PreviewLayer preview = new PreviewLayer(layer);
            add(new ExternalLink("openlayers", preview.getWmsLink()+ "&format=application/openlayers"));
            add(new ExternalLink("google", "../wms/kml?layers=" + layer.getName()));
            add(new ExternalLink("styler", "/styler/index.html?layer="
                + urlEncode(layer.getResource().getStore().getWorkspace().getName() + ":" +  layer.getName())));
        }
    }

    static class AdvancedOptionPanel extends Panel {
        public AdvancedOptionPanel(String id, IModel<ImportItem> model) {
            super(id);
            
            add(new Link<ImportItem>("link", model) {
                @Override
                public void onClick() {
                    setResponsePage(new ImportItemAdvancedPage(getModel()));
                }
            });
        }
    }
}
