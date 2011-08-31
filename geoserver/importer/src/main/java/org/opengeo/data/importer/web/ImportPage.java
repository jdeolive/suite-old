package org.opengeo.data.importer.web;

import static org.opengeo.data.importer.web.ImporterWebUtils.importer;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Future;

import org.apache.wicket.PageParameters;
import org.apache.wicket.ajax.AbstractAjaxTimerBehavior;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.util.time.Duration;
import org.geoserver.web.GeoServerSecuredPage;
import org.geoserver.web.wicket.Icon;
import org.opengeo.data.importer.BasicImportFilter;
import org.opengeo.data.importer.Database;
import org.opengeo.data.importer.Directory;
import org.opengeo.data.importer.FileData;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportData;
import org.opengeo.data.importer.ImportItem;
import org.opengeo.data.importer.ImportTask;
import org.opengeo.data.importer.RasterFormat;
import org.opengeo.data.importer.VectorFormat;

public class ImportPage extends GeoServerSecuredPage {

    //GeoServerTablePanel<LayerSummary> layerTable; 
    //AtomicBoolean job = new AtomicBoolean(false);
    
    public ImportPage(PageParameters pp) {
        this(new ImportContextModel(pp.getAsLong("id")));
    }

    public ImportPage(ImportContext imp) {
        this(new ImportContextModel(imp));
    }

    public ImportPage(IModel<ImportContext> model) {
        initComponents(model);
    }

    void initComponents(final IModel<ImportContext> model) {
        add(new Label("id", new PropertyModel(model, "id")));

        ImportContextProvider provider = new ImportContextProvider() {
            @Override
            protected List<Property<ImportContext>> getProperties() {
                return Arrays.asList(STATE, CREATED, UPDATED);
            }
            @Override
            protected List<ImportContext> getItems() {
                return Collections.singletonList(model.getObject());
            }
        };

        ImportContextTable headerTable = new ImportContextTable("header", provider);
        headerTable.setFilterable(false);
        headerTable.setPageable(false);
        add(headerTable);

        ImportContext imp = model.getObject();
        ListView<ImportTask> tasksView = new ListView<ImportTask>("tasks", new ImportTasksModel(imp)) {
            @Override
            protected void populateItem(final ListItem<ImportTask> item) {
                IModel<ImportTask> model = item.getModel();

                DataIcon icon = null;
                ImportData data = item.getModelObject().getData();
                if (data instanceof Directory) {
                    icon = DataIcon.FOLDER;
                }
                else if (data instanceof FileData) {
                    FileData df = (FileData) data;
                    icon = df.getFormat() instanceof VectorFormat ? DataIcon.FILE_VECTOR : 
                           df.getFormat() instanceof RasterFormat ? DataIcon.FILE_RASTER : DataIcon.FILE;
                }
                else if (data instanceof Database) {
                    icon = DataIcon.DATABASE;
                }
                else {
                    icon = DataIcon.VECTOR; //TODO: better default
                }

                item.add(new Icon("icon", icon.getIcon()));
                item.add(new Label("title", new PropertyModel(model, "data")));
                
                ImportItemProvider provider = new ImportItemProvider(item.getModelObject());
                final ImportItemTable itemTable = new ImportItemTable("items", provider, true);
                item.add(itemTable);
                
                itemTable.setOutputMarkupId(true);
                itemTable.setFilterable(false);
                itemTable.setSortable(false);
                doSelectReady(model.getObject(), itemTable, null);
                
                item.add(new AjaxLink("import") {
                    @Override
                    public void onClick(AjaxRequestTarget target) {
                        ImportTask task = item.getModelObject();

                        BasicImportFilter filter = new BasicImportFilter();
                        filter.add(task, itemTable.getSelection());

                        final Long jobid = 
                            importer().runAsync(task.getContext(), filter);

                        final AjaxLink self = this;

                        //create a timer to update the table and reload the page when necessary
                        itemTable.add(new AbstractAjaxTimerBehavior(Duration.milliseconds(500)) {
                            @Override
                            protected void onTimer(AjaxRequestTarget target) {
                                Future<ImportContext> job = importer().getFuture(jobid); 
                                if (job == null || job.isDone()) {
                                    //remove the timer
                                    stop();
                                    
                                    self.setEnabled(true);
                                    target.addComponent(self);
                                }

                                //update the table
                                target.addComponent(itemTable);
                            }
                        });
                        target.addComponent(itemTable);

                        //set this button disabled
                        setEnabled(false);
                        target.addComponent(this);
                    }
                });
                
                item.add(new AjaxLink<ImportTask>("select-all", model) {
                    @Override
                    public void onClick(AjaxRequestTarget target) {
                        itemTable.selectAll();
                        target.addComponent(itemTable);
                    }
                });
                item.add(new AjaxLink<ImportTask>("select-none", model) {
                    @Override
                    public void onClick(AjaxRequestTarget target) {
                        itemTable.clearSelection();
                        target.addComponent(itemTable);
                    }
                });
                item.add(new AjaxLink<ImportTask>("select-ready", model) {
                    @Override
                    public void onClick(AjaxRequestTarget target) {
                        doSelectReady(getModelObject(), itemTable, target);
                    }
                });
            }
        };
        add(tasksView);

//        LayerSummaryProvider provider = new LayerSummaryProvider(imp);
//
//        add(layerTable = new LayerSummaryTable("layers", provider, true));
//        layerTable.setOutputMarkupId(true);
//        layerTable.setFilterable(false);
//        layerTable.setSortable(false);
//        
//        if (newImport) {
//            //set up initial selections
//            for (int i = 0; i < imp.getLayers().size(); i++) {
//                LayerSummary l = imp.getLayers().get(i);
//                if (l.getStatus() == LayerStatus.READY) {
//                    layerTable.selectIndex(i);
//                }
//            }
//        }
//        else {
//            //set selections based on what was selected before
//            if (imp.getLayersToImport() != null) {
//                for (int i = 0; i < imp.getLayers().size(); i++) {
//                    LayerSummary l = imp.getLayers().get(i);
//                    if (l.getStatus() == LayerStatus.COMPLETED) {
//                        continue;
//                    }
//                    if (imp.getLayersToImport().contains(l)) {
//                        layerTable.selectIndex(i);
//                    }
//                }
//            }
//        }
//        
//        if(!newImport) {
//            //getFeedbackPanel().warn("This is an old import");
//        }
//            
    }

    
    void doSelectReady(ImportTask task, ImportItemTable table, AjaxRequestTarget target) {
        for (ImportItem item : task.getItems()) {
            if (item.getState() == ImportItem.State.READY) {
                table.selectObject(item);
            }
        }
        if (target != null) {
            target.addComponent(table);
        }
    }

