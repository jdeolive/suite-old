package org.opengeo.data.importer.rest;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;

import org.apache.commons.io.IOUtils;
import org.geoserver.catalog.LayerInfo;
import org.geoserver.catalog.ResourceInfo;
import org.geoserver.catalog.StoreInfo;
import org.geoserver.config.util.XStreamPersister;
import org.geoserver.config.util.XStreamPersisterFactory;
import org.geoserver.rest.PageInfo;
import org.opengeo.data.importer.Database;
import org.opengeo.data.importer.Directory;
import org.opengeo.data.importer.FileData;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportData;
import org.opengeo.data.importer.ImportItem;
import org.opengeo.data.importer.ImportTask;
import org.opengeo.data.importer.Importer;
import org.opengeo.data.importer.SpatialFile;
import org.opengeo.data.importer.Table;

/**
 * Utility class for reading/writing import/tasks/etc... to/from JSON.
 * 
 * @author Justin Deoliveira, OpenGeo
 */
public class ImportJSONIO {

    Importer importer;
    XStreamPersister xp;

    public ImportJSONIO(Importer importer) {
        this.importer = importer;
        xp = new XStreamPersisterFactory().createJSONPersister();
        xp.setReferenceByName(true);
        xp.setExcludeIds();
        xp.setCatalog(importer.getCatalog());
    }

    public void context(ImportContext context, PageInfo page, OutputStream out) throws IOException {
        JSONBuilder json = new JSONBuilder(new OutputStreamWriter(out));

        json.object().key("import");
        json.object();
        json.key("id").value(context.getId());
        
        tasks(context.getTasks(), true, page, json);

        json.endObject();
        json.endObject();
        json.flush();
    }


    public void contexts(List<ImportContext> contexts, PageInfo page, OutputStream out) 
        throws IOException {
        
        JSONBuilder json = new JSONBuilder(new OutputStreamWriter(out));
        json.object().key("imports").array();
        for (ImportContext context : contexts) {
            json.object()
              .key("id").value(context.getId())
              .key("href").value(page.pageURI("/" + context.getId()))
            .endObject();
        }
        json.endArray().endObject();
        json.flush();
    }

    public void tasks(List<ImportTask> tasks, PageInfo page, OutputStream out) throws IOException {
        tasks(tasks, page, builder(out));
    }

    public void tasks(List<ImportTask> tasks, PageInfo page, JSONBuilder json) throws IOException {
        tasks(tasks, false, page, json);
    }

    public void tasks(List<ImportTask> tasks, boolean inline, PageInfo page, JSONBuilder json) 
        throws IOException {
        if (!inline) {
            json.object();
        }
        json.key("tasks").array();
        for (ImportTask task : tasks) {
            task(task, true, page, json);
        }
        json.endArray();
        if (!inline) {
            json.endObject();
        }
        json.flush();
    }

    public void task(ImportTask task, PageInfo page, OutputStream out) throws IOException {
        task(task, page, builder(out));
    }

    public void task(ImportTask task, PageInfo page, JSONBuilder json) throws IOException {
        task(task, false, page, json);
    }
    
    public void task(ImportTask task, boolean inline, PageInfo page, JSONBuilder json) throws IOException {
        
        long id = task.getId();
       
        if (!inline) {
            json.object().key("task");
        }
        json.object();
        json.key("id").value(id);
        json.key("href").value(page.rootURI("/imports/"+task.getContext().getId()+"/tasks/"+id));
        json.key("state").value(task.getState());

        //source
        ImportData data = task.getData();
        json.key("source");
        data(data, page, json);

        //target
        StoreInfo store = task.getStore();
        if (store != null) {
            json.key("target").value(toJSON(store));
        }

        //items
        items(task.getItems(), true, page, json);

        json.endObject();
        if (!inline) {
            json.endObject();
        }

        json.flush();
    }

    public void item(ImportItem item, PageInfo page, OutputStream out) throws IOException {
        item(item, page, builder(out));
    }

    public void item(ImportItem item, PageInfo page, JSONBuilder json) throws IOException {
        item(item, false, page, json);
    }
    
    public void item(ImportItem item, boolean inline, PageInfo page, JSONBuilder json) throws IOException {
        long id = item.getId();
        ImportTask task = item.getTask();
        
        LayerInfo layer = item.getLayer();
        if (!inline) {
            json.object().key("item");
        }

        json.object()
          .key("id").value(id)
          .key("href").value(page.rootURI(String.format("/imports/%d/tasks/%d/items/%d", 
              task.getContext().getId(), task.getId(), id)))
          .key("state").value(item.getState())
          .key("resource").value(toJSON(layer.getResource()))
          .key("layer").value(toJSON(layer))
        .endObject();

        if (!inline) {
            json.endObject();
        }
        json.flush();
    }

