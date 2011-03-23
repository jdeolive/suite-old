Ext.namespace("og");

/**
 * Separates out platform spcefic properties and operations.
 */
og.platform = {
    "Windows NT": {
        toURL: function(filePath) {
            return "file:///" + filePath;
        }, 
        name: "Windows"
    },
    
    "Darwin": {
        name: "Mac"
    },
    
    "Linux": {
        name: "Linux"
    }
};
