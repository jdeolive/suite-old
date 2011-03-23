package org.opengeo.geoserver.test;

import java.io.File;
import java.io.IOException;

import org.geoserver.data.test.TestData;

public class ReadOnlyTestSupport extends OpenGeoTestSupport {

    @Override
    protected TestData buildTestData() throws Exception {
        return new ReadOnlyTestData();
    }
    
    static class ReadOnlyTestData implements TestData {

        public File getDataDirectoryRoot() {
            try {
                return new File("../../data_dir").getCanonicalFile();
            } 
            catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        public boolean isTestDataAvailable() {
            return getDataDirectoryRoot().exists();
        }

        public void setUp() throws Exception {
        }

        public void tearDown() throws Exception {
        }
        
    }
}
