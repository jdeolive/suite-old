package org.opengeo.jetty;

import java.io.File;

import org.ini4j.Wini;

/**
 * Wrapper around Jetty main which reads the configuration file prior to starting jetty.
 * 
 * @author Justin Deoliveira, OpenGeo
 *
 */
public class Start {

    public static void main(String[] args) throws Exception {
        
        File ogConfigDir = new File(System.getProperty("user.home")+File.separator+".opengeo");
        if (!ogConfigDir.exists() ) {
            ogConfigDir.mkdir();
        }
        
        if (!ogConfigDir.exists()) {
            System.err.print("Could not create configuration directory " + ogConfigDir.getCanonicalPath() );
            System.exit(1);
        }
        
        Wini ini = null;
        File f = new File( ogConfigDir, File.separator+"config.ini");
        
        if (f.exists()) {
            ini = new Wini(f);
        }
        else {
            ini = new Wini();
            System.out.println(f.getAbsolutePath() + " not found, continuing with default parameters.");
        }
        
        String startPort = ini.get("?", "suite_port");
        if (startPort != null) {
            System.setProperty("jetty.port", startPort);
        }
        
        String stopPort = ini.get("?", "suite_stop_port");
        if (stopPort == null) {
            stopPort = "8079";
        }
        System.setProperty("STOP.PORT", stopPort);
        System.setProperty("STOP.KEY", "opengeo");
        
        String gsDataDirectory = ini.get("?", "geoserver_data_dir" );
        if (gsDataDirectory == null) {
            //look in config directory
            File dd = new File( ogConfigDir, "data_dir");
            if (!dd.exists()) {
                //try in directory we are running in
                dd = new File("data_dir");
            }
             
            if (dd.exists()) {
                gsDataDirectory = dd.getCanonicalPath();
            }
        }
        if (gsDataDirectory != null) {
            System.setProperty("GEOSERVER_DATA_DIR", gsDataDirectory);
        }

        // initialize the location where gxp writes it data
        String gxpDataDirectory = ini.get("?", "geoexplorer_data_dir");
        if (gxpDataDirectory == null) {
            gxpDataDirectory = ogConfigDir.getCanonicalPath();
        }
        
        System.setProperty("GEOEXPLORER_DATA", gxpDataDirectory);
        
        org.mortbay.start.Main.main(args);
    }
}
