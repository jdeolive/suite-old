package org.opengeo.data.importer.web;

import org.apache.wicket.ResourceReference;
import org.geoserver.web.GeoServerApplication;

public enum DataIcon {
    FOLDER("img/icons/silk/folder.png"),
    VECTOR("img/icons/geosilk/vector.png"),
    FILE("img/icons/silk/page_white_text.png"),
    FILE_VECTOR("img/icons/geosilk/page_white_vector.png"),
    FILE_RASTER("img/icons/geosilk/page_white_raster.png"),
    DATABASE("img/icons/geosilk/database_vector.png"),
    POSTGIS("img/icons/geosilk/postgis.png");

    ResourceReference icon;

    DataIcon(String iconPath) {
        this.icon = new ResourceReference(GeoServerApplication.class, iconPath);
    }

    public ResourceReference getIcon() {
        return icon;
    }
}
