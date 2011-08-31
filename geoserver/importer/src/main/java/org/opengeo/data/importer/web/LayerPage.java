package org.opengeo.data.importer.web;

import org.apache.wicket.PageParameters;
import org.geoserver.catalog.LayerInfo;
import org.geoserver.web.data.resource.ResourceConfigurationPage;

public class LayerPage extends ResourceConfigurationPage {

    PageParameters sourcePage;

    public LayerPage(LayerInfo info, PageParameters sourcePage) {
        super(info, true);
        this.sourcePage = sourcePage;
    }

    @Override
    protected void doSave() {
        if (getLayerInfo().getId() == null) {
            //do not call super.doSave(), because this layer is not part of the catalog yet

            
            onSuccessfulSave();
        }
        else {
            super.doSave();
        }
    }

    @Override
    protected void onSuccessfulSave() {
        setResponsePage(ImportPage.class, sourcePage);
    }

    @Override
    protected void onCancel() {
        //TODO: cancel doesn't roll back any changes
        setResponsePage(ImportPage.class, sourcePage);
    }
}
