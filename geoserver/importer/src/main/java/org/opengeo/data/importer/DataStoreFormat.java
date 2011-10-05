package org.opengeo.data.importer;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.geoserver.catalog.AttributeTypeInfo;
import org.geoserver.catalog.Catalog;
import org.geoserver.catalog.CatalogBuilder;
import org.geoserver.catalog.CatalogFactory;
import org.geoserver.catalog.DataStoreInfo;
import org.geoserver.catalog.FeatureTypeInfo;
import org.geoserver.catalog.LayerInfo;
import org.geoserver.catalog.ResourceInfo;
import org.geoserver.catalog.WorkspaceInfo;
import org.geotools.data.DataStore;
import org.geotools.data.DataStoreFactorySpi;
import org.geotools.data.FeatureReader;
import org.geotools.data.FileDataStoreFactorySpi;
import org.geotools.data.Query;
import org.geotools.data.Transaction;
import org.geotools.data.simple.SimpleFeatureSource;
import org.geotools.jdbc.JDBCDataStoreFactory;
import org.opengis.feature.simple.SimpleFeatureType;
import org.opengis.feature.type.AttributeDescriptor;
import org.opengis.feature.type.FeatureType;

/**
 * Base for formats that have a DataStore implementation.
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class DataStoreFormat extends VectorFormat {

    private Class<? extends DataStoreFactorySpi> dataStoreFactoryClass;
    private transient volatile DataStoreFactorySpi dataStoreFactory;

    public DataStoreFormat(Class<? extends DataStoreFactorySpi> dataStoreFactoryClass) {
        this.dataStoreFactoryClass = dataStoreFactoryClass;
    }

    public DataStoreFormat(DataStoreFactorySpi dataStoreFactory) {
        this(dataStoreFactory.getClass());
        this.dataStoreFactory = dataStoreFactory;
    }

    @Override
    public String getName() {
        return factory().getDisplayName();
    }

    @Override
    public boolean canRead(ImportData data) throws IOException {
        DataStore store = createDataStore(data);
        try {
            return store != null;
        }
        finally {
            if (store != null) {
                store.dispose();
            }
        }
    }

    public DataStoreInfo createStore(ImportData data, WorkspaceInfo workspace, Catalog catalog) throws IOException {
        Map<String,Serializable> params = createConnectionParameters(data);
        if (params == null) {
            return null;
        }

        CatalogBuilder cb = new CatalogBuilder(catalog);
        cb.setWorkspace(workspace);
        DataStoreInfo store  = cb.buildDataStore(data.getName());
        store.setType(factory().getDisplayName());
        store.getConnectionParameters().putAll(params);
        return store;
    }

    @Override
    public List<ImportItem> list(ImportData data, Catalog catalog) throws IOException {
        DataStore dataStore = createDataStore(data);
        try {
            CatalogBuilder cb = new CatalogBuilder(catalog);
            
            //create a dummy datastore
            DataStoreInfo store = cb.buildDataStore("dummy");
            cb.setStore(store);
            
            List<ImportItem> resources = new ArrayList<ImportItem>();
            for (String typeName : dataStore.getTypeNames()) {
                FeatureTypeInfo featureType = 
                        cb.buildFeatureType(dataStore.getFeatureSource(typeName));
                featureType.setStore(null);
                featureType.setNamespace(null);

                SimpleFeatureSource featureSource = dataStore.getFeatureSource(typeName); 
                cb.setupBounds(featureType, featureSource);

                //add attributes
                CatalogFactory factory = catalog.getFactory();
                SimpleFeatureType schema = featureSource.getSchema();
                for (AttributeDescriptor ad : schema.getAttributeDescriptors()) {
                    AttributeTypeInfo att = factory.createAttribute();
                    att.setName(ad.getLocalName());
                    att.setBinding(ad.getType().getBinding());
                    featureType.getAttributes().add(att);
                }

                LayerInfo layer = cb.buildLayer((ResourceInfo)featureType);

                ImportItem item = new ImportItem(layer);
                item.getMetadata().put(FeatureType.class, schema);

                resources.add(item);
            }

            return resources;
        }
        finally {
            dataStore.dispose();
        }
    }

    @Override
    public FeatureReader read(ImportData data, ImportItem item) throws IOException {
        DataStore dataStore = createDataStore(data);

        //store in order to later dispose
        //TODO: come up with a better scheme for caching the datastore
        item.getMetadata().put(DataStore.class, dataStore);
        FeatureReader reader = dataStore.getFeatureReader(
            new Query(item.getLayer().getResource().getNativeName()), Transaction.AUTO_COMMIT);
        return reader;
    }

    public void dispose(FeatureReader reader, ImportItem item) throws IOException {
        reader.close();

        if (item.getMetadata().containsKey(DataStore.class)) {
            DataStore dataStore = (DataStore) item.getMetadata().get(DataStore.class);
            dataStore.dispose();
        }
    }
    
    public DataStore createDataStore(ImportData data) throws IOException {
        DataStoreFactorySpi dataStoreFactory = factory();

        Map<String,Serializable> params = createConnectionParameters(data);
        if (params != null && dataStoreFactory.canProcess(params)) {
            DataStore dataStore = dataStoreFactory.createDataStore(params); 
            if (dataStore != null) {
                return dataStore;
            }
        }

        return null;
    }

    public Map<String,Serializable> createConnectionParameters(ImportData data) throws IOException {
        //try file based
        if (dataStoreFactory instanceof FileDataStoreFactorySpi) {
            File f = null;
            if (data instanceof SpatialFile) {
                f = ((SpatialFile) data).getFile();
            }
            if (data instanceof Directory) {
                f = ((Directory) data).getFile();
            }

            if (f != null) {
                Map<String,Serializable> map = new HashMap<String, Serializable>();
                map.put("url", f.toURI().toURL());
                return map;
            }
        }

        //try db based
        if (dataStoreFactory instanceof JDBCDataStoreFactory) {
            Database db = null;
            if (data instanceof Database) {
                db = (Database) data;
            }
            if (data instanceof Table) {
                db = ((Table) data).getDatabase();
            }

            if (db != null) {
                return db.getParameters();
            }
        }
        return null;
    }

    protected DataStoreFactorySpi factory() {
        if (dataStoreFactory == null) {
            synchronized (this) {
                if (dataStoreFactory == null) {
                    try {
                        dataStoreFactory = dataStoreFactoryClass.newInstance();
                    } catch (Exception e) {
                        throw new RuntimeException("Unable to create instance of: " + 
                            dataStoreFactoryClass.getSimpleName(), e);
                    }
                }
            }
        }
        return dataStoreFactory;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
                + ((dataStoreFactoryClass == null) ? 0 : dataStoreFactoryClass.hashCode());
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
        
        DataStoreFormat other = (DataStoreFormat) obj;
        if (dataStoreFactoryClass == null) {
            if (other.dataStoreFactoryClass != null)
                return false;
        } else if (!dataStoreFactoryClass.equals(other.dataStoreFactoryClass))
            return false;
        return true;
    }
}
