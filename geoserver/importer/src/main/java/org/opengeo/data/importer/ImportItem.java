package org.opengeo.data.importer;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import org.geoserver.catalog.LayerInfo;
import org.opengeo.data.importer.transform.ImportTransform;
import org.opengeo.data.importer.transform.TransformChain;

/**
 * A resource (feature type, coverage, etc... ) created during an imported.
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class ImportItem implements Serializable {

    /** serialVersionUID */
    private static final long serialVersionUID = 1L;

    public static enum State {
        PENDING, READY, RUNNING, NO_CRS, NO_BOUNDS, ERROR, COMPLETE;
    }

    /**
     * item id
     */
    long id;

    /**
     * task this item is part of
     */
    ImportTask task;

    /**
     * the layer/resource
     */
    LayerInfo layer;

    /** 
     * state of the resource
     */
    State state = State.PENDING;

    /**
     * Any error associated with the resource
     */
    Exception error;

    /** 
     * transform to apply to this import item 
     */
    TransformChain transform;

    /**
     * various metadata 
     */
    transient Map<Object,Object> metadata;

    public ImportItem() {
    }

    public ImportItem(LayerInfo layer) {
        this.layer = layer;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public ImportTask getTask() {
        return task;
    }

    public void setTask(ImportTask task) {
        this.task = task;
    }

    public LayerInfo getLayer() {
        return layer;
    }

    public void setLayer(LayerInfo layer) {
        this.layer = layer;
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public Exception getError() {
        return error;
    }

    public void setError(Exception error) {
        this.error = error;
    }

    public TransformChain getTransform() {
        return transform;
    }

    public void setTransform(TransformChain transform) {
        this.transform = transform;
    }

    public Map<Object, Object> getMetadata() {
        if (metadata == null) {
            metadata = new HashMap<Object, Object>();
        }
        return metadata;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (id ^ (id >>> 32));
        result = prime * result + ((task == null) ? 0 : task.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        ImportItem other = (ImportItem) obj;
        if (id != other.id)
            return false;
        if (task == null) {
            if (other.task != null)
                return false;
        } else if (!task.equals(other.task))
            return false;
        return true;
    }
}
