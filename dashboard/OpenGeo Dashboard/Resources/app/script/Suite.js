Ext.namespace("og");

og.Suite = Ext.extend(Ext.util.Observable, {
    
    /** api: property[statusInterval]
     *  ``Number``
     *  Time in milliseconds between service status checks.  Default is 2500.
     */
    statusInterval: 2500,
    
    /** api: property[timeout]
     *  ``Number``
     *  Time in milliseconds to wait before givin up on the Suite starting.
     *  Default is 300000 (five minutes).
     */
    timeout: 300000,
    
    /** api: property[config]
     *  ``Object``
     *  The suite configuration.
     */
    config: null,
    
    /** api: property[status]
     *  ``Number``
     *  The HTTP status code for the service this depends on.  Unset by
     *  default.
     */
    status: -1, 
    
    /** api: property[online]
     *  ``Boolean``
     *  Flag indicating if the suite is running. True if the suite is running,
     *  false if the suite is not running, and null if the state is unknown.
     */
    online: null,
    
    constructor: function(config) {
        this.initialConfig = config;
        this.config = Ext.apply({}, config);
        
        this.addEvents(
            /** api: event[changed]
             *  Fired when the service status changes.  Listeners will be called
             *  with two arguments, the new status and old status codes.
             */
            "changed", 
            
            /** api: event[starting]
             *
             *  Fired when the suite is starting up.
             */
            "starting", 
            
            /** api: event[startfailure]
             *
             *  Fired when the suite starting fails.
             */
            "startfailure", 
            
            /** api: event[started]
             *
             *  Fired when the suite has started.
             */
            "started", 
          
            /** api: event[starting]
             *
             *  Fired when the suite is shuttind down.
             */
            "stopping", 
            
            /** api: event[stopped]
             *
             *  Fired when the suite has been stopped.
             */
            "stopped"  
        );
        this.on({
            changed: function(newStatus, oldStatus) {
                if (newStatus >= 200 && newStatus < 300) {
                    //online
                    this.fireEvent("started");
                }
                else {
                    //offline
                    this.fireEvent("stopped");
                }
            },
            started: function() {
                this.online = true;
            },
            stopping: function() {
                this.online = false;
            },
            stopped: function() {
                this.online = false;
            }, 
            scope: this
        });
    }, 
    
    /**
     * api: method[getLogFile]
     * :return: ``String`` The absolute path to the log file.
     *
     * Returns the location of the suite log file.
     */
    getLogFile: function() {
        return og.util.tirun(
            function() {
                var fs = Titanium.Filesystem;
                var home = fs.getUserDirectory();
                var f = fs.getFile(
                    home.nativePath(), ".opengeo", "logs", "opengeosuite.log");
                return f.nativePath();
            }, 
            this, 
            function() {
                return this.config["suite_dir"] + "/logs/opengeosuite.log";
            }
        );
    }, 
    
    /** api: method[run]
     *
     *  Starts the opengeo suite monitor.
     */
    run: function() {
        if (window.Titanium) {
            window.setInterval(
                this.monitor.createDelegate(this),
                this.statusInterval
            );
            this.monitor();
        } else {
            this.fireEvent("started");
        }
    }, 
    
    /** private: method[monitor]
     * 
     *  Monitors the status of the suite.
     */
    monitor: function() {
        var port = this.config["suite_port"] || "80";
        var url = "http://" + this.config["suite_host"] + ":" + port + "/dashboard/version.ini"
        var client = new XMLHttpRequest();
        client.open("HEAD", url);
        client.onreadystatechange = (function() {
            if(client.readyState === 4) {
                var status = parseInt(client.status, 10);
                if (status !== this.status) {
                    this.fireEvent("changed", status, this.status);
                }
                this.status = status;
            }
        }).createDelegate(this);
        client.send();
    },
    
    /** api: method[start]
     *
     *  Starts the suite.
     */
    start: function() {
        if (window.Titanium) {
            
            if (this.startProcess) {
                try {
                    this.startProcess.terminate();                    
                } catch (err) {
                    // pass
                }
                delete this.startPorcess;
            }
            
            // check for port conflict via HTTP
            var client = new XMLHttpRequest();
            var port = this.config["suite_port"];
            var host = this.config["suite_host"];
            var time = (new Date).getTime();
            var url = "http://" + host + (port ? ":" + port : "") + "/?t=" + time;
            client.open("GET", url, false);
            try {
                client.send(null);
            } catch (err) {
                // pass
            }
            if (client.status > 0) {
                this.fireEvent(
                    "startfailure",
                    "There is another service running on the Suite's primary " +
                    "service port (" + port + ").  Go to the Preferences page " +
                    "and set the primary service port to something unoccupied."
                );
                this.fireEvent("stopped");
                return false;
            }
            
            // check that the Suite executable exists
            var exe = this.config["suite_exe"];
            var file = Titanium.Filesystem.getFile(exe);
            if (!file.exists()) {
                this.fireEvent(
                    "startfailure",
                    "The Suite executable (" + exe + ") cannot be found. " +
                    "The 'suite_exe' value must be set in your config.ini to a " +
                    "valid executable."
                );
                this.fireEvent("stopped");
                return false;
            }
            
            this.startProcess = Titanium.Process.createProcess(
                [this.config["suite_exe"], "start"]
            );

            // don't let the user wait forever
            var timerId = window.setTimeout(
                (function() {
                    if (!this.online) {
                        // we've waited long enough
                        this.fireEvent(
                            "startfailure",
                            "Giving up on starting the Suite as it is taking " +
                            "longer than expected.  Check the Suite logs for " +
                            "detail."
                        );
                        try {
                            this.startProcess.terminate();
                        } catch (err) {
                            // pass
                        }
                        this.stop(true);
                    }
                }).createDelegate(this), 
                this.timeout
            );

            var removeListener = function() { 
                window.clearTimeout(timerId);
            };

            this.on({
                started: removeListener,
                stopping: removeListener,
                scope: this
            });
            this.startProcess.launch();
            this.fireEvent("starting");

        }
    }, 
    
    /** api: method[stop]
     *  :arg hard: ``Boolean``
     *
     *  Stops the suite.  A hard stop will fire 'stopped' immediately after
     *  firing 'stopping'.  This is required if stop is called after a start
     *  failure.
     */
    stop: function(hard) {
        og.util.tirun(function() {
            var p = Titanium.Process.createProcess({
                args: [this.config["suite_exe"], "stop"]
            });
            p.launch();

            this.fireEvent("stopping");
            if (hard) {
                this.fireEvent("stopped");
            }
        }, this);
    }

});
