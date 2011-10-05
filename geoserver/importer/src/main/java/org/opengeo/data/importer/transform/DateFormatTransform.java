package org.opengeo.data.importer.transform;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.geotools.data.DataStore;
import org.opengeo.data.importer.ImportItem;
import org.opengis.feature.simple.SimpleFeature;

/**
 * Transform that converts a non date attribute in a date attribute.
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class DateFormatTransform extends AttributeRemapTransform {

    static List<SimpleDateFormat> FORMATS = new ArrayList<SimpleDateFormat>();
    static {
        //TODO: add some more formats
        FORMATS.add(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss"));
        FORMATS.add(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss.S"));
        FORMATS.add(new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss"));
        FORMATS.add(new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss.S"));
    }
    SimpleDateFormat dateFormat;

    public DateFormatTransform(String field, String datePattern) {
        super(field, Date.class);
        
        if (datePattern != null) {
            this.dateFormat = new SimpleDateFormat(datePattern);    
        }
    }

    @Override
    public SimpleFeature apply(ImportItem item, DataStore dataStore, SimpleFeature oldFeature, 
        SimpleFeature feature) throws Exception {
        Object val = feature.getAttribute(field);
        if (val != null) {
            feature.setAttribute(field, parseDate(val.toString()));
        }
        return feature;
    }

    Date parseDate(String value) throws ParseException {
        ParseException error = null;
        if (dateFormat != null) {
            try {
                return dateFormat.parse(value);
            }
            catch(ParseException e) {
                e = error;
            }
        }

        for (SimpleDateFormat format : FORMATS) {
            try {
                return format.parse(value);
            }
            catch(ParseException e) {
                error = error != null ? error : e;
            }
        }
        
        throw error;
    }
}
