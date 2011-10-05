package org.opengeo.data.importer.transform;

import org.geotools.data.DataStore;
import org.opengeo.data.importer.ImportItem;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;

/**
 * Vector transform that is performed inline features are read from the source and written to
 * the destination.
 * <p>
 * This type of transform can only be applied to an indirect import.
 * </p>
 * 
 * @author Justin Deoliveira, OpenGeo
 */
public interface InlineVectorTransform extends VectorTransform {

    SimpleFeatureType apply(ImportItem item, DataStore dataStore, SimpleFeatureType featureType) 
        throws Exception;
    
    SimpleFeature apply(ImportItem item, DataStore dataStore, SimpleFeature oldFeature, SimpleFeature feature) 
        throws Exception;
}
