package org.opengeo.data.importer.rest;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.List;

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
        ImportContext context = lookupContext();
        ImportTask newTask = null;
        
        //file posted from form
        MediaType mimeType = getRequest().getEntity().getMediaType(); 
        if (mimeType.equals(MediaType.MULTIPART_FORM_DATA, true)) {
            newTask = handleMultiPartFormUpload();
        }
        else {
            
        }

        if (newTask == null) {
            throw new RestletException("Unsupported POST", Status.CLIENT_ERROR_FORBIDDEN);
        }

        context.addTask(newTask);
        try {
            importer.prep(context);
        } 
        catch (IOException e) {
            throw new RestletException("Error updating context", Status.SERVER_ERROR_INTERNAL, e);
        }

        getResponse().redirectSeeOther(getPageInfo().rootURI(String.format("/imports/%d/tasks/%d", 
            context.getId(), newTask.getId())));
        getResponse().setEntity(new ImportTaskJSONFormat().toRepresentation(newTask));
        getResponse().setStatus(Status.SUCCESS_CREATED);
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
        File directory;
        try {
            directory = importer.getCatalog().getResourceLoader().findOrCreateDirectory("uploads");
            directory = File.createTempFile("tmp", "", directory);
            directory.delete();
            directory.mkdir();
        } catch (IOException e) {
            throw new RestletException("Error creating temp directory", Status.SERVER_ERROR_INTERNAL, e);
        }

        //unpack all the files
        for (FileItem item : items) {
            if (item.getName() == null) {
                continue;
            }

            File file = new File(directory, item.getName());
            try {
                item.write(file);
            } 
            catch (Exception e) {
                throw new RestletException("Error writing file " + item.getName(), 
                    Status.SERVER_ERROR_INTERNAL, e);
            }

            //if the file is an archive, unpack it
            //TODO: build this in to Directory
            VFSWorker vfs = new VFSWorker();
            try {
                if (vfs.canHandle(file)) {
                    vfs.extractTo(file, directory);
                    file.delete();
                }
            } 
            catch (IOException e) {
                throw new RestletException("Error unpacking file " + item.getName(), 
                        Status.SERVER_ERROR_INTERNAL, e);
            }
        }
        newTask = new ImportTask(new Directory(directory));
        return newTask;
    }

    public boolean allowPut() {
        return getAttribute("task") != null;
    }

    public void handlePut() {
        
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
