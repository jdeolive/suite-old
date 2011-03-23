package org.opengeo.analytics.web;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.apache.wicket.Component;
import org.apache.wicket.ajax.AjaxEventBehavior;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.behavior.AttributeAppender;
import org.apache.wicket.behavior.SimpleAttributeModifier;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.opengeo.analytics.View;

public class TimeSpanWithZoomPanel extends TimeSpanPanel {

    public TimeSpanWithZoomPanel(String id, IModel<Date> from, IModel<Date> to) {
        super(id, from, to);
    }
    
    @Override
    protected void initComponents() {
        super.initComponents();
        
        List<AjaxLink> zoomLinks = new ArrayList();
        zoomLinks.add(new AjaxLink<View>("hour", new Model<View>(View.HOURLY)) {
            @Override
            public void onClick(AjaxRequestTarget target) {
               onZoomChange(getModelObject(), target);
            } 
        });
        zoomLinks.add(new AjaxLink<View>("day", new Model<View>(View.DAILY)) {
            @Override
            public void onClick(AjaxRequestTarget target) {
                onZoomChange(getModelObject(), target);
            }
        });
        zoomLinks.add(new AjaxLink<View>("week", new Model<View>(View.WEEKLY)) {
            @Override
            public void onClick(AjaxRequestTarget target) {
                onZoomChange(getModelObject(), target);
            }
        });
        zoomLinks.add(new AjaxLink<View>("month", new Model<View>(View.MONTHLY)) {
            @Override
            public void onClick(AjaxRequestTarget target) {
                onZoomChange(getModelObject(), target);
            }
        });
        for (AjaxLink link : zoomLinks) {
            add(link);
        }
        setMutuallyExclusive(zoomLinks, 
            Arrays.asList("button button-hour", "button button-day", "button button-week", 
                "button button-month"), zoomLinks.get(1));
    }
    
    protected void onZoomChange(View view, AjaxRequestTarget target) {
    }
    
    void setMutuallyExclusive(List<AjaxLink> links, List<String> classes, AjaxLink initial) {
        for (int i = 0; i < links.size(); i++) {
            AjaxLink link = links.get(i);
            link.add(new MutuallyExclusingBehaviour("onclick", link, links, classes));
        }
        initial.add(new AttributeAppender("class", new Model("active"), " "));
    }
    
    static class MutuallyExclusingBehaviour extends AjaxEventBehavior {

        List<AjaxLink> group;
        AjaxLink self;
        List<String> classes;
        
        public MutuallyExclusingBehaviour(
            String event, AjaxLink self, List<AjaxLink> group, List<String> classes) {
            
            super(event);
            this.self = self;
            this.group = group;
            this.classes = classes;
        }

        @Override
        protected void onEvent(AjaxRequestTarget target) {
            self.onClick(target);
            
            self.add(new AttributeAppender("class", new Model("active"), " "));
            target.addComponent(self);
        
            for (int i = 0; i < group.size(); i++) {
                Component c = group.get(i);
                if (c == self) continue;
                
                String clazz = classes.get(i);
                c.add(new SimpleAttributeModifier("class", clazz));
                target.addComponent(c);
            }
        }
    }
    

}
