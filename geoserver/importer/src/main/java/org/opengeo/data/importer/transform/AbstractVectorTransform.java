package org.opengeo.data.importer.transform;

public class AbstractVectorTransform implements VectorTransform {

    public boolean stopOnError(Exception e) {
        return true;
    }

}
