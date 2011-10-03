package org.opengeo.data.importer.rest;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.channels.FileChannel;
import java.util.Arrays;
import java.util.List;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.geoserver.rest.AbstractResource;
import org.geoserver.rest.RestletException;
import org.geoserver.rest.format.DataFormat;
import org.geoserver.rest.format.StreamDataFormat;
import org.opengeo.data.importer.Directory;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportTask;
import org.opengeo.data.importer.Importer;
import org.opengeo.data.importer.VFSWorker;
import org.restlet.data.MediaType;
import org.restlet.data.Request;
import org.restlet.data.Response;
import org.restlet.data.Status;
import org.restlet.ext.fileupload.RestletFileUpload;

/**
 * REST resource for /imports/<import>/tasks[/<id>]
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class TaskResource extends AbstractResource {

    Importer importer;

    public TaskResource(Importer importer) {
        this.importer = importer;
    }

    @Override
    protected List<DataFormat> createSupportedFormats(Request request, Response response) {
        return (List) Arrays.asList(new ImportTaskJSONFormat());
    }

    @Override
    public void handleGet() {
        Object obj = lookupTask(true);
        if (obj instanceof ImportTask) {
            getResponse().setEntity(getFormatGet().toRepresentation((ImportTask)obj));
        }
        else {
            getResponse().setEntity(getFormatGet().toRepresentation((List<ImportTask>)obj));
        }
    }

    public boolean allowPost() {
        return getAttribute("task") == null;
    }

    public void handlePost() {
        ImportTask newTask = null;
        
        getLogger().info("Handling POST of " + getRequest().getEntity().getMediaType());
        //file posted from form
        MediaType mimeType = getRequest().getEntity().getMediaType(); 
        if (mimeType.equals(MediaType.MULTIPART_FORM_DATA, true)) {
            newTask = handleMultiPartFormUpload();
        }
        else {
            // nothing
        }

        if (newTask == null) {
            throw new RestletException("Unsupported POST", Status.CLIENT_ERROR_FORBIDDEN);
        }

        acceptTask(newTask);
    }
    
    private void acceptTask(ImportTask newTask) {
        ImportContext context = lookupContext();
        context.addTask(newTask);
        try {
            importer.prep(context);
            context.updated();
        } 
        catch (IOException e) {
            throw new RestletException("Error updating context", Status.SERVER_ERROR_INTERNAL, e);
        }

        getResponse().redirectSeeOther(getPageInfo().rootURI(String.format("/imports/%d/tasks/%d", 
            context.getId(), newTask.getId())));
        getResponse().setEntity(new ImportTaskJSONFormat().toRepresentation(newTask));
        getResponse().setStatus(Status.SUCCESS_CREATED);
    }
    
    private Directory createDirectory() {
        try {
            return Directory.createNew(importer.getCatalog().getResourceLoader().findOrCreateDirectory("uploads"));
        } catch (IOException ioe) {
            throw new RestletException("File upload failed", Status.SERVER_ERROR_INTERNAL, ioe);
        }
    }
    
    private ImportTask handleFileUpload() {
        Directory directory = createDirectory();
        
        try {
            directory.accept(getAttribute("task"),getRequest().getEntity().getStream());
        } catch (IOException e) {
            throw new RestletException("Error unpacking file", 
                Status.SERVER_ERROR_INTERNAL, e);
        }
        
        return new ImportTask(directory);
    }
    
    private ImportTask handleMultiPartFormUpload() {
        ImportTask newTask;
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(102400000);

        RestletFileUpload upload = new RestletFileUpload(factory);
        List<FileItem> items = null;
        try {
            items = upload.parseRequest(getRequest());
        } catch (FileUploadException e) {
            throw new RestletException("File upload failed", Status.SERVER_ERROR_INTERNAL, e);
        }

        //create a directory to hold the files
        Directory directory = createDirectory();

        //unpack all the files
        for (FileItem item : items) {
            if (item.getName() == null) {
                continue;
            }
            try {
                directory.accept(item);
            } catch (Exception ex) {
                throw new RestletException("Error writing file " + item.getName(), Status.SERVER_ERROR_INTERNAL, ex);
            }
        }
        newTask = new ImportTask(directory);
        return newTask;
    }

    public boolean allowPut() {
        return getAttribute("task") != null;
    }

    public void handlePut() {
        getLogger().info("Handling PUT of " + getRequest().getEntity().getMediaType());
        
        ImportTask newTask = handleFileUpload();
        
        acceptTask(newTask);
    }

    ImportContext lookupContext() {
        long i = Long.parseLong(getAttribute("import"));

        ImportContext context = importer.getContext(i);
        if (context == null) {
            throw new RestletException("No such import: " + i, Status.CLIENT_ERROR_NOT_FOUND);
        }
        return context;
    }

    Object lookupTask(boolean allowAll) {
        ImportContext context = lookupContext();

        String t = getAttribute("task");
        if (t != null) {
            int id = Integer.parseInt(t);
            if (id >= context.getTasks().size()) {
                throw new RestletException("No such task: " + id + " for import: " + context.getId(),
                    Status.CLIENT_ERROR_NOT_FOUND);
            }

            return context.getTasks().get(id);
        }
        else {
            if (allowAll) {
                return context.getTasks();
            }
            throw new RestletException("No task specified", Status.CLIENT_ERROR_BAD_REQUEST);
        }
    }

    class ImportTaskJSONFormat extends StreamDataFormat {

        ImportTaskJSONFormat() {
            super(MediaType.APPLICATION_JSON);
        }

        @Override
        protected Object read(InputStream in) throws IOException {
            return null;
        }

        @Override
        protected void write(Object object, OutputStream out) throws IOException {
            ImportJSONIO json = new ImportJSONIO(importer);

            if (object instanceof ImportTask) {
                ImportTask task = (ImportTask) object;
                json.task(task, getPageInfo(), out);
            }
            else {
                json.tasks((List<ImportTask>)object, getPageInfo(), out);
            }
        }

    }
}
