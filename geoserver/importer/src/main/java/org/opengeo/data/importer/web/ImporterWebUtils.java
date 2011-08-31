package org.opengeo.data.importer.web;

import org.geoserver.web.GeoServerApplication;
import org.opengeo.data.importer.Importer;

/**
 * Importer web utilities.
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class ImporterWebUtils {

    static Importer importer() {
        return GeoServerApplication.get().getBeanOfType(Importer.class);
    }
}
