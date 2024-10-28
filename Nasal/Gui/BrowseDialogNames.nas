#
# Class for GUI browse-dialog-names.xml
#
var BrowseDialogNames = {
    #
    # Constructor
    #
    new: func {
        return {
            parents: [BrowseDialogNames],
            _pathToFiles: g_Addon.basePath ~ "/DialogNames",
        };
    },

    #
    # Called in <open> tag of dialog XML
    #
    open: func {
        me.loadValuesFromFile();
    },

    #
    # Called in <close> tag of dialog XML
    #
    close: func {
    },

    loadValuesFromFile: func {
        var dlgRoot = cmdarg();
        var list = gui.findElementByName(dlgRoot, "dialog-names-list");

        var fileToLoad = me.findFileToLoad();
        if (fileToLoad == nil) {
            return;
        }

        var path = me._pathToFiles ~ "/" ~ fileToLoad ~ ".xml";

        var target = props.globals.getNode(g_myNodePath ~ "/dialogs/browse-dialog-names");
        io.read_properties(path, target);

        list.removeChildren("value");

        foreach (var valueNode; target.getChildren("value")) {
            var value = valueNode.getValue();
            if (value != nil) {
                list.addChild("value").setValue(value);
            }
        }

        fgcommand("dialog-update", props.Node.new({
            "object-name": "dialog-names-list",
            "dialog-name": "browse-dialog-names",
        }));
    },

    #
    # @return string|nil
    #
    findFileToLoad: func () {
        var fgVersion = getprop("/sim/version/flightgear");
        var (major, minor, patch) = split(".", fgVersion);

        var availableFiles = me.getAvailableFiles();
        if (size(availableFiles) == 0) {
            return nil; # nothing found
        }

        # Check major version
        var majorMatches = me.matchVersionToFileName(availableFiles, major ~ "*");
        if (size(majorMatches) == 0) {
            # Any match, return last version file
            return availableFiles[size(availableFiles) - 1];
        }

        # Check major.minor version
        var minorMatches = me.matchVersionToFileName(majorMatches, major ~ "." ~ minor ~ "*");
        if (size(minorMatches) == 0) {
            # Any minor match, return last major
            return majorMatches[size(majorMatches) - 1];
        }

        # Check major.minor.patch version
        var patchMatches = me.matchVersionToFileName(minorMatches, major ~ "." ~ minor ~ "." ~ patch);
        if (size(patchMatches) == 0) {
            # Any patch match, return last minor
            return minorMatches[size(minorMatches) - 1];
        }

        # return last patchMatches
        return patchMatches[size(patchMatches) - 1];
    },

    #
    # @param  vector  fileNames
    # @param  string  version
    # @return vector
    #
    matchVersionToFileName: func (fileNames, version) {
        var matches = [];
        foreach (var fileName; fileNames) {
            if (string.match(fileName, version)) {
                append(matches, fileName);
            }
        }

        return matches;
    },

    getAvailableFiles: func {
        var availableFiles = [];

        var files = directory(me._pathToFiles);
        foreach (var file; files) {
            if (io.is_regular_file(me._pathToFiles ~ "/" ~ file)) {
                # Get file name without extension '.xml'
                file = substr(file, 0, size(file) - size(".xml"));
                append(availableFiles, file);
            }
        }

        return availableFiles;
    },

    selectItemList: func {
        var name = getprop(g_myNodePath ~ "/dialogs/browse-dialog-names/list");
        var vector = split(" ", name);
        var dialogName = vector[0];

        setprop(g_myNodePath ~ "/dialogs/camera-settings/dialog-name", dialogName);

        currentCameraConfig.applyDialogName();
    },
};
