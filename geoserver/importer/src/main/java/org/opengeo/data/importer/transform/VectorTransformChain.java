package org.opengeo.data.importer.transform;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.geotools.data.DataStore;
import org.geotools.util.logging.Logging;
import org.opengeo.data.importer.ImportData;
import org.opengeo.data.importer.ImportItem;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;

/**
 * Transform chain for vectors.
 * 
 * @author Justin Deoliveira, OpenGeo
 */
public class VectorTransformChain extends TransformChain<VectorTransform> {

    static Logger LOGGER = Logging.getLogger(VectorTransformChain.class);

    public VectorTransformChain(List<VectorTransform> transforms) {
        super(transforms);
    }

    public VectorTransformChain(VectorTransform... transforms) {
        super(transforms);
    }

    public void pre(ImportItem item, ImportData data) throws Exception {
        for (PreVectorTransform tx : filter(transforms, PreVectorTransform.class)) {
            try {
                tx.apply(item, data);
            } catch (Exception e) {
                error(tx, e);
            }
        }
    }

    public SimpleFeatureType inline(ImportItem item, DataStore dataStore, SimpleFeatureType featureType) 
        throws Exception {
        
        for (InlineVectorTransform tx : filter(transforms, InlineVectorTransform.class)) {
            try {
                featureType = tx.apply(item, dataStore, featureType);
            } catch (Exception e) {
                error(tx, e);
            }
        }
        
        return featureType;
    }

    public SimpleFeature inline(ImportItem item, DataStore dataStore, SimpleFeature oldFeature, 
        SimpleFeature feature) throws Exception {
        
        for (InlineVectorTransform tx : filter(transforms, InlineVectorTransform.class)) {
            try {
                feature = tx.apply(item, dataStore, oldFeature, feature);
            } catch (Exception e) {
                error(tx, e);
            }
        }
        
        return feature;
    }

    public void post(ImportItem item, ImportData data) throws Exception {
        for (PostVectorTransform tx : filter(transforms, PostVectorTransform.class)) {
            try {
                tx.apply(item, data);
            } catch (Exception e) {
                error(tx, e);
            }
        }
    }

    <T> List<T> filter(List<VectorTransform> transforms, Class<T> type) {
        List<T> filtered = new ArrayList<T>();
        for (VectorTransform tx : transforms) {
            if (type.isInstance(tx)) {
                filtered.add((T) tx);
            }
        }
        return filtered;
    }

    void error(VectorTransform tx, Exception e) throws Exception {
        if (tx.stopOnError(e)) {
            throw e;
        }
        else {
            //log and continue
            LOGGER.log(Level.WARNING, "Transform " + tx + " failed", e);
        }
    }
}
