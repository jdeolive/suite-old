package org.opengeo.geoserver.test;

import java.io.File;
import java.util.HashMap;

import org.custommonkey.xmlunit.SimpleNamespaceContext;
import org.custommonkey.xmlunit.XMLUnit;
import org.geoserver.data.test.LiveData;
import org.geoserver.data.test.TestData;
import org.geoserver.test.GeoServerAbstractTestSupport;
import org.geotools.filter.v1_1.OGC;
import org.geotools.gml2.GML;
import org.geotools.wfs.v1_0.WFS;

public class OpenGeoTestSupport extends GeoServerAbstractTestSupport {

    static {
        HashMap ns = new HashMap();
        ns.put("wfs", WFS.NAMESPACE);
        ns.put("gml", GML.NAMESPACE);
        ns.put("ogc", OGC.NAMESPACE);
        ns.put("medford", "http://medford.opengeo.org");
        
        XMLUnit.setXpathNamespaceContext(new SimpleNamespaceContext(ns));
    }
    
    @Override
    protected boolean useLegacyDataDirectory() {
        return false;
    }
    
    @Override
    protected TestData buildTestData() throws Exception {
        return new LiveData(new File("../../data_dir").getCanonicalFile());
    }

}
