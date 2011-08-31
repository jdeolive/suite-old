package org.opengeo.data.importer.rest;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.List;

import org.geoserver.config.util.XStreamPersister;
import org.geoserver.config.util.XStreamPersisterFactory;
import org.geoserver.rest.AbstractResource;
import org.geoserver.rest.RestletException;
import org.geoserver.rest.format.DataFormat;
import org.geoserver.rest.format.StreamDataFormat;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.Importer;
import org.restlet.data.MediaType;
import org.restlet.data.Request;
import org.restlet.data.Response;
import org.restlet.data.Status;

/**
 * REST resource for /contexts[/<id>]
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class ImportResource extends AbstractResource {

    Importer importer;

    public ImportResource(Importer importer) {
        this.importer = importer;
    }

    @Override
    protected List<DataFormat> createSupportedFormats(Request request, Response response) {
        return (List) Arrays.asList(new ImportContextJSONFormat());
    }

    @Override
    public void handleGet() {
        getResponse().setEntity(getFormatGet().toRepresentation(lookupContext(true, true)));
    }

    @Override
    public boolean allowPost() {
        return true;
    }

    @Override
    public void handlePost() {
        Object obj = lookupContext(true, true);
        if (obj instanceof ImportContext) {
            //run an existing import
            try {
                importer.run((ImportContext) obj);
            } catch (IOException e) {
                throw new RestletException("Error occured executing import", Status.SERVER_ERROR_INTERNAL, e);
            }
        }
        else {
            //create a new import
            try {
                ImportContext context = importer.createContext(null);
                getResponse().redirectSeeOther(getPageInfo().rootURI("/imports/"+context.getId()));
                getResponse().setEntity(new ImportContextJSONFormat().toRepresentation(context));
                getResponse().setStatus(Status.SUCCESS_CREATED);
            } 
            catch (IOException e) {
                throw new RestletException("Unable to create import", Status.SERVER_ERROR_INTERNAL, e);
            }
        }
    }

    Object lookupContext(boolean allowAll, boolean mustExist) {
        String i = getAttribute("import");
        if (i != null) {
            ImportContext context = importer.getContext(Long.parseLong(i));
            if (context == null && mustExist) {
                throw new RestletException("No such import: " + i, Status.CLIENT_ERROR_NOT_FOUND);
            }
            return context;
        }
        else {
            if (allowAll) {
                return importer.getContexts();
            }
            throw new RestletException("No import specified", Status.CLIENT_ERROR_BAD_REQUEST);
        }
    }

    class ImportContextJSONFormat extends StreamDataFormat {

        XStreamPersister xp;

        public ImportContextJSONFormat() {
            super(MediaType.APPLICATION_JSON);
            xp = new XStreamPersisterFactory().createJSONPersister();
            xp.setReferenceByName(true);
            xp.setExcludeIds();
        }

        @Override
        protected Object read(InputStream in) throws IOException {
            return null;
        }

        @Override
        protected void write(Object object, OutputStream out) throws IOException {
            ImportJSONIO json = new ImportJSONIO(importer);

            if (object instanceof ImportContext) {
                json.context((ImportContext) object, getPageInfo(), out);
            }
            else {
                json.contexts((List<ImportContext>)object, getPageInfo(), out);
            }
        }
    }
}
