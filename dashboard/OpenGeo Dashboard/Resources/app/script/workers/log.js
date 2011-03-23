/**
 * worker whose job is to read the opengeo server log.
 */

function readBuffer(file) {
    var buf = [];
    try {
        for (var line = file.readLine(); line !== null; line=file.readLine()) {
            buf.push(line.toString());
            // only keep the last 1000 lines
            if (buf.length > 1000) {
                buf.shift();
            }
        }        
    } catch (err) {
        buff = ["Unable to read log file: '" + file.nativePath() + "'", err.message];
    }
    if (buf.length === 0) {
        buf = ["Empty log file."];
    }
    return buf.join("\n");
}

function readFile(path) {
    var file = Titanium.Filesystem.getFile(path);
    var message;
    if (file.exists() === true) {
        message = readBuffer(file);
    } else {
        message = "Can't find log file: '" + path + "'";
    }
    postMessage(message);    
}

// handler for messages to worker
onmessage = function(evt) {
    if (evt.message.path) {
        readFile(evt.message.path);
    } else {
        postMessage("bad message to log read worker");
    }
};
