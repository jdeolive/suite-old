package org.opengeo.data.importer.web;

import org.apache.wicket.model.LoadableDetachableModel;
import org.opengeo.data.importer.ImportTask;

public class ImportTaskModel extends LoadableDetachableModel<ImportTask> {

    long context;
    long id;

    public ImportTaskModel(ImportTask task) {
        this(task.getContext().getId(), task.getId());
    }

    public ImportTaskModel(long context, long id) {
        this.context = context;
        this.id = id;
    }

    @Override
    protected ImportTask load() {
        return ImporterWebUtils.importer().getContext(context).task(id);
    }

}
