package org.opengeo.analytics.web;

import java.util.ArrayList;
import java.util.List;

import org.apache.wicket.extensions.markup.html.tabs.AbstractTab;
import org.apache.wicket.extensions.markup.html.tabs.ITab;
import org.apache.wicket.extensions.markup.html.tabs.TabbedPanel;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.model.ResourceModel;
import org.apache.wicket.model.StringResourceModel;
import org.geoserver.monitor.Query;
import org.geoserver.monitor.web.MonitorBasePage;
import org.opengeo.analytics.QueryViewState;

public class AnalyticsHomePage extends MonitorBasePage {

    QueryViewState queryViewState;
    String description;
    
    public AnalyticsHomePage() {
        queryViewState = new QueryViewState();
        
        add(new Label("description", new PropertyModel<String>(this, "description")))
        ;
        List<ITab> tabs = new ArrayList();
        tabs.add(new AbstractTab(new ResourceModel("summary")) {
            @Override
            public Panel getPanel(String panelId) {
                description = description("summaryDescription");
                return new SummaryPanel(panelId, queryViewState);
            }
        });
        tabs.add(new AbstractTab(new ResourceModel("location")) {
            @Override
            public Panel getPanel(String panelId) {
                description = description("locationDescription");
                return new LocationPanel(panelId);
            }
        });
        
        tabs.add(new AbstractTab(new ResourceModel("performance")) {
            @Override
            public Panel getPanel(String panelId) {
                description = description("performanceDescription");
                return new PerformancePanel(panelId, queryViewState);
            }
        });
        
        add(new TabbedPanel("tabs", tabs));
    }
    
    String description(String key) {
        return new StringResourceModel(key, this, null).getObject();
    }
}
