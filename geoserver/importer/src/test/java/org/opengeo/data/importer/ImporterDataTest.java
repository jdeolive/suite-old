package org.opengeo.data.importer;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.geoserver.catalog.Catalog;
import org.geoserver.catalog.DataStoreInfo;
import org.geoserver.catalog.FeatureTypeInfo;
import org.geoserver.catalog.LayerInfo;
import org.geotools.data.FeatureSource;
import org.geotools.data.Query;
import org.geotools.data.h2.H2DataStoreFactory;
import org.w3c.dom.Document;

import com.mockrunner.mock.web.MockHttpServletResponse;

public class ImporterDataTest extends ImporterTestSupport {

    public void testImportShapefile() throws Exception {
        File dir = unpack("shape/archsites_epsg_prj.zip");
        
        ImportContext context = 
                importer.createContext(new SpatialFile(new File(dir, "archsites.shp")));
        assertEquals(1, context.getTasks().size());
        
        ImportTask task = context.getTasks().get(0);
        assertEquals(ImportTask.State.READY, task.getState());
        assertEquals(1, task.getItems().size());
        
        ImportItem item = task.getItems().get(0);
        assertEquals(ImportItem.State.READY, item.getState());
        assertEquals("archsites", item.getLayer().getResource().getName());

        importer.run(context);
        
        Catalog cat = getCatalog();
        assertNotNull(cat.getLayerByName("archsites"));

        assertEquals(ImportTask.State.COMPLETE, task.getState());
        assertEquals(ImportItem.State.COMPLETE, item.getState());

        runChecks("archsites");
    }

    public void testImportShapefiles() throws Exception {
        File dir = tmpDir();
        unpack("shape/archsites_epsg_prj.zip", dir);
        unpack("shape/bugsites_esri_prj.tar.gz", dir);
        
        ImportContext context = importer.createContext(new Directory(dir));
        assertEquals(1, context.getTasks().size());
        
        ImportTask task = context.getTasks().get(0);
        assertEquals(ImportTask.State.READY, task.getState());
        assertEquals(2, task.getItems().size());
        
        assertEquals(ImportItem.State.READY, task.getItems().get(0).getState());
        assertEquals("archsites", task.getItems().get(0).getLayer().getResource().getName());

        assertEquals(ImportItem.State.READY, task.getItems().get(1).getState());
        assertEquals("bugsites", task.getItems().get(1).getLayer().getResource().getName());

        importer.run(context);
        
        Catalog cat = getCatalog();
        assertNotNull(cat.getLayerByName("archsites"));
        assertNotNull(cat.getLayerByName("bugsites"));
        
        assertEquals(ImportTask.State.COMPLETE, task.getState());
        assertEquals(ImportItem.State.COMPLETE, task.getItems().get(0).getState());
        assertEquals(ImportItem.State.COMPLETE, task.getItems().get(1).getState());
        
        runChecks("archsites");
        runChecks("bugsites");
    }

    public void testImportShapefilesWithError() throws Exception {
        File dir = tmpDir();
        unpack("shape/archsites_no_crs.zip", dir);
        unpack("shape/bugsites_esri_prj.tar.gz", dir);

        ImportContext context = importer.createContext(new Directory(dir));
        assertEquals(1, context.getTasks().size());

        ImportTask task = context.getTasks().get(0);
        assertEquals(ImportTask.State.INCOMPLETE, task.getState());
        assertEquals(2, task.getItems().size());

        assertEquals(ImportItem.State.NO_CRS, task.getItems().get(0).getState());
        assertEquals("archsites", task.getItems().get(0).getLayer().getResource().getName());

        assertEquals(ImportItem.State.READY, task.getItems().get(1).getState());
        assertEquals("bugsites", task.getItems().get(1).getLayer().getResource().getName());

        importer.run(context);

        Catalog cat = getCatalog();
        assertNull(cat.getLayerByName("archsites"));
        assertNotNull(cat.getLayerByName("bugsites"));

        assertEquals(ImportTask.State.INCOMPLETE, task.getState());
        assertEquals(ImportItem.State.NO_CRS, task.getItems().get(0).getState());
        assertEquals(ImportItem.State.COMPLETE, task.getItems().get(1).getState());

        runChecks("bugsites");
    }
 
