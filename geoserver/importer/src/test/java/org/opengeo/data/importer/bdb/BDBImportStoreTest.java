package org.opengeo.data.importer.bdb;

import java.io.File;
import java.util.Iterator;
import java.util.concurrent.TimeUnit;

import org.geoserver.platform.GeoServerResourceLoader;
import org.opengeo.data.importer.Directory;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportStore.ImportVisitor;
import org.opengeo.data.importer.ImportTask;
import org.opengeo.data.importer.ImporterTestSupport;

import com.sleepycat.bind.EntryBinding;
import com.sleepycat.bind.serial.SerialBinding;
import com.sleepycat.bind.serial.StoredClassCatalog;
import com.sleepycat.collections.StoredList;
import com.sleepycat.collections.StoredMap;
import com.sleepycat.je.CacheMode;
import com.sleepycat.je.Database;
import com.sleepycat.je.DatabaseConfig;
import com.sleepycat.je.DatabaseEntry;
import com.sleepycat.je.Durability;
import com.sleepycat.je.Environment;
import com.sleepycat.je.EnvironmentConfig;
import com.sleepycat.je.LockMode;

import junit.framework.TestCase;

public class BDBImportStoreTest extends ImporterTestSupport {

    BDBImportStore store;
    
    @Override
    protected void setUpInternal() throws Exception {
        super.setUpInternal();
        
        store = new BDBImportStore(importer);
        store.init();
    }

    public void testAdd() throws Exception {
        File dir = unpack("shape/archsites_epsg_prj.zip");
        ImportContext context = importer.createContext(new Directory(dir));
        assertNull(context.getId());

        CountingVisitor cv = new CountingVisitor();
        store.query(cv);
        assertEquals(0, cv.getCount());

        store.add(context);
        assertNotNull(context.getId());

        ImportContext context2 = store.get(context.getId());
        assertNotNull(context2);
        assertEquals(context.getId(), context2.getId());

        store.query(cv);
        assertEquals(1, cv.getCount());
        
        SearchingVisitor sv = new SearchingVisitor(context.getId());
        store.query(sv);
        assertTrue(sv.isFound());
    }

    public void testSave() throws Exception {
        testAdd();

        ImportContext context = store.get(0);
        assertNotNull(context);

        assertEquals(ImportContext.State.READY, context.getState());
        context.setState(ImportContext.State.COMPLETE);

        ImportContext context2 = store.get(0);
        assertNotNull(context2);
        assertEquals(ImportContext.State.READY, context2.getState());

        store.save(context);
        context2 = store.get(0);
        assertNotNull(context2);
        assertEquals(ImportContext.State.COMPLETE, context2.getState());
    }

    class SearchingVisitor implements ImportVisitor {
        long id;
        boolean found = false;

        SearchingVisitor(long id) {
            this.id = id;
        }
        public void visit(ImportContext context) {
            if (context.getId().longValue() == id) {
                found = true;
            }
        }
        public boolean isFound() {
            return found;
        }
    }

    class CountingVisitor implements ImportVisitor {
        int count = 0;
        public void visit(ImportContext context) {
            count++;
        }
        public int getCount() {
            return count;
        }
    }

    @Override
    protected void tearDownInternal() throws Exception {
        super.tearDownInternal();
        store.destroy();

//        Environment env = db.getEnvironment();
//        db.close();
//        classDb.close();
//        env.close();
    }
}
