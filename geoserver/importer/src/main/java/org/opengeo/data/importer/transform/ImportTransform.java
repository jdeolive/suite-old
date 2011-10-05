package org.opengeo.data.importer.transform;

import java.io.Serializable;

/**
 * Transformation to apply at some stage of the import.
 * 
 * @author Justin Deoliveira, OpenGeo
 */
public interface ImportTransform extends Serializable {

    boolean stopOnError(Exception e);
}