    public void testImportUnknownFile() throws Exception {
        File dir = unpack("gml/states_wfs11.xml.gz");

        ImportContext context = importer.createContext(new Directory(dir)); 
        assertEquals(1, context.getTasks().size());

        ImportTask task = context.getTasks().get(0);
        assertEquals(ImportTask.State.INCOMPLETE, task.getState());
        assertNull(task.getData().getFormat());

    }

    public void testImportDatabase() throws Exception {
        File dir = unpack("h2/cookbook.zip");

        Map params = new HashMap();
        params.put(H2DataStoreFactory.DBTYPE.key, "h2");
        params.put(H2DataStoreFactory.DATABASE.key, new File(dir, "cookbook").getAbsolutePath());
     
        ImportContext context = importer.createContext(new Database(params));
        assertEquals(1, context.getTasks().size());

        ImportTask task = context.getTasks().get(0);
        assertEquals(ImportTask.State.READY, task.getState());
        
        assertEquals(3, task.getItems().size());

        assertEquals(ImportItem.State.READY, task.getItems().get(0).getState());
        assertEquals(ImportItem.State.READY, task.getItems().get(1).getState());
        assertEquals(ImportItem.State.READY, task.getItems().get(2).getState());

        Catalog cat = getCatalog();
        assertNull(cat.getDataStoreByName(cat.getDefaultWorkspace(), "cookbook"));
        assertNull(cat.getLayerByName("point"));
        assertNull(cat.getLayerByName("line"));
        assertNull(cat.getLayerByName("polygon"));

        importer.run(context);
        assertEquals(ImportTask.State.COMPLETE, task.getState());
        assertEquals(ImportItem.State.COMPLETE, task.getItems().get(0).getState());
        assertEquals(ImportItem.State.COMPLETE, task.getItems().get(1).getState());
        assertEquals(ImportItem.State.COMPLETE, task.getItems().get(2).getState());

        assertNotNull(cat.getDataStoreByName(cat.getDefaultWorkspace(), "cookbook"));

        DataStoreInfo ds = cat.getDataStoreByName(cat.getDefaultWorkspace(), "cookbook");
        assertNotNull(cat.getFeatureTypeByDataStore(ds, "point"));
        assertNotNull(cat.getFeatureTypeByDataStore(ds, "line"));
        assertNotNull(cat.getFeatureTypeByDataStore(ds, "polygon"));
        assertNotNull(cat.getLayerByName("point"));
        assertNotNull(cat.getLayerByName("line"));
        assertNotNull(cat.getLayerByName("polygon"));

        runChecks("point");
        runChecks("line");
        runChecks("polygon");
    }
//    
////    public void testImportGML() throws Exception {
////        File dir = unpack("gml/states_wfs11.gml.gz");
////        
////        Import imp = importer.newImport();
////        imp.setSource(new SpatialFile(new File(dir, "states_wfs11.gml"), new GMLFormat()));
////
////        importer.prepare(imp);
////        assertEquals(ImportStatus.READY, imp.getStatus());
////        assertEquals(1, imp.getLayers().size());
////        assertEquals(LayerStatus.READY, imp.getLayers().get(0).getStatus());
////
////        importer.run(imp);
////        
////        //converting gml leaves us without a crs and without bounds
////        assertTrue(imp.getLayers(LayerStatus.COMPLETED).isEmpty());
////        assertEquals(1, imp.getLayers().size());
////        assertEquals(LayerStatus.NO_CRS, imp.getLayers().get(0).getStatus());
////        imp.getLayers().get(0).setCRS(CRS.decode("EPSG:4326"));
////        
////        importer.run(imp);
////        runChecks("states");
////    }
//    
//    public void testImportGMLWithPrjFile() throws Exception {
//        File dir = unpack("gml/states_wfs11_prj.zip");
//        
//        Import imp = importer.newImport();
//        imp.setSource(new Directory(dir));
//
//        importer.prepare(imp);
//        assertEquals(ImportStatus.READY, imp.getStatus());
//        assertEquals(1, imp.getLayers().size());
//        assertEquals(LayerStatus.READY, imp.getLayers().get(0).getStatus());
//
//        importer.run(imp);
//        
//        runChecks("states");
//    }
//
    public void testImportIntoDatabase() throws Exception {
        Catalog cat = getCatalog();

        DataStoreInfo ds = cat.getFactory().createDataStore();
        ds.setWorkspace(cat.getDefaultWorkspace());
        ds.setName("spearfish");
        ds.setType("H2");

        Map params = new HashMap();
        params.put("database", getTestData().getDataDirectoryRoot().getPath()+"/spearfish");
        params.put("dbtype", "h2");
        ds.getConnectionParameters().putAll(params);
        ds.setEnabled(true);
        cat.add(ds);
        
        File dir = tmpDir();
        unpack("shape/archsites_epsg_prj.zip", dir);
        unpack("shape/bugsites_esri_prj.tar.gz", dir);

        ImportContext context = importer.createContext(new Directory(dir), ds);
        assertEquals(2, context.getTasks().size());

        assertEquals(1, context.getTasks().get(0).getItems().size());
        assertEquals(1, context.getTasks().get(1).getItems().size());

        assertEquals(ImportTask.State.READY, context.getTasks().get(0).getState());
        assertEquals(ImportTask.State.READY, context.getTasks().get(1).getState());
        
        ImportItem item1 = context.getTasks().get(0).getItems().get(0);
        assertEquals(ImportItem.State.READY, item1.getState());
        assertEquals("archsites", item1.getLayer().getResource().getName());
        
        ImportItem item2 = context.getTasks().get(1).getItems().get(0);
        assertEquals(ImportItem.State.READY, item2.getState());
        assertEquals("bugsites", item2.getLayer().getResource().getName());

        importer.run(context);

        assertEquals(ImportItem.State.COMPLETE, item1.getState());
        assertEquals(ImportItem.State.COMPLETE, item2.getState());

        assertNotNull(cat.getLayerByName("archsites"));
        assertNotNull(cat.getLayerByName("bugsites"));

        assertNotNull(cat.getFeatureTypeByDataStore(ds, "archsites"));
        assertNotNull(cat.getFeatureTypeByDataStore(ds, "bugsites"));

        runChecks("archsites");
        runChecks("bugsites");
    }

