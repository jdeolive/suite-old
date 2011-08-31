package org.opengeo.data.importer.web;

import org.apache.wicket.markup.html.panel.Panel;
import org.opengeo.data.importer.ImportData;

/**
 * Abstract class for import source panels.
 */
public abstract class ImportSourcePanel extends Panel {

    public ImportSourcePanel(String id) {
        super(id);
    }

    public abstract ImportData createImportSource();

}
