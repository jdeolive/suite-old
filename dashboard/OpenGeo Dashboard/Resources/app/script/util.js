Ext.namespace("og");

og.util = {

    /** api: method[loadSync]
     *  :arg url: ``String``
     *
     *  Syncrhonously load a resource.  This is a workaround for Ext XHR
     *  failures with Titanium.
     */
    loadSync: function(url) {
        var client = new XMLHttpRequest();
        client.open("GET", url, false);
        client.send(null);
        return client.responseText;
    },
    
    getVersionInfo: function() {
        var str = this.loadResourceFile("version.ini");
        var versionInfo = og.util.parseConfig(str);
        return versionInfo;
    },
    
    getBundledConfig: function() {
        var config = og.util.parseConfig(this.loadResourceFile("config.ini"));
        Ext.apply(
            config, og.util.parseConfig(this.loadResourceFile("static.ini"))
        );
        return config;
    },
    
    getUserConfig: function() {
        var config;
        if (window.Titanium) {
            var fs = Titanium.Filesystem;
            var configFile = fs.getFile(
                fs.getUserDirectory().toString(), ".opengeo", "config.ini"
            );
            if (configFile.exists()) {
                config = og.util.parseConfig(configFile.read().toString());
            }
        }
        return config;
    },
    
    loadResourceFile: function(path) {
        var str;
        if (window.Titanium) {
            var fs = Titanium.Filesystem;
            var file = fs.getFile(
                fs.getResourcesDirectory().toString(), path
            );
            if (file.exists()) {
                str = file.read().toString();
            }
        } else {
            str = this.loadSync(path);
        }
        return str;
    },
    
    /** private: method[upgradeConfig]
     *  :arg oldConfig: ``Object`` Existing config.
     *  :arg newVersion: ``String`` New version string.
     *  :returns: ``Object`` Upgraded config.
     *
     *  Upgrades an existing configuration.
     */
    upgradeConfig: function(oldConfig, newVersion) {
        var version = oldConfig["suite_version"] || "1.0.0";
        // grab the bundled config.ini
        var newConfig = og.util.parseConfig(this.loadResourceFile("config.ini"));
        if (version === "1.0.0") {
            // respect old username, password, port, and stop_port
            Ext.apply(newConfig, {
                geoserver_username: oldConfig["username"] || newConfig["geoserver_username"],
                geoserver_password: oldConfig["password"] || newConfig["geoserver_password"],
                suite_port: oldConfig["port"] || newConfig["suite_port"],
                suite_stop_port: oldConfig["stop_port"] || newConfig["suite_stop_port"]
            });
            // respect custom data_dir
            if (oldConfig["data_dir"] !== newConfig["geoserver_data_dir"]) {
                // osx default data_dir changed between 1.0.0 and 1.9.0
                if (Titanium.Platform.name === "Darwin") {
                    // only update if different than the old default
                    if (oldConfig["data_dir"] !== "/Applications/OpenGeo Suite.app/Contents/Resources/Java/data_dir") {
                        newConfig["geoserver_data_dir"] = oldConfig["data_dir"];
                    }
                } else {
                    newConfig["geoserver_data_dir"] = oldConfig["data_dir"];
                }
            }
        }
        // respect old configuration for all upgrades
        for (var key in oldConfig) {
            if (key in newConfig) {
                newConfig[key] = oldConfig[key];
            }
        }
        // apply static config for all upgrades
        Ext.apply(
            newConfig, og.util.parseConfig(this.loadResourceFile("static.ini"))
        );
        newConfig["suite_version"] = newVersion;
        this.saveConfig(newConfig);
        return newConfig;
    },
    
    /** private: method[parseConfig]
     *  :arg text: ``String``
     *  :returns: ``Object`` A config object.
     *
     *  Parses the contents of a config file into a config object.
     */    
    parseConfig: function(text) {
        var config = {};
        if (text) {
            var lines = text.split(/[\n\r]/);
            var line, pair, key, value, match;
            for (var i=0, len=lines.length; i<len; ++i) {
                line = lines[i].trim();
                if (line) {
                    pair = line.split("=");
                    if (pair.length > 1) {
                        key = pair.shift().trim();
                        value = pair.join("=").trim();
                        config[key] = value;
                    }
                }
            }
        } 
        return config;
    }, 
    
    /** api: method[saveConfig]
     *  :arg config: ``Object``
     *
     *  Saves the current config to config.ini in the users home directory.
     */
    saveConfig: function(config) {
        if (window.Titanium) {
            var fs = Titanium.Filesystem;
            var file = fs.getFile(
                fs.getUserDirectory().toString(), ".opengeo", "config.ini"
            );
            if (!file.parent().exists()) {
                file.parent().createDirectory();
            }
            var lines = [];
            for (key in config) {
                lines.push(key + "=" + config[key]);
            }
            try {
                file.write(lines.join(fs.getLineEnding()));
            } catch (err) {
                Ext.Msg.alert(
                    "Error", "Could not write to " + file.toString()
                );
            }
        }
    }, 
    
    /** api: method[tirun]
     *  :arg f: ``Function`` The function to execute.
     *  :arg scope: ``Object`` The function execution scope.
     *  :arg fallback: ``Function`` An optional function to execute if titanium
     *      is not available.
     *
     * Executes a function if running in the titanium environment.
     */
    tirun: function(f, scope, fallback) {
        if (window.Titanium) {
            return f.call(scope);
        }
        else {
            if (fallback) {
                return fallback.call(scope);
            }
            else {
                Ext.Msg.alert("Warning",
                              "Titanium is required for this action.");
            }
        }
    }

};