    public void testImportGeoTIFF() throws Exception {
        File dir = unpack("geotiff/EmissiveCampania.tif.bz2");
        
        ImportContext context = 
                importer.createContext(new SpatialFile(new File(dir, "EmissiveCampania.tif")));
        assertEquals(1, context.getTasks().size());
        
        ImportTask task = context.getTasks().get(0);
        assertEquals(ImportTask.State.READY, task.getState());
        assertEquals(1, task.getItems().size());
        
        ImportItem item = task.getItems().get(0);
        assertEquals(ImportItem.State.READY, item.getState());
        assertEquals("EmissiveCampania", item.getLayer().getResource().getName());

        importer.run(context);
        
        Catalog cat = getCatalog();
        assertNotNull(cat.getLayerByName("EmissiveCampania"));

        assertEquals(ImportTask.State.COMPLETE, task.getState());
        assertEquals(ImportItem.State.COMPLETE, item.getState());

        runChecks("EmissiveCampania");
    }

//    public void testUnknownFormat() throws Exception {
//        File dir = unpack("gml/states_wfs11.xml.gz");
//        
//        Import imp = importer.newImport();
//        imp.setSource(new SpatialFile(new File(dir, "states_wfs11.xml"), new GMLFormat()));
//
//        importer.prepare(imp);
//        assertEquals(ImportStatus.READY, imp.getStatus());
//        assertEquals(1, imp.getLayers().size());
//        assertEquals(LayerStatus.READY, imp.getLayers().get(0).getStatus());
//
//        importer.run(imp);
//        
//        //converting gml leaves us without a crs and without bounds
//        assertTrue(imp.getCompleted().isEmpty());
//        assertEquals(1, imp.getLayers().size());
//        assertEquals(LayerStatus.NO_CRS, imp.getLayers().get(0).getStatus());
//        imp.getLayers().get(0).setCRS(CRS.decode("EPSG:4326"));
//        
//        importer.run(imp);
//        runChecks("states");
//    }
}
