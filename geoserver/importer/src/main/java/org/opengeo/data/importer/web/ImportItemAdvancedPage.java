package org.opengeo.data.importer.web;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.apache.wicket.PageParameters;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.form.AjaxFormComponentUpdatingBehavior;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.ajax.markup.html.form.AjaxButton;
import org.apache.wicket.ajax.markup.html.form.AjaxSubmitLink;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.form.CheckBox;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.geoserver.catalog.AttributeTypeInfo;
import org.geoserver.catalog.FeatureTypeInfo;
import org.geoserver.web.GeoServerSecuredPage;
import org.geoserver.web.wicket.CRSPanel;
import org.opengeo.data.importer.ImportItem;
import org.opengeo.data.importer.transform.AttributeRemapTransform;
import org.opengeo.data.importer.transform.DateFormatTransform;
import org.opengeo.data.importer.transform.NumberFormatTransform;
import org.opengeo.data.importer.transform.ReprojectTransform;
import org.opengeo.data.importer.transform.TransformChain;

import com.ibm.icu.text.DateFormat;

public class ImportItemAdvancedPage extends GeoServerSecuredPage {

    CheckBox reprojectCheckBox;
    ReprojectionPanel reprojectPanel;
    AttributeRemappingPanel remapPanel;
    
    public ImportItemAdvancedPage(final IModel<ImportItem> model) {
        ImportItem item = model.getObject();
        //item.getTransform().get

        Form form = new Form("form");
        add(form);

        ReprojectTransform reprojectTx =
            (ReprojectTransform) item.getTransform().get(ReprojectTransform.class);

        reprojectCheckBox = new CheckBox("enableReprojection", new Model(reprojectTx != null));
        reprojectCheckBox.add(new AjaxFormComponentUpdatingBehavior("onclick") {
            @Override
            protected void onUpdate(AjaxRequestTarget target) {
                reprojectPanel.setEnabled(reprojectCheckBox.getModelObject());
                target.addComponent(reprojectPanel);
            }
        });
        form.add(reprojectCheckBox);

        if (reprojectTx == null) {
            reprojectTx = new ReprojectTransform(null);
            reprojectTx.setSource(item.getLayer().getResource().getNativeCRS());
        }

        reprojectPanel = new ReprojectionPanel("reprojection", reprojectTx);
        reprojectPanel.setOutputMarkupId(true);
        reprojectPanel.setEnabled(false);
        form.add(reprojectPanel);

        remapPanel = new AttributeRemappingPanel("remapping", model); 
        form.add(remapPanel);
        
        form.add(new AjaxSubmitLink("save") {
            @Override
            protected void onSubmit(AjaxRequestTarget target, Form<?> form) {
                ImportItem item = model.getObject();
                TransformChain txChain = item.getTransform();

                //reprojection
                txChain.removeAll(ReprojectTransform.class);

                if (reprojectCheckBox.getModelObject()) {
                    txChain.add(reprojectPanel.getTransform());
                }

                //remaps
                txChain.removeAll(AttributeRemapTransform.class);
                txChain.getTransforms().addAll(remapPanel.remaps);

                ImporterWebUtils.importer().changed(item);

                PageParameters pp = new PageParameters("id="+item.getTask().getContext().getId());
                setResponsePage(ImportPage.class, pp);
            }
        });
        form.add(new AjaxLink("cancel") {
            @Override
            public void onClick(AjaxRequestTarget target) {
                ImportItem item = model.getObject();
                PageParameters pp = new PageParameters("id="+item.getTask().getContext().getId());
                setResponsePage(ImportPage.class, pp);
            }
        });
    }


    static class ReprojectionPanel extends Panel {

        ReprojectTransform transform;

        public ReprojectionPanel(String id, ReprojectTransform transform) {
            super(id);

            this.transform = transform;

            add(new CRSPanel("from", new PropertyModel(transform, "source")));
            add(new CRSPanel("to", new PropertyModel(transform, "target")));
        }

