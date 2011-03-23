package org.opengeo.analytics.web;

import java.util.Date;

import org.apache.wicket.Page;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.form.AjaxButton;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.PropertyModel;
import org.geoserver.monitor.Query;
import org.opengeo.analytics.AverageTotalTimeAggregator;
import org.opengeo.analytics.PerformanceLineChart;
import org.opengeo.analytics.View;

public class PerformancePanel extends Panel {

    Query query;
    View zoom;
    
    TimeSpanWithZoomPanel timeSpanPanel;
    ChartPanel chartPanel;
    RequestDataTablePanel slowestRequestTable, largestRequestTable;
    
    public PerformancePanel(String id, Query query) {
        super(id);
        this.query = query;
        this.zoom = View.DAILY;
        
        initComponents();
        handleZoomChange(zoom, new AjaxRequestTarget(new Page() {}));
    }
    
    void initComponents() {
        Form form = new Form("form");
        add(form);
        
        timeSpanPanel = new TimeSpanWithZoomPanel("timeSpan", 
            new PropertyModel<Date>(query, "fromDate"), new PropertyModel<Date>(query, "toDate")) {
            protected void onZoomChange(View view, AjaxRequestTarget target) {
                handleZoomChange(view, target);
            };
        };
        form.add(timeSpanPanel);
        form.add(new AjaxButton("refresh", form) {
            @Override
            protected void onSubmit(AjaxRequestTarget target, Form<?> form) {
                handleZoomChange(zoom, target);
            }
        });
        
        chartPanel = new ChartPanel("chart");
        form.add(chartPanel);
        
        SlowestRequestProvider slowestProvider = new SlowestRequestProvider(query);
        form.add(slowestRequestTable = new RequestDataTablePanel("slowestRequests", slowestProvider)); 
        slowestRequestTable.setOutputMarkupId(true);
        slowestRequestTable.setPageable(false);
        
        LargestResponseProvider largestProvider = new LargestResponseProvider(query);
        form.add(largestRequestTable = new RequestDataTablePanel("largestResponses", largestProvider)); 
        largestRequestTable.setOutputMarkupId(true);
        largestRequestTable.setPageable(false);
    }
    
    void handleZoomChange(View zoom, AjaxRequestTarget target) {
        this.zoom = zoom;
        
        AverageTotalTimeAggregator agg = new AverageTotalTimeAggregator(query, zoom);
        Analytics.monitor().query(agg.getQuery(), agg);
        
        PerformanceLineChart chart = new PerformanceLineChart();
        chart.setContainer(chartPanel.getMarkupId());
        chart.setFrom(query.getFromDate());
        chart.setTo(query.getToDate());
        chart.setSteps(10);
        chart.setWidth(550);
        chart.setHeight(300);
        chart.setZoom(zoom);
        chart.setTimeData(agg.getAverageTimeData());
        chart.setThroughputData(agg.getAverageThroughputData());
        
        chartPanel.setChart(chart);
        target.addComponent(chartPanel);
    }

}
