package org.opengeo.data.importer.rest;

import java.io.ByteArrayOutputStream;
import java.io.File;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.multipart.FilePart;
import org.apache.commons.httpclient.methods.multipart.MultipartRequestEntity;
import org.apache.commons.httpclient.methods.multipart.Part;
import org.opengeo.data.importer.Directory;
import org.opengeo.data.importer.ImportContext;
import org.opengeo.data.importer.ImportTask;
import org.opengeo.data.importer.ImporterTestSupport;
import org.opengeo.data.importer.SpatialFile;

import com.mockrunner.mock.web.MockHttpServletRequest;
import com.mockrunner.mock.web.MockHttpServletResponse;

public class TaskResourceTest extends ImporterTestSupport {

    @Override
    protected void setUpInternal() throws Exception {
        super.setUpInternal();
    
        File dir = unpack("shape/archsites_epsg_prj.zip");
        unpack("geotiff/EmissiveCampania.tif.bz2", dir);
        importer.createContext(new Directory(dir));
    }

    public void testGetAllTasks() throws Exception {
        JSONObject json = (JSONObject) getAsJSON("/rest/imports/0/tasks");

        JSONArray tasks = json.getJSONArray("tasks");
        assertEquals(2, tasks.size());

        JSONObject task = tasks.getJSONObject(0);
        assertEquals(0, task.getInt("id"));
        assertTrue(task.getString("href").endsWith("/imports/0/tasks/0"));
        
        task = tasks.getJSONObject(1);
        assertEquals(1, task.getInt("id"));
        assertTrue(task.getString("href").endsWith("/imports/0/tasks/1"));
    }

    public void testGetTask() throws Exception {
        JSONObject json = (JSONObject) getAsJSON("/rest/imports/0/tasks/0");
        JSONObject task = json.getJSONObject("task");
        assertEquals(0, task.getInt("id"));
        assertTrue(task.getString("href").endsWith("/imports/0/tasks/0"));
    }

    public void testPostMultiPartFormData() throws Exception {
        MockHttpServletResponse resp = postAsServletResponse("/rest/imports", "");
        assertEquals(201, resp.getStatusCode());
        assertNotNull(resp.getHeader("Location"));

        String[] split = resp.getHeader("Location").split("/");
        Integer id = Integer.parseInt(split[split.length-1]);
        ImportContext context = importer.getContext(id);
        assertNull(context.getData());
        assertTrue(context.getTasks().isEmpty());

        File dir = unpack("shape/archsites_epsg_prj.zip");
        
        Part[] parts = new Part[]{new FilePart("archsites.shp", new File(dir, "archsites.shp")), 
            new FilePart("archsites.dbf", new File(dir, "archsites.dbf")), 
            new FilePart("archsites.shx", new File(dir, "archsites.shx")), 
            new FilePart("archsites.prj", new File(dir, "archsites.prj"))};

        MultipartRequestEntity multipart = 
            new MultipartRequestEntity(parts, new PostMethod().getParams());

        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        multipart.writeRequest(bout);

        MockHttpServletRequest req = createRequest("/rest/imports/" + id + "/tasks");
        req.setContentType(multipart.getContentType());
        req.addHeader("Content-Type", multipart.getContentType());
        req.setMethod("POST");
        req.setBodyContent(bout.toByteArray());
        resp = dispatch(req);

        context = importer.getContext(context.getId());
        assertNull(context.getData());
        assertEquals(1, context.getTasks().size());

        ImportTask task = context.getTasks().get(0);
        assertTrue(task.getData() instanceof Directory);
        assertEquals(ImportTask.State.READY, task.getState());
    }
}
