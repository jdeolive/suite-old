package org.opengeo.data.importer;

import java.io.File;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;

public class DirectoryTest extends ImporterTestSupport {

    public void testSingleSpatialFile() throws Exception {
        File dir = unpack("shape/archsites_epsg_prj.zip");

        Directory d = new Directory(dir);
        d.prepare();
        
        List<FileData> files = d.getFiles();
        
        assertEquals(1, files.size());
        assertTrue( files.get(0) instanceof SpatialFile);

        SpatialFile spatial = (SpatialFile) files.get(0);
        assertEquals("shp", FilenameUtils.getExtension(spatial.getFile().getName()));

        assertNotNull(spatial.getPrjFile().getName());
        assertEquals("prj", FilenameUtils.getExtension(spatial.getPrjFile().getName()));
        
        assertEquals(2, spatial.getSuppFiles().size());

        Set<String> exts = new HashSet<String>(Arrays.asList("shx", "dbf"));
        for (File supp : spatial.getSuppFiles()) {
            exts.remove(FilenameUtils.getExtension(supp.getName()));
        }

        assertTrue(exts.isEmpty());
    }
    
    public void testMultipleSpatialFile() throws Exception {
        File dir = unpack("shape/archsites_epsg_prj.zip");
        unpack("shape/bugsites_esri_prj.tar.gz", dir);

        Directory d = new Directory(dir);
        d.prepare();

        assertEquals(2, d.getFiles().size());
        assertTrue( d.getFiles().get(0) instanceof SpatialFile);
        assertTrue( d.getFiles().get(1) instanceof SpatialFile);
    }

    public void testMultipleSpatialASpatialFile() throws Exception {
        File dir = unpack("shape/archsites_epsg_prj.zip");
        unpack("shape/bugsites_esri_prj.tar.gz", dir);
        FileUtils.touch(new File(dir, "foo.txt")); //TODO: don't rely on alphabetical order 
        
        Directory d = new Directory(dir);
        d.prepare();
        
        assertEquals(3, d.getFiles().size());
        assertTrue( d.getFiles().get(0) instanceof SpatialFile);
        assertTrue( d.getFiles().get(1) instanceof SpatialFile);
        assertTrue( d.getFiles().get(2) instanceof ASpatialFile);
    }

}