    public void items(List<ImportItem> items, PageInfo page, OutputStream out) throws IOException {
        items(items, page, builder(out));
    }

    public void items(List<ImportItem> items, PageInfo page, JSONBuilder json) throws IOException {
        items(items, false, page, json);
    }

    public void items(List<ImportItem> items, boolean inline, PageInfo page, JSONBuilder json) 
        throws IOException {
        if (!inline) {
            json.object();
        }
        json.key("items").array();

        Iterator<ImportItem> it = items.iterator();
        while(it.hasNext()) {
            ImportItem item = it.next();
            item(item, true, page, json);
        }
        json.endArray();
        if (!inline) {
            json.endObject();
        }
        json.flush();
    }

    public ImportItem item(InputStream in) throws IOException {
        JSONObject json = parse(in);
        if (json.has("item")) {
            json = json.getJSONObject("item");
        }

        LayerInfo layer = null; 
        if (json.has("layer")) {
            layer = fromJSON(json.getJSONObject("layer"), LayerInfo.class);
        }
        else {
            layer = importer.getCatalog().getFactory().createLayer();
        }

        //parse the resource if specified
        if (json.has("resource")) {
            ResourceInfo resource = fromJSON(json.getJSONObject("resource"), ResourceInfo.class);
            layer.setResource(resource);
        }

        //parse the layer if specified
        return new ImportItem(layer);
    }

    public void data(ImportData data, PageInfo page, OutputStream out) throws IOException {
        data(data, page, builder(out));
    }

    public void data(ImportData data, PageInfo page, JSONBuilder json) throws IOException {
        if (data instanceof FileData) {
            if (data instanceof Directory) {
                directory((Directory)data, page, json);
            }
            else {
                file((FileData)data, page, json);
            }
        }
        else if (data instanceof Database) {
            database((Database)data, page, json);
        }
    }

    public void file(FileData data, PageInfo page, OutputStream out) throws IOException {
        file(data, page, builder(out));
    }

    public void file(FileData data, PageInfo page, JSONBuilder json) throws IOException {
        json.object();
        
        json.key("type").value("file");
        json.key("format").value(data.getFormat() != null ? data.getFormat().getName() : null);
        json.key("location").value(data.getFile().getParentFile().getPath());

        fileContents(data, json);

        json.endObject();
    }

    void fileContents(FileData data, JSONBuilder json) throws IOException {
        json.key("file").value(data.getFile().getName());

        if (data instanceof SpatialFile) {
            SpatialFile sf = (SpatialFile) data;
            json.key("prj").value(sf.getPrjFile() != null ? sf.getPrjFile().getName() : null);
            json.key("other").array();
            for (File supp : ((SpatialFile) data).getSuppFiles()) {
                json.value(supp.getName());
            }
            json.endArray();
        }
    }

    public void directory(Directory data, PageInfo page, OutputStream out) throws IOException {
        directory(data, page, builder(out));
    }

    public void directory(Directory data, PageInfo page, JSONBuilder json) throws IOException {
        json.object();
        json.key("type").value("directory");
        json.key("format").value(data.getFormat() != null ? data.getFormat().getName() : null);
        json.key("location").value(data.getFile().getPath());
        json.key("files").array();
        
        for (FileData file : data.getFiles()) {
            json.object();
            fileContents(file, json);
            json.endObject();
        }
        json.endArray();

        json.endObject();
    }

    public void database(Database data, PageInfo page, OutputStream out) throws IOException {
        database(data, page, builder(out));
    }

    public void database(Database data, PageInfo page, JSONBuilder json) throws IOException {
        json.object();
        json.key("type").value("database");
        json.key("format").value(data.getFormat() != null ? data.getFormat().getName() : null);

        json.key("parameters").object();
        for (Map.Entry e : data.getParameters().entrySet()) {
            json.key((String) e.getKey()).value(e.getValue());
        }

        json.endObject();
        
        json.key("tables").array();
        for (Table t : data.getTables()) {
            json.value(t.getName());
        }
        json.endArray();

        json.endObject();
    }

    JSONBuilder builder(OutputStream out) {
        return new JSONBuilder(new OutputStreamWriter(out));
    }

    JSONObject toJSON(Object o) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        xp.save(o, out);
        return (JSONObject) JSONSerializer.toJSON(new String(out.toByteArray()));
    }

    <T> T fromJSON(JSONObject json, Class<T> clazz) throws IOException {
        return (T) xp.load(new ByteArrayInputStream(json.toString().getBytes()), clazz);
    }

    JSONObject parse(InputStream in) throws IOException {
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        IOUtils.copy(in, bout);
        return JSONObject.fromObject(new String(bout.toByteArray()));
    }
    
    static class JSONBuilder extends net.sf.json.util.JSONBuilder {

        public JSONBuilder(Writer w) {
            super(w);
        }

        public void flush() throws IOException {
            writer.flush();
        }
    }
}
