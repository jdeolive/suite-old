package org.opengeo.data.importer.bdb;

import java.io.File;
import java.util.Iterator;
import java.util.concurrent.TimeUnit;

import org.geoserver.catalog.LayerInfo;
import org.geoserver.platform.GeoServerResourceLoader;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportItem;
import org.opengeo.data.importer.ImportStore;
import org.opengeo.data.importer.ImportTask;
import org.opengeo.data.importer.Importer;

import com.sleepycat.bind.EntryBinding;
import com.sleepycat.bind.serial.SerialBinding;
import com.sleepycat.bind.serial.StoredClassCatalog;
import com.sleepycat.bind.tuple.LongBinding;
import com.sleepycat.collections.StoredMap;
import com.sleepycat.je.CacheMode;
import com.sleepycat.je.Cursor;
import com.sleepycat.je.Database;
import com.sleepycat.je.DatabaseConfig;
import com.sleepycat.je.DatabaseEntry;
import com.sleepycat.je.Durability;
import com.sleepycat.je.Environment;
import com.sleepycat.je.EnvironmentConfig;
import com.sleepycat.je.LockMode;
import com.sleepycat.je.OperationStatus;
import com.sleepycat.je.Sequence;
import com.sleepycat.je.SequenceConfig;

/**
 * Import store implementation based on Berkley DB Java Edition.
 * 
 * @author Justin Deoliveira, OpenGeo
 */
public class BDBImportStore implements ImportStore {

    Importer importer;

    Database db;
    Database seqDb;
    Database classDb;

    Sequence importIdSeq;
    StoredClassCatalog classCatalog;
    EntryBinding<ImportContext> importBinding;

    public BDBImportStore(Importer importer) {
        this.importer = importer;
    }

    public void init() {
        //create the db environment
        EnvironmentConfig envCfg = new EnvironmentConfig();
        envCfg.setAllowCreate(true);
        envCfg.setCacheMode(CacheMode.DEFAULT);
        envCfg.setLockTimeout(1000, TimeUnit.MILLISECONDS);
        envCfg.setDurability(Durability.COMMIT_WRITE_NO_SYNC);
        envCfg.setSharedCache(true);
        envCfg.setTransactional(true);
        envCfg.setConfigParam("je.log.fileMax", String.valueOf(100 * 1024 * 1024));

        File dbRoot = new File(importer.getImportRoot(), "bdb");
        dbRoot.mkdir();
        
        Environment env = new Environment(dbRoot, envCfg);

        DatabaseConfig dbConfig = new DatabaseConfig();
        dbConfig.setAllowCreate(true);
        dbConfig.setTransactional(true);

        db = env.openDatabase(null, "imports", dbConfig);
         
        SequenceConfig seqConfig = new SequenceConfig();
        seqConfig.setAllowCreate(true);
        seqDb = env.openDatabase(null, "seq", dbConfig);
        importIdSeq = 
            seqDb.openSequence(null, new DatabaseEntry("import_id".getBytes()), seqConfig);
        
        classDb = env.openDatabase(null, "classes", dbConfig);
        classCatalog = new StoredClassCatalog(classDb);
        importBinding = new SerialBinding<ImportContext>(classCatalog, ImportContext.class);
    }

    public ImportContext get(long id) {
        DatabaseEntry val = new DatabaseEntry();
        OperationStatus op = db.get(null, key(id), val, LockMode.DEFAULT);
        if (op == OperationStatus.NOTFOUND) {
            return null;
        }

        ImportContext context = importBinding.entryToObject(val);

        //fix transient references that were not serialized
        for (ImportTask task : context.getTasks()) {
            for (ImportItem item : task.getItems()) {
                if (item.getLayer() != null) {
                    LayerInfo l = item.getLayer();
                    if (l.getDefaultStyle() != null && l.getDefaultStyle().getId() != null) {
                        l.setDefaultStyle(importer.getCatalog().getStyle(l.getDefaultStyle().getId()));
                    }
                }
            }
        }

        return context;
    }

    public void add(ImportContext context) {
        context.setId(importIdSeq.get(null, 1));

        put(context);
    }

    public void save(ImportContext context) {
        if (context.getId() == null) {
            add(context);
        }
        else {
            put(context);
        }
    }

    public Iterator<ImportContext> iterator() {
        return new StoredMap<Long, ImportContext>(db, new LongBinding(), importBinding, false)
            .values().iterator();
    }

    public void query(ImportVisitor visitor) {
        Cursor c  = db.openCursor(null, null);
        try {
            DatabaseEntry key = new DatabaseEntry();
            DatabaseEntry val = new DatabaseEntry();
    
            OperationStatus op = null;
            while((op  = c.getNext(key, val, LockMode.DEFAULT)) == OperationStatus.SUCCESS) {
                visitor.visit(importBinding.entryToObject(val));
            }
        }
        finally {
            c.close();
        }
    }

    void put(ImportContext context) {
        DatabaseEntry val = new DatabaseEntry();
        importBinding.objectToEntry(context, val);

        db.put(null, key(context), val);
    }

    DatabaseEntry key(ImportContext context) {
        return key(context.getId());
    }

    DatabaseEntry key(long id) {
        DatabaseEntry key = new DatabaseEntry();
        new LongBinding().objectToEntry(id, key);
        return key;
    }

    byte[] toBytes(long l) {
        byte[] b = new byte[8];
        b[0]   = (byte)(0xff & (l >> 56));
        b[1] = (byte)(0xff & (l >> 48));
        b[2] = (byte)(0xff & (l >> 40));
        b[3] = (byte)(0xff & (l >> 32));
        b[4] = (byte)(0xff & (l >> 24));
        b[5] = (byte)(0xff & (l >> 16));
        b[6] = (byte)(0xff & (l >> 8));
        b[7] = (byte)(0xff & l);
        return b;
    }
    public void destroy() {
        //destroy the db environment
        Environment env = db.getEnvironment();
        classDb.close();
        seqDb.close();
        db.close();
        env.close();
    }
}
