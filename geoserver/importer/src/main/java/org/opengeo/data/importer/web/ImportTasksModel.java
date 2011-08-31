package org.opengeo.data.importer.web;

import java.util.List;

import org.apache.wicket.model.LoadableDetachableModel;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportTask;

public class ImportTasksModel extends LoadableDetachableModel<List<ImportTask>> {

    long id;

    public ImportTasksModel(ImportContext imp) {
        this(imp.getId());
    }

    public ImportTasksModel(long id) {
        this.id = id;
    }

    @Override
    protected List<ImportTask> load() {
        return ImporterWebUtils.importer().getContext(id).getTasks();
    }

}
