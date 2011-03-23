
// handler for messages posted from client
onmessage = function(e) {
    if (e.message && e.message.collect) {
        collectStats(e.message.config);
    }
};

function getResource(url, username, password) {

    var client = Titanium.Network.createHTTPClient();
    
    client.open("GET", url, false);
    if (username && password) {
        client.setRequestHeader(
            "Authorization", 
            createAuthHeader(username, password)
        );
    }
    client.send(null);
    
    var resource = null;
    try {
        resource = Titanium.JSON.parse(client.responseText);
    } catch(err) {
        // pass
    }

    return resource;

}

function getWorkspaces(config) {
    var url = "http://" + config["suite_host"] + ":" + config["suite_port"] + "/geoserver/rest/workspaces.json";
    var resource = getResource(
        url, config["geoserver_username"], config["geoserver_password"]
    );
    var workspaces = {};
    if (resource && resource.workspaces) {
        var list = resource.workspaces.workspace;
        for (var i=0, ii=list.length; i<ii; ++i) {
            workspaces[list[i].name] = list[i].href;
        }
    }
    return workspaces;
}

function getStoreCount(config) {
    var workspaces = getWorkspaces(config);
    var username = config["geoserver_username"];
    var password = config["geoserver_password"];
    var base = "http://" + config["suite_host"] + ":" + config["suite_port"] + "/geoserver/rest/workspaces/";
    var resource, count = 0;
    for (var name in workspaces) {
        resource = getResource(base + name + "/datastores.json", username, password);
        if (resource && resource.dataStores && resource.dataStores.dataStore) {
            count += resource.dataStores.dataStore.length;
        }
        resource = getResource(base + name + "/coveragestores.json", username, password);
        if (resource && resource.coverageStores && resource.coverageStores.coverageStore) {
            count += resource.coverageStores.coverageStore.length;
        }
    }
    return count;
}

function getLayerCount(config) {
    var url = "http://" + config["suite_host"] + ":" + config["suite_port"] + "/geoserver/rest/layers.json";
    var resource = getResource(
        url, config["geoserver_username"], config["geoserver_password"]
    );
    return resource && resource.layers.layer.length;
}

function getMapCount(config) {
    var resource = getResource(
        "http://" + config["suite_host"] + ":" + config["suite_port"] + "/geoexplorer/maps/"
    );
    return resource && resource.ids.length;
}

function collectStats(config) {    
    var stats = {
        stores: getStoreCount(config),
        layers: getLayerCount(config),
        maps: getMapCount(config)
    };
    postMessage({stats: stats});
}

function createAuthHeader(username, password) {
    var token = username + ":" + password;
    var hash = Base64.encode(token);
    return "Basic " + hash;
};

/**
 *  Base64 encode / decode
 *  The Titanium Desktop SDK doesn't come with base64 encoding/decoding.
 *  Here is an implementation from http://www.webtoolkit.info/
 */
var Base64 = {
 
	// private property
	_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
 
	// public method for encoding
	encode : function (input) {
		var output = "";
		var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
		var i = 0;
 
		input = Base64._utf8_encode(input);
 
		while (i < input.length) {
 
			chr1 = input.charCodeAt(i++);
			chr2 = input.charCodeAt(i++);
			chr3 = input.charCodeAt(i++);
 
			enc1 = chr1 >> 2;
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			enc4 = chr3 & 63;
 
			if (isNaN(chr2)) {
				enc3 = enc4 = 64;
			} else if (isNaN(chr3)) {
				enc4 = 64;
			}
 
			output = output +
			this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
			this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);
 
		}
 
		return output;
	},
 
	// public method for decoding
	decode : function (input) {
		var output = "";
		var chr1, chr2, chr3;
		var enc1, enc2, enc3, enc4;
		var i = 0;
 
		input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
 
		while (i < input.length) {
 
			enc1 = this._keyStr.indexOf(input.charAt(i++));
			enc2 = this._keyStr.indexOf(input.charAt(i++));
			enc3 = this._keyStr.indexOf(input.charAt(i++));
			enc4 = this._keyStr.indexOf(input.charAt(i++));
 
			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;
 
			output = output + String.fromCharCode(chr1);
 
			if (enc3 != 64) {
				output = output + String.fromCharCode(chr2);
			}
			if (enc4 != 64) {
				output = output + String.fromCharCode(chr3);
			}
 
		}
 
		output = Base64._utf8_decode(output);
 
		return output;
 
	},
 
	// private method for UTF-8 encoding
	_utf8_encode : function (string) {
		string = string.replace(/\r\n/g,"\n");
		var utftext = "";
 
		for (var n = 0; n < string.length; n++) {
 
			var c = string.charCodeAt(n);
 
			if (c < 128) {
				utftext += String.fromCharCode(c);
			}
			else if((c > 127) && (c < 2048)) {
				utftext += String.fromCharCode((c >> 6) | 192);
				utftext += String.fromCharCode((c & 63) | 128);
			}
			else {
				utftext += String.fromCharCode((c >> 12) | 224);
				utftext += String.fromCharCode(((c >> 6) & 63) | 128);
				utftext += String.fromCharCode((c & 63) | 128);
			}
 
		}
 
		return utftext;
	},
 
	// private method for UTF-8 decoding
	_utf8_decode : function (utftext) {
		var string = "";
		var i = 0;
		var c = c1 = c2 = 0;
 
		while ( i < utftext.length ) {
 
			c = utftext.charCodeAt(i);
 
			if (c < 128) {
				string += String.fromCharCode(c);
				i++;
			}
			else if((c > 191) && (c < 224)) {
				c2 = utftext.charCodeAt(i+1);
				string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
				i += 2;
			}
			else {
				c2 = utftext.charCodeAt(i+1);
				c3 = utftext.charCodeAt(i+2);
				string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
				i += 3;
			}
 
		}
 
		return string;
	}
 
};
