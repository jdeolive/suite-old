package org.opengeo.geoserver.test;

import javax.servlet.http.HttpServletResponse;

import org.custommonkey.xmlunit.XMLAssert;
import org.w3c.dom.Document;

public class BasicTest extends ReadOnlyTestSupport {

    public void testMedfordBuildings() throws Exception {
        Document dom = 
            getAsDOM("wfs?request=getfeature&typename=medford:buildings&maxfeatures=1");
        
        assertEquals("wfs:FeatureCollection", dom.getDocumentElement().getNodeName());
        XMLAssert.assertXpathEvaluatesTo("1", "count(//medford:buildings)", dom);
        
        String xml =
            "<wfs:GetFeature xmlns:wfs='http://www.opengis.net/wfs' service='WFS' version='1.0.0' maxFeatures='1'>" + 
              "<wfs:Query typeName='medford:buildings'/>" + 
            "</wfs:GetFeature>";
        dom = postAsDOM("wfs", xml);
        
        assertEquals("wfs:FeatureCollection", dom.getDocumentElement().getNodeName());
        XMLAssert.assertXpathEvaluatesTo("1", "count(//medford:buildings)", dom);
    
        //HttpServletResponse resp = getAsServletResponse("wms?request=getmap&....");
        //InputStream in = get("wms?request=getmap&..");
        //getAsString(path)
    }
}
