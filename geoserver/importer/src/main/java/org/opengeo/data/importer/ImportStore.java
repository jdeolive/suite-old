package org.opengeo.data.importer;

import java.util.Iterator;

/**
 * Data access interface for persisting imports.
 * 
 * @author Justin Deoliveira, OpenGeo
 */
public interface ImportStore {

    public interface ImportVisitor {
        void visit (ImportContext context);
    }

    void init();

    ImportContext get(long id);

    void add(ImportContext context);

    void save(ImportContext context);

    Iterator<ImportContext> iterator();

    void query(ImportVisitor visitor);

    void destroy();
}
