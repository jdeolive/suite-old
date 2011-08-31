package org.opengeo.data.importer.rest;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.List;

import org.geoserver.catalog.CatalogBuilder;
import org.geoserver.catalog.CoverageInfo;
import org.geoserver.catalog.FeatureTypeInfo;
import org.geoserver.catalog.LayerInfo;
import org.geoserver.catalog.ResourceInfo;
import org.geoserver.rest.AbstractResource;
import org.geoserver.rest.RestletException;
import org.geoserver.rest.format.DataFormat;
import org.geoserver.rest.format.StreamDataFormat;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportItem;
import org.opengeo.data.importer.ImportTask;
import org.opengeo.data.importer.Importer;
import org.restlet.data.MediaType;
import org.restlet.data.Request;
import org.restlet.data.Response;
import org.restlet.data.Status;

/**
 * REST resource for /imports/<import>/tasks/<task>/items[/<id>]
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class ItemResource extends AbstractResource {

    Importer importer;

    public ItemResource(Importer importer) {
        this.importer = importer;
    }

    @Override
    protected List<DataFormat> createSupportedFormats(Request request, Response response) {
        return (List) Arrays.asList(new ImportItemJSONFormat());
    }

    @Override
    public void handleGet() {
        getResponse().setEntity(getFormatGet().toRepresentation(lookupItem(true)));
    }

    @Override
    public boolean allowPut() {
        return getAttribute("item") != null;
    }

    @Override
    public void handlePut() {
        ImportItem orig = (ImportItem) lookupItem(false);
        ImportItem item = (ImportItem) getFormatPostOrPut().toObject(getRequest().getEntity());

        //update the original layer and resource from the new
        LayerInfo l = item.getLayer();
        ResourceInfo r = l.getResource();

        //TODO: this is not thread safe, clone the object before overwriting it
        //save the existing resource, which will be overwritten below,  
        ResourceInfo resource = orig.getLayer().getResource();
        
        CatalogBuilder cb = new CatalogBuilder(importer.getCatalog());
        if (l != null) {
            l.setResource(resource);
            cb.updateLayer(orig.getLayer(), l);
            //orig.getLayer().setResource(resource);
        }

        //update the resource
        if (r != null) {
            if (r instanceof FeatureTypeInfo) {
                cb.updateFeatureType((FeatureTypeInfo) resource, (FeatureTypeInfo) r);
            }
            else if (r instanceof CoverageInfo) {
                cb.updateCoverage((CoverageInfo) resource, (CoverageInfo) r);
            }
        }

        //notify the importer that the item has changed
        importer.changed(orig);
    }

    public boolean allowDelete() {
        return getAttribute("item") != null;
    }

    public void handleDelete() {
        ImportItem item = (ImportItem) lookupItem(false);
        ImportTask task = item.getTask();
        task.removeItem(item);

        importer.changed(task);
    }

    Object lookupItem(boolean allowAll) {
        long imprt = Long.parseLong(getAttribute("import"));

        ImportContext context = importer.getContext(imprt);
        if (context == null) {
            throw new RestletException("No such import: " + imprt, Status.CLIENT_ERROR_NOT_FOUND);
        }

        int t = Integer.parseInt(getAttribute("task"));
        if (t >= context.getTasks().size()) {
            throw new RestletException("No such task: " + t + " for import: " + imprt,
                    Status.CLIENT_ERROR_NOT_FOUND);
        }

        ImportTask task = context.getTasks().get(t);

        String i = getAttribute("item");
        if (i != null) {
            int id = Integer.parseInt(i);
            if (id >= task.getItems().size()) {
                throw new RestletException("No such item: " + id + " for import: " + imprt + 
                    ", task: " + t, Status.CLIENT_ERROR_NOT_FOUND);
            }

            return task.getItems().get(id);
        }
        else {
            if (allowAll) {
                return task.getItems();
            }
            throw new RestletException("No item specified", Status.CLIENT_ERROR_BAD_REQUEST);
        }
    }

    class ImportItemJSONFormat extends StreamDataFormat {

        ImportItemJSONFormat() {
            super(MediaType.APPLICATION_JSON);
        }

        @Override
        protected Object read(InputStream in) throws IOException {
            return new ImportJSONIO(importer).item(in);
        }

        @Override
        protected void write(Object object, OutputStream out) throws IOException {
            ImportJSONIO json = new ImportJSONIO(importer);

            if (object instanceof ImportItem) {
                ImportItem item = (ImportItem) object;
                json.item(item, getPageInfo(), out);
            }
            else {
                json.items((List<ImportItem>)object, getPageInfo(), out);
            }
        }

    }
}
