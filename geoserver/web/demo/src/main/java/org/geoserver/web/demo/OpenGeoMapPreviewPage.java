/* Copyright (c) 2001 - 2007 TOPP - www.openplans.org. All rights reserved.
 * This code is licensed under the GPL 2.0 license, available at the root
 * application directory.
 */
package org.geoserver.web.demo;

import static org.geoserver.ows.util.ResponseUtils.*;
import static org.geoserver.web.demo.OpenGeoPreviewProvider.*;

import org.apache.wicket.Component;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.image.Image;
import org.apache.wicket.markup.html.link.ExternalLink;
import org.apache.wicket.markup.html.panel.Fragment;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.geoserver.web.GeoServerBasePage;
import org.geoserver.web.demo.PreviewLayer.PreviewLayerType;
import org.geoserver.web.wicket.GeoServerTablePanel;
import org.geoserver.web.wicket.GeoServerDataProvider.Property;

/**
 * Shows a paged list of the available layers and points to previews in various formats
 */
@SuppressWarnings("serial")
public class OpenGeoMapPreviewPage extends GeoServerBasePage {

    OpenGeoPreviewProvider provider = new OpenGeoPreviewProvider();

    GeoServerTablePanel<PreviewLayer> table;

    public OpenGeoMapPreviewPage() {
        // build the table
        table = new GeoServerTablePanel<PreviewLayer>("table", provider) {

            @Override
            protected Component getComponentForProperty(String id, final IModel itemModel,
                    Property<PreviewLayer> property) {
                PreviewLayer layer = (PreviewLayer) itemModel.getObject();

                if (property == TYPE) {
                    Fragment f = new Fragment(id, "iconFragment", OpenGeoMapPreviewPage.this);
                    f.add(new Image("layerIcon", layer.getTypeSpecificIcon()));
                    return f;
                } else if (property == NAME) {
                    return new Label(id, property.getModel(itemModel));
                } else if (property == TITLE) {
                    return new Label(id, property.getModel(itemModel));
                } else if (property == OL) {
                    final String olUrl = layer.getWmsLink() + "&format=application/openlayers";
                    Fragment f = new Fragment(id, "newpagelink", OpenGeoMapPreviewPage.this);
                    f.add(new ExternalLink("link", new Model(olUrl), new Model("OpenLayers")));
                    return f;
                } else if (property == GE) {
                    final String kmlUrl = "../wms/kml?layers=" + layer.getName();
                    Fragment f = new Fragment(id, "exlink", OpenGeoMapPreviewPage.this);
                    f.add(new ExternalLink("link", new Model(kmlUrl),  new Model("Google Earth")));
                    return f;
                } else if (property == STYLER) {
                    if(layer.getType() == PreviewLayerType.Group || layer.getType() == PreviewLayerType.Raster) {
                        return new Label(id, "");
                    } else {
                        // styler link
                        final String stylerUrl = "../www/styler/index.html?layer=" + urlEncode(layer.getName());
                        Fragment f = new Fragment(id, "newpagelink", OpenGeoMapPreviewPage.this);
                        f.add(new ExternalLink("link", new Model(stylerUrl),  new Model("Styler")));
                        return f;
                    }
                }
                
                return null;
            }

        };
        table.setOutputMarkupId(true);
        add(table);
    }

}
