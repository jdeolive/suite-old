package org.opengeo.data.importer;

import static org.apache.commons.io.FilenameUtils.getBaseName;
import static org.apache.commons.io.FilenameUtils.getExtension;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.geotools.referencing.CRS;
import org.opengis.referencing.FactoryException;
import org.opengis.referencing.crs.CoordinateReferenceSystem;

public class SpatialFile extends FileData {

    /**
     * .prj file
     */
    File prjFile;

    /** supplementary files, like indexes, etc...  */
    List<File> suppFiles = new ArrayList<File>();

    public SpatialFile(File file) {
        super(file);
    }

    public File getPrjFile() {
        return prjFile;
    }

    public void setPrjFile(File prjFile) {
        this.prjFile = prjFile;
    }

    public List<File> getSuppFiles() {
        return suppFiles;
    }

    public List<File> allFiles() {
        ArrayList<File> all = new ArrayList<File>();
        all.add(file);
        if (prjFile != null) {
            all.add(prjFile);
        }
        all.addAll(suppFiles);
        return all;
    }

    @Override
    public void prepare() throws IOException {
        //round up all the files with the same name
        suppFiles = new ArrayList();
        prjFile = null;
        for (File f : file.getParentFile().listFiles()) {
            if (f.equals(file)) {
                continue;
            }

            if (getBaseName(f.getName()).equals(getBaseName(file.getName()))) {
                if ("prj".equalsIgnoreCase(getExtension(f.getName()))) {
                    prjFile = f;
                }
                else {
                    suppFiles.add(f);
                }
            }
        }
        if (format == null) {
            format = DataFormat.lookup(file);
        }

        //fix the prj file (match to official epsg wkt)
        fixPrjFile();
    }

    public void fixPrjFile() throws IOException {
        CoordinateReferenceSystem crs = readPrjToCRS();
        if (crs == null) {
            return;
        }

        try {
            Integer epsgCode = CRS.lookupEpsgCode(crs, false);
            CoordinateReferenceSystem epsgCrs = null;
            
            if (epsgCode == null) {
                epsgCode = CRS.lookupEpsgCode(crs, true);
                if (epsgCode != null) {
                    epsgCrs = CRS.decode("EPSG:" + epsgCode);
                }
                if (epsgCrs != null) {
                    String epsgWKT = epsgCrs.toWKT();
                    FileUtils.writeStringToFile(getPrjFile(), epsgWKT);
                }
            }
        }
        catch (FactoryException e) {
            throw (IOException) new IOException().initCause(e);
        }
    }
    
    public CoordinateReferenceSystem readPrjToCRS() throws IOException {
        File prj = getPrjFile();
        if (prj == null || !prj.exists()) {
            return null;
        }
        
        String wkt = FileUtils.readFileToString(prj);
        try {
            return CRS.parseWKT(wkt);
        } 
        catch (Exception e) {
            throw (IOException) new IOException().initCause(e);
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + ((suppFiles == null) ? 0 : suppFiles.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (!super.equals(obj))
            return false;
        if (getClass() != obj.getClass())
            return false;
        SpatialFile other = (SpatialFile) obj;
        if (suppFiles == null) {
            if (other.suppFiles != null)
                return false;
        } else if (!suppFiles.equals(other.suppFiles))
            return false;
        return true;
    }
}
