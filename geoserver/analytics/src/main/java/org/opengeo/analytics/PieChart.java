package org.opengeo.analytics;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import freemarker.ext.beans.BeansWrapper;
import freemarker.ext.beans.CollectionModel;
import freemarker.ext.beans.MapModel;
import freemarker.template.SimpleHash;
import freemarker.template.TemplateException;
import freemarker.template.TemplateModel;
import freemarker.template.TemplateModelException;

public class PieChart extends Chart {

    String[] colors;
    Map<String,ServiceOpSummary> data;
    
    public void setColors(String[] colors) {
        this.colors = colors;
    }
    
    public String[] getColors() {
        return colors;
    }
    
    public void setData(Map<String, ServiceOpSummary> data) {
        this.data = data;
    }
    
    public Map<String, ServiceOpSummary> getData() {
        return data;
    }
    
    public void render(Writer writer) 
        throws IOException, TemplateException {

        //sort by number of requrests
        List<ServiceOpSummary> keys = new ArrayList(data.values());
        Collections.sort(keys, new Comparator<ServiceOpSummary>() {
            public int compare(ServiceOpSummary s1, ServiceOpSummary s2) {
                return -1*s1.getCount().compareTo(s2.getCount());
            }
        });
        
        List<SimpleHash> hashes = new ArrayList();
        for(ServiceOpSummary sum : keys) {
            SimpleHash hash = new SimpleHash();
            hash.put("value", sum.getCount());
            
            Service s;
            try {
                s = Service.valueOf(sum.getService());
            }
            catch(IllegalArgumentException e) {
                s = Service.OTHER;
            }
            
            hash.put("label", s.displayName());
            hash.put("color", s.color());
            
            if (s != Service.OTHER) {
                hash.put("ops", sum.getOperations());
            }
            else {
                hash.put("ops", new HashMap()); 
            }
            
            hashes.add(hash);
        }
        
       
        
        SimpleHash model = createTemplate();
        model.put("data", hashes);
        
        render(model, "pie.ftl", writer);
    }
}
