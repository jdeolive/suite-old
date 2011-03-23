package org.opengeo.analytics.web;

import java.text.ParseException;
import java.util.Date;

import org.apache.wicket.PageParameters;
import org.apache.wicket.WicketRuntimeException;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.markup.html.basic.Label;
import org.geoserver.monitor.Query;
import org.geoserver.monitor.Query.Comparison;
import org.geoserver.monitor.web.MonitorBasePage;
import static org.geoserver.monitor.rest.RequestResource.toDate;

public class ResourcePage extends MonitorBasePage {
    
    Query query;
    RequestDataTablePanel tablePanel;
    
    public ResourcePage(PageParameters params) {
        String resource = params.getString("resource");
        Date from = null, to = null;
        
        if (params.containsKey("from")) {
            try {
                from = toDate(params.getString("from"));
                to = toDate(params.getString("to"));
            } 
            catch (ParseException e) {
                throw new WicketRuntimeException(e);
            }
        }
    
        add(new Label("resource", resource));
        
        query = new Query();
        if (from != null) {
            query.between(from, to);
        }
        query.filter(resource, "resources", Comparison.IN);
        
        ActivityPanel activityPanel = new ActivityPanel("activity", query) {
            @Override
            protected void onChange(AjaxRequestTarget target) {
                target.addComponent(tablePanel);
            }
        };
        add(activityPanel);
        
        tablePanel = new RequestDataTablePanel("requests", new RequestDataProvider(query));
        tablePanel.setOutputMarkupId(true);
        tablePanel.setItemsPerPage(25);
        add(tablePanel);
    }
}
