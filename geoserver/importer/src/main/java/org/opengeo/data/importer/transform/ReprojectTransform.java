package org.opengeo.data.importer.transform;

import org.geoserver.catalog.ResourceInfo;
import org.geotools.data.DataStore;
import org.geotools.feature.simple.SimpleFeatureTypeBuilder;
import org.geotools.geometry.jts.JTS;
import org.geotools.referencing.CRS;
import org.opengeo.data.importer.ImportData;
import org.opengeo.data.importer.ImportItem;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.opengis.referencing.operation.MathTransform;

import com.vividsolutions.jts.geom.Geometry;

public class ReprojectTransform extends AbstractVectorTransform implements InlineVectorTransform {

    CoordinateReferenceSystem source, target;
    transient MathTransform transform;

    public CoordinateReferenceSystem getSource() {
        return source;
    }

    public void setSource(CoordinateReferenceSystem source) {
        this.source = source;
    }

    public CoordinateReferenceSystem getTarget() {
        return target;
    }

    public void setTarget(CoordinateReferenceSystem target) {
        this.target = target;
    }

    public ReprojectTransform(CoordinateReferenceSystem target) {
        this(null, target);
    }

    public ReprojectTransform(CoordinateReferenceSystem source, CoordinateReferenceSystem target) {
        this.source = source;
        this.target = target;
    }

    public SimpleFeatureType apply(ImportItem item, DataStore dataStore,
            SimpleFeatureType featureType) throws Exception {

        //update the layer metadata
        ResourceInfo r = item.getLayer().getResource();
        r.setNativeCRS(target);
        r.setSRS(CRS.lookupIdentifier(target, true));
        if (r.getNativeBoundingBox() != null) {
            r.setNativeBoundingBox(r.getNativeBoundingBox().transform(target, true));
        }
        //retype the schema
        return SimpleFeatureTypeBuilder.retype(featureType, target);
    }

    public SimpleFeature apply(ImportItem item, DataStore dataStore, SimpleFeature oldFeature, SimpleFeature feature)
            throws Exception {
        if (transform == null) {
            //compute the reprojection transform
            CoordinateReferenceSystem source = this.source;
            if (source == null) {
                //try to determine source crs from data
                source = oldFeature.getType().getCoordinateReferenceSystem();
            }

            if (source == null) {
                throw new IllegalStateException("Unable to determine source projection");
            }

            transform = CRS.findMathTransform(source, target, true);
        }

        Geometry g = (Geometry) feature.getDefaultGeometry();
        if (g != null) {
            feature.setDefaultGeometry(JTS.transform(g, transform));
        }
        return feature;
    }
}
