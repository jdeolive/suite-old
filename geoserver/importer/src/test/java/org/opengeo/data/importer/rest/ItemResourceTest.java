package org.opengeo.data.importer.rest;

import java.io.File;

import javax.servlet.ServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.opengeo.data.importer.Directory;
import org.opengeo.data.importer.Importer;
import org.opengeo.data.importer.ImporterTestSupport;
import org.opengeo.data.importer.SpatialFile;

import com.mockrunner.mock.web.MockHttpServletResponse;

public class ItemResourceTest extends ImporterTestSupport {

    @Override
    protected void setUpInternal() throws Exception {
        super.setUpInternal();
    
        File dir = unpack("shape/archsites_epsg_prj.zip");
        unpack("shape/bugsites_esri_prj.tar.gz", dir);
        importer.createContext(new Directory(dir));
    }

    public void testGetAllItems() throws Exception {
        JSONObject json = (JSONObject) getAsJSON("/rest/imports/0/tasks/0/items");

        JSONArray items = json.getJSONArray("items");
        assertEquals(2, items.size());

        JSONObject item = items.getJSONObject(0);
        assertEquals(0, item.getInt("id"));
        assertTrue(item.getString("href").endsWith("/imports/0/tasks/0/items/0"));
        
        item = items.getJSONObject(1);
        assertEquals(1, item.getInt("id"));
        assertTrue(item.getString("href").endsWith("/imports/0/tasks/0/items/1"));
    }

    public void testGetItem() throws Exception {
        JSONObject json = (JSONObject) getAsJSON("/rest/imports/0/tasks/0/items/0");
        JSONObject item = json.getJSONObject("item");
        
        assertEquals(0, item.getInt("id"));
        assertTrue(item.getString("href").endsWith("/imports/0/tasks/0/items/0"));
    }

    public void testPutItem() throws Exception {
        File dir = unpack("shape/archsites_no_crs.zip");
        importer.createContext(new SpatialFile(new File(dir, "archsites.shp")));

        JSONObject json = (JSONObject) getAsJSON("/rest/imports/1/tasks/0/items/0");
        JSONObject item = json.getJSONObject("item");
        assertEquals("NO_CRS", item.get("state"));
        assertFalse(item.getJSONObject("resource").getJSONObject("featureType").containsKey("srs"));

        //String 
        String s = "{" + 
          "\"resource\": {" + 
            "\"featureType\":   {" + 
               "\"srs\": \"EPSG:26713\"" +
             "}" + 
           "}" + 
        "}";

        put("/rest/imports/1/tasks/0/items/0", s, "application/json");

        json = (JSONObject) getAsJSON("/rest/imports/1/tasks/0/items/0");
        item = json.getJSONObject("item");
        assertEquals("READY", item.get("state"));
        assertEquals("EPSG:26713", 
            item.getJSONObject("resource").getJSONObject("featureType").getString("srs"));
    }

    public void testDeleteItem() throws Exception {
        MockHttpServletResponse response = deleteAsServletResponse("/rest/imports/0/tasks/0/items/0");
        assertEquals(200, response.getStatusCode());

        JSONObject json = (JSONObject) getAsJSON("/rest/imports/0/tasks/0/items");

        JSONArray items = json.getJSONArray("items");
        assertEquals(1, items.size());
        assertEquals(1, items.getJSONObject(0).getInt("id"));
    }
}
