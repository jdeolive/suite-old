package org.opengeo.data.importer;

import java.io.File;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.geoserver.catalog.Catalog;
import org.geoserver.catalog.DataStoreInfo;
import org.geoserver.catalog.FeatureTypeInfo;
import org.geoserver.catalog.LayerInfo;
import org.geotools.feature.FeatureIterator;
import org.geotools.referencing.CRS;
import org.opengeo.data.importer.transform.DateFormatTransform;
import org.opengeo.data.importer.transform.NumberFormatTransform;
import org.opengeo.data.importer.transform.ReprojectTransform;
import org.opengeo.data.importer.transform.VectorTransformChain;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;

public class ImportTransformTest extends ImporterTestSupport {

    DataStoreInfo store;

    @Override
    protected void setUpInternal() throws Exception {
        super.setUpInternal();
        
        Catalog cat = getCatalog();

        store = cat.getFactory().createDataStore();
        store.setWorkspace(cat.getDefaultWorkspace());
        store.setName("spearfish");
        store.setType("H2");

        Map params = new HashMap();
        params.put("database", getTestData().getDataDirectoryRoot().getPath()+"/spearfish");
        params.put("dbtype", "h2");
        store.getConnectionParameters().putAll(params);
        store.setEnabled(true);
        cat.add(store);
    }
    
    public void testNumberFormatTransform() throws Exception {
        Catalog cat = getCatalog();

        File dir = unpack("shape/restricted.zip");

        SpatialFile file = new SpatialFile(new File(dir, "restricted.shp"));
        file.prepare();

        ImportContext context = importer.createContext(file, store);
        assertEquals(1, context.getTasks().size());
        assertEquals(1, context.getTasks().get(0).getItems().size());
        
        context.setTargetStore(store);

        ImportItem item = context.getTasks().get(0).getItems().get(0);
        item.getTransform().add(new NumberFormatTransform("cat", Integer.class));
        importer.run(context);

        assertEquals(ImportContext.State.COMPLETE, context.getState());

        FeatureTypeInfo ft = cat.getFeatureTypeByDataStore(store, "restricted");
        assertNotNull(ft);

        SimpleFeatureType schema = (SimpleFeatureType) ft.getFeatureType();
        assertEquals(Integer.class, schema.getDescriptor("cat").getType().getBinding());

        FeatureIterator it = ft.getFeatureSource(null, null).getFeatures().features();
        try {
            assertTrue(it.hasNext());
            while(it.hasNext()) {
                SimpleFeature f = (SimpleFeature) it.next();
                assertTrue(f.getAttribute("cat") instanceof Integer);
            }
        }
        finally {
            it.close();
        }
    }

    public void testDateFormatTransform() throws Exception {
        Catalog cat = getCatalog();

        File dir = unpack("shape/ivan.zip");

        SpatialFile file = new SpatialFile(new File(dir, "ivan.shp"));
        file.prepare();

        ImportContext context = importer.createContext(file, store);
        assertEquals(1, context.getTasks().size());
        assertEquals(1, context.getTasks().get(0).getItems().size());
        
        context.setTargetStore(store);

        ImportItem item = context.getTasks().get(0).getItems().get(0);
        item.getTransform().add(new DateFormatTransform("timestamp", "yyyy-MM-dd HH:mm:ss.S"));
        
        importer.run(context);

        assertEquals(ImportContext.State.COMPLETE, context.getState());

        FeatureTypeInfo ft = cat.getFeatureTypeByDataStore(store, "ivan");
        assertNotNull(ft);

        SimpleFeatureType schema = (SimpleFeatureType) ft.getFeatureType();
        assertTrue(Date.class.isAssignableFrom(schema.getDescriptor("timestamp").getType().getBinding()));

        FeatureIterator it = ft.getFeatureSource(null, null).getFeatures().features();
        try {
            assertTrue(it.hasNext());
            while(it.hasNext()) {
                SimpleFeature f = (SimpleFeature) it.next();
                assertTrue(f.getAttribute("timestamp") instanceof Date);
            }
        }
        finally {
            it.close();
        }
    }

    public void testReprojectTransform() throws Exception {
        Catalog cat = getCatalog();

        File dir = unpack("shape/archsites_epsg_prj.zip");

        SpatialFile file = new SpatialFile(new File(dir, "archsites.shp"));
        file.prepare();

        ImportContext context = importer.createContext(file, store);
        importer.run(context);

        assertEquals(ImportContext.State.COMPLETE, context.getState());

        LayerInfo l1 = context.getTasks().get(0).getItems().get(0).getLayer();
        assertTrue(CRS.equalsIgnoreMetadata(CRS.decode("EPSG:26713"), l1.getResource().getNativeCRS()));
        assertEquals("EPSG:26713", l1.getResource().getSRS());
        
        dir = unpack("shape/archsites_epsg_prj.zip");

        file = new SpatialFile(new File(dir, "archsites.shp"));
        file.prepare();

        context = importer.createContext(file, store);
        ImportItem item = context.getTasks().get(0).getItems().get(0);
        item.getTransform().add(new ReprojectTransform(CRS.decode("EPSG:4326")));
        importer.run(context);

        assertEquals(ImportContext.State.COMPLETE, context.getState());
        
        LayerInfo l2 = context.getTasks().get(0).getItems().get(0).getLayer();
        assertTrue(CRS.equalsIgnoreMetadata(CRS.decode("EPSG:4326"), l2.getResource().getNativeCRS()));
        assertEquals("EPSG:4326", l2.getResource().getSRS());
        
        assertFalse(l1.getResource().getNativeBoundingBox().equals(l2.getResource().getNativeBoundingBox()));
        assertTrue(CRS.equalsIgnoreMetadata(l2.getResource().getNativeCRS(), l2.getResource().getNativeBoundingBox().getCoordinateReferenceSystem()));
        
        LayerInfo l = cat.getLayer(l2.getId());
        assertTrue(CRS.equalsIgnoreMetadata(CRS.decode("EPSG:4326"), l2.getResource().getNativeCRS()));
        assertEquals("EPSG:4326", l2.getResource().getSRS());
    }
}