        public ReprojectTransform getTransform() {
            return transform;
        }
    }

    static class AttributeRemappingPanel extends Panel {

        List<AttributeRemapTransform> remaps;
        ListView<AttributeRemapTransform> remapList; 
        
        public AttributeRemappingPanel(String id, IModel<ImportItem> itemModel) {
            super(id, itemModel);
            setOutputMarkupId(true);

            FeatureTypeInfo featureType =
                (FeatureTypeInfo) itemModel.getObject().getLayer().getResource();
            final List atts = new ArrayList();
            for (AttributeTypeInfo at : featureType.getAttributes()) {
                atts.add(at.getName());
            }
            
            final List<Class> types = (List) Arrays.asList(Integer.class, Double.class, Date.class);

            final WebMarkupContainer remapContainer = new WebMarkupContainer("remapsContainer");
            remapContainer.setOutputMarkupId(true);
            add(remapContainer);
            
            remaps = 
                itemModel.getObject().getTransform().getAll(AttributeRemapTransform.class);
            remapList = new ListView<AttributeRemapTransform>("remaps", remaps) {
                
                @Override
                protected void populateItem(final ListItem<AttributeRemapTransform> item) {
                    
                    final DropDownChoice<String> attChoice = new DropDownChoice<String>("att", 
                        new PropertyModel(item.getModel(), "field"), atts);
                    item.add(attChoice);

                    final DropDownChoice<Class> typeChoice = new DropDownChoice<Class>("type", 
                        new PropertyModel(item.getModel(), "type"), types, new ChoiceRenderer<Class>() {

                        public Object getDisplayValue(Class object) {
                            return object.getSimpleName();
                        }
                    });
                    item.add(typeChoice);

                    final TextField<String> dateFormatTextField = new TextField<String>("dateFormat", new Model());
                    dateFormatTextField.setOutputMarkupId(true);
                    item.add(dateFormatTextField);

                    typeChoice.add(new AjaxFormComponentUpdatingBehavior("onchange") {
                        @Override
                        protected void onUpdate(AjaxRequestTarget target) {
                            dateFormatTextField.setEnabled(
                                Date.class.equals(typeChoice.getModelObject()));
                            target.addComponent(dateFormatTextField);
                        }
                    });
                    //dateFormatTextField.setVisible(false);

                    item.add(new AjaxButton("apply") {
                        @Override
                        protected void onSubmit(AjaxRequestTarget target, Form<?> form) {
                            attChoice.processInput();
                            typeChoice.processInput();
                            dateFormatTextField.processInput();

                            AttributeRemapTransform tx = item.getModelObject();
                            
                            String field = tx.getField(); 
                            Class type = typeChoice.getModelObject();

                            if (Date.class.equals(type)) {
                                String dateFormat = dateFormatTextField.getModelObject();
                                if (dateFormat == null || "".equals(dateFormat.trim())) {
                                    dateFormat = null;
                                }
                                item.setModelObject(new DateFormatTransform(field, dateFormat));
                            }
                            else if (Number.class.isAssignableFrom(type)) {
                                item.setModelObject(new NumberFormatTransform(field, type));
                            }
                            
                            target.addComponent(remapContainer);
                        }
                    }.setDefaultFormProcessing(false));

                    item.add(new AjaxButton("cancel") {
                        @Override
                        protected void onSubmit(AjaxRequestTarget target, Form<?> form) {
                            remaps.remove(item.getModelObject());
                            target.addComponent(remapContainer);
                        }
                    }.setDefaultFormProcessing(false));

                }
            };
            remapList.setOutputMarkupId(true);
            remapContainer.add(remapList);

            add(new AjaxLink<ImportItem>("add", itemModel) {
                @Override
                public void onClick(AjaxRequestTarget target) {
                    ImportItem item = getModelObject();
                    remaps.add(new AttributeRemapTransform(null, null));
                    target.addComponent(remapContainer);
                }
            });
        }
    }
}