    @Override
    public String getAjaxIndicatorMarkupId() {
        return null;
    }

//    class ImportTaskPanel extends Panel {
//
//        //TODO: use a model
//        ImportTask task;
//        ImportItemTable itemTable;
//
//        public ImportTaskPanel(String id, ImportTask task) {
//            this(id, new ImportTaskModel(task));
//        }
//
//        public ImportTaskPanel(String id, IModel<ImportTask> task) {
//            super(id);
//
//            DataIcon icon = null;
//            ImportData data = task.getObject().getData();
//            if (data instanceof Directory) {
//                icon = DataIcon.FOLDER;
//            }
//            else if (data instanceof FileData) {
//                FileData df = (FileData) data;
//                icon = df.getFormat() instanceof VectorFormat ? DataIcon.FILE_VECTOR : 
//                       df.getFormat() instanceof RasterFormat ? DataIcon.FILE_RASTER : DataIcon.FILE;
//            }
//            else if (data instanceof Database) {
//                icon = DataIcon.DATABASE;
//            }
//            else {
//                icon = DataIcon.VECTOR; //TODO: better default
//            }
//            add(new Icon("icon", icon.getIcon()));
//            add(new Label("title", new PropertyModel(task, "data")));
//
//            ImportItemProvider provider = new ImportItemProvider(task);
//
//            add(itemTable = new ImportItemTable("items", provider, true));
//            itemTable.setOutputMarkupId(true);
//            itemTable.setFilterable(false);
//            itemTable.setSortable(false);
//
//            
//
//        }
//    }
}
