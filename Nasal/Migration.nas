#
# Cameras migration class
#
var Migration = {
    #
    # Constructor
    #
    # @return me
    #
    new: func() {
        return { parents: [Migration] };

        # var versions = ["1.0", "1.1", "1.2", "1.2.1", "1.2.2", "1.2.3"];
    },

    #
    # Upgrade cameras from given version to current one
    #
    # @param string oldVersion
    # @return void
    #
    upgradeVersion: func (oldVersion) {
        var versions = me._getVersionsVector(oldVersion);
        if (size(versions) < 1) {
            return;
        }

        logprint(LOG_INFO, "FGCamera: upgrading camera data to the newest version");

        var versionItems = me._getVersionsItems();

        foreach (var version; versions) {
            foreach (var item; keys(versionItems[version])) {
                forindex (var i; cameras.getVector()) {
                    cameras.getCamera(i)[item] = versionItems[version][item];
                }
            }
        }
    },

    #
    # Get vector of versions according to given version
    #
    # @param string version
    # @return vector
    #
    _getVersionsVector: func (version) {
        if (version == "1.0") return ["v1.0", "v1.1", "v1.2.1"];
        if (version == "1.1") return ["v1.1", "v1.2.1"];
        if (version == "1.2") return ["v1.2.1"];

        return [];
    },

    #
    # Get hash of versions with new items
    #
    # @return hash
    #
    _getVersionsItems: func {
        return {
            "v1.0": {
                "category"    : 0,
                "popupTip"    : 1,
                "dialog-show" : 0,
                "dialog-name" : "",
            },

            "v1.1": {
                "panel-show"          : 0,
                "enable-head-tracker" : 0,
            },

            "v1.2.1": {
                "panel-show-type"	: "",
            },
        };
    },
};
