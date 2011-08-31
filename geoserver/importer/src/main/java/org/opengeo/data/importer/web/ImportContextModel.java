package org.opengeo.data.importer.web;

import org.apache.wicket.model.LoadableDetachableModel;
import org.opengeo.data.importer.ImportContext;

public class ImportContextModel extends LoadableDetachableModel<ImportContext> {

    long id;
    
    public ImportContextModel(ImportContext imp) {
        this(imp.getId());
    }

    public ImportContextModel(long id) {
        this.id = id;
    }
    
    @Override
    protected ImportContext load() {
        return ImporterWebUtils.importer().getContext(id);
    }


}
