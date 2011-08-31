package org.opengeo.data.importer;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.geoserver.catalog.Catalog;
import org.geoserver.catalog.CatalogBuilder;
import org.geoserver.catalog.CoverageInfo;
import org.geoserver.catalog.CoverageStoreInfo;
import org.geoserver.catalog.LayerInfo;
import org.geoserver.catalog.ResourceInfo;
import org.geoserver.catalog.WorkspaceInfo;
import org.geotools.coverage.grid.io.AbstractGridCoverage2DReader;
import org.geotools.coverage.grid.io.AbstractGridFormat;

/**
 * Base for formats that have a GridFormat implementation.
 *  
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class GridFormat extends RasterFormat {

    private Class<? extends AbstractGridFormat> gridFormatClass;
    private transient volatile AbstractGridFormat gridFormat;

    public GridFormat(Class<? extends AbstractGridFormat> gridFormatClass) {
        this.gridFormatClass = gridFormatClass;
    }

    public GridFormat(AbstractGridFormat gridFormat) {
        this(gridFormat.getClass());
        this.gridFormat = gridFormat;
    }

    @Override
    public String getName() {
        return gridFormat().getName();
    }

    @Override
    public boolean canRead(ImportData data) throws IOException {
        AbstractGridFormat gridFormat = gridFormat();
        
        File f = file(data);
        if (f != null) {
            return gridFormat.accepts(f);
        }
        return false;
    }

    @Override
    public CoverageStoreInfo createStore(ImportData data, WorkspaceInfo workspace, Catalog catalog) 
        throws IOException {
        File f = file(data);
        if (f == null) {
            return null;
        }

        CatalogBuilder cb = new CatalogBuilder(catalog);
        cb.setWorkspace(workspace);
        
        CoverageStoreInfo store = cb.buildCoverageStore(data.getName());
        store.setURL(f.toURI().toURL().toString());
        store.setType(gridFormat().getName());
        
        return store;
    }

    @Override
    public List<ImportItem> list(ImportData data, Catalog catalog) throws IOException {
        AbstractGridCoverage2DReader reader = gridReader(data);
        
        List<ImportItem> resources = new ArrayList<ImportItem>();
        if (reader != null) {
            CatalogBuilder cb = new CatalogBuilder(catalog);

            //create a dummy store
            CoverageStoreInfo store = cb.buildCoverageStore("dummy");
            store.setType(gridFormat().getName());
            cb.setStore(store);

            try {
                CoverageInfo coverage = cb.buildCoverage(reader, null);
                coverage.setStore(null);
                coverage.setNamespace(null);
                cb.setupBounds(coverage, reader);

                LayerInfo layer = cb.buildLayer((ResourceInfo)coverage);
                resources.add(new ImportItem(layer));
            } catch (Exception e) {
                throw (IOException) new IOException(). initCause(e);
            }
        }
        return resources;
    }

    public AbstractGridCoverage2DReader gridReader(ImportData data) throws IOException {
        //try file based
        File f = null;
        if (data instanceof SpatialFile) {
            f = ((SpatialFile) data).getFile();
        }
        if (data instanceof Directory) {
            f = ((Directory) data).getFile();
        }
        if (f != null) {
            AbstractGridFormat gridFormat = gridFormat();
            return gridFormat.getReader(f);
        }
        return null;
    }

    File file(ImportData data) {
        //try file based
        File f = null;
        if (data instanceof SpatialFile) {
            f = ((SpatialFile) data).getFile();
        }
        if (data instanceof Directory) {
            f = ((Directory) data).getFile();
        }
        return f;
    }

    protected AbstractGridFormat gridFormat() {
        if (gridFormat == null) {
            synchronized (this) {
                if (gridFormat == null) {
                    try {
                        gridFormat = gridFormatClass.newInstance();
                    } catch (Exception e) {
                        throw new RuntimeException("Unable to create instance of: " + 
                            gridFormatClass.getSimpleName(), e);
                    }
                }
            }
        }
        return gridFormat;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((gridFormatClass == null) ? 0 : gridFormatClass.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        GridFormat other = (GridFormat) obj;
        if (gridFormatClass == null) {
            if (other.gridFormatClass != null)
                return false;
        } else if (!gridFormatClass.equals(other.gridFormatClass))
            return false;
        return true;
    }

    
}
