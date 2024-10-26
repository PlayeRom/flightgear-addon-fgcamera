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
                # items = "DHM", "enable-exec-nasal", etc.
                forindex (var i; cameras.getVector()) {
                    # Check if the name exists, if it does, do not insert a default
                    # one so as not to overwrite values that may already exist
                    if (!view.hasmember(cameras.getCamera(i), item)) {
                        cameras.getCamera(i)[item] = me.deepHashCopy(versionItems[version][item]);
                    }
                }
            }
        }
    },

    #
    # Get copy of the given hash
    #
    # @param  hash|string|double|int  hash  Hash to copy (or any value)
    # @retrun hash  New instance of hash
    #
    deepHashCopy: func (hash) {
        if (typeof(hash) != "hash") {
            return hash;
        }

        var newHash = {};
        foreach (var key; keys(hash)) {
            if (typeof(hash[key]) == "hash") {
                newHash[key] = me.deepHashCopy(hash[key]);
            }
            else {
                newHash[key] = hash[key];
            }
        }

        return newHash;
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
        if (version == "1.2.1"
            or version == "1.2.2"
            or version == "1.2.3"
            or version == "1.2.4"
            or version == "1.2.5"
            or version == "1.2.6"
        ) {
            return ["v1.2.7"];
        }

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
                "panel-show-type" : "",
            },

            "v1.2.7": {
                "enable-exec-nasal"     : 0,
                "enable-nasal-entry"    : 0,
                "enable-nasal-leave"    : 0,
                "script-for-entry"      : "",
                "script-for-leave"      : "",
                "DHM": {
                    "head-mass"         : 10,
                    "g-load-release"    : 0,
                    "x-axis": {
                        "constant-g"    : 0.5,
                        "impulse-g"     : 0.4,
                        "head-bank"     : 50,
                        "damping"       : 30,
                        "movement-limit": 0.05,
                    },
                    "y-axis": {
                        "constant-g"    : 0.05,
                        "impulse-g"     : 0.2,
                        "head-pitch"    : 50,
                        "damping"       : 30,
                        "movement-limit": 0.025,
                    },
                    "z-axis": {
                        "constant-g"    : 0.25,
                        "impulse-g"     : 0,
                        "damping"       : 50,
                        "movement-limit": 0.05,
                    },
                },
            },
        };
    },
};
