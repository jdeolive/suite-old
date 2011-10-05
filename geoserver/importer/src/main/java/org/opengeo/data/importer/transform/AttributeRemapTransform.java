package org.opengeo.data.importer.transform;

import org.geotools.data.DataStore;
import org.geotools.feature.simple.SimpleFeatureTypeBuilder;
import org.opengeo.data.importer.ImportItem;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;

/**
 * Attribute that maps an attribute from one type to another.
 * 
 * @author Justin Deoliveira, OpenGeo
 */
public class AttributeRemapTransform extends AbstractVectorTransform implements InlineVectorTransform {

    /** field to remap */
    protected String field;

    /** type to remap to */
    protected Class type;

    public AttributeRemapTransform(String field, Class type) {
        this.field = field;
        this.type = type;
    }

    public String getField() {
        return field;
    }

    public void setField(String field) {
        this.field = field;
    }

    public Class getType() {
        return type;
    }

    public void setType(Class type) {
        this.type = type;
    }

    public SimpleFeatureType apply(ImportItem item, DataStore dataStore,
            SimpleFeatureType featureType) throws Exception {
        //remap the type
        SimpleFeatureTypeBuilder builder = new SimpleFeatureTypeBuilder();
        builder.init(featureType);

        //remap the attribute to type date
        builder.remove(field);
        builder.add(field, type);

        return builder.buildFeatureType();
    }

    public SimpleFeature apply(ImportItem item, DataStore dataStore, SimpleFeature oldFeature, 
        SimpleFeature feature) throws Exception {
        return feature;
    }

}
