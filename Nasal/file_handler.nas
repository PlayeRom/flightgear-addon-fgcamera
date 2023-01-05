#
# Save/Load camers for current aircraft
#
var FileHandler = {
    #
    # Constructor
    #
    # @param hash addon
    # @return me
    #
    new: func(addon) {
        var me = {
            parents         : [FileHandler],
            _migration      : Migration.new(),
            _currentVersion : addon.version.str(),
            _addonBasePath  : addon.basePath,
        };

        me._loadCameras();

        return me;
    },

    #
    # Load cameras from the file for the current aircraft
    #
    # @return int - Number of loaded cameras
    #
    _loadCameras: func {
        var aircraft  = getprop("/sim/aircraft");
        var file = aircraft ~ ".xml";
        var cameraNode = props.Node.new();
        var isDefault = 0;

        # search for user defined configuration (in fg-home)
        var path = getprop("/sim/fg-home") ~ "/aircraft-data/FGCamera/" ~ aircraft;
        if (call(io.readfile, [path ~ "/" ~ file], nil, nil, var err = []) == nil) {
            # search in aircraft directory
            path = getprop("/sim/aircraft-dir") ~ "/FGCamera/";
            if (call(io.readfile, [path ~ "/" ~ file], nil, nil, var err = []) == nil) {
                # default configuration
                path = me._addonBasePath;
                file = "default-cameras.xml";
                isDefault = 1;
            }
        }

        props.copy(io.read_properties(path ~ "/" ~ file), cameraNode);

        cameras = [];
        var vec = cameraNode.getChildren("camera");
        forindex (var i; vec) {
            append(cameras, vec[i].getValues());
        }

        if (isDefault) {
            me._setDefaultOffsets();
        }

        var version = cameraNode.getChild("version", 0, 1).getValue() or "v1.0";
        print("Loaded cameras version: ", version);
        if (version != me._currentVersion) {
            me._migration.upgradeVersion(version);
        }

        me._loadBoolOption(cameraNode, 1, "spring-loaded-mouse", "mouse/spring-loaded");
        me._loadBoolOption(cameraNode, 1, "mini-dialog-enable");
        me._loadBoolOption(cameraNode, 0, "mini-dialog-autohide");
        me._loadBoolOption(cameraNode, 0, "use-ctrl-with-numkeys");

        var value = cameraNode.getChild("mini-dialog-type", 0, 1).getValue() or "simple";
        setprop("/sim/fgcamera/" ~ "mini-dialog-type", value);

        cameraNode.remove();
        return size(cameras);
    },

    #
    # Load single boolean option
    #
    # @param hash cameraNode - Node object
    # @param bool defaultValue
    # @param string optionName
    # @param string|nil propName
    # @return void
    #
    _loadBoolOption: func(cameraNode, defaultValue, optionName, propName = nil) {
        if (propName == nil) {
            propName = optionName;
        }

        var value = cameraNode.getChild(optionName, 0, 1).getBoolValue() or defaultValue;
        setprop("/sim/fgcamera/" ~ propName, value);
    },

    #
    # Load defaults offsets
    #
    # @return void
    #
    _setDefaultOffsets: func {
        forindex (var i; manager._list) {
            cameras[0].offsets[i] = num(getprop("/sim/view/config/" ~ manager._list[i])) or 0;
        }
    },

    #
    # Save cameras to the file for the current aircraft
    #
    # @return void
    #
    saveCameras: func {
        var aircraft = getprop("/sim/aircraft");
        var path     = getprop("/sim/fg-home") ~ "/aircraft-data/FGCamera/" ~ aircraft;
        var file     = aircraft ~ ".xml";
        var node     = props.Node.new();
        var index    = 0; # default child index
        var create   = 1;

        forindex (var i; cameras) {
            foreach (var a; keys(cameras[i]) ) {
                var data = {};
                data[a]  = cameras[i][a];

                node.getChild("camera", i, create).setValues(data);
            }
        }

        node.getChild("version",               index, create).setValue(me._currentVersion);
        node.getChild("mini-dialog-type",      index, create).setValue(getprop("/sim/fgcamera/mini-dialog-type"));
        node.getChild("spring-loaded-mouse",   index, create).setBoolValue(getprop("/sim/fgcamera/mouse/spring-loaded"));
        node.getChild("mini-dialog-enable",    index, create).setBoolValue(getprop("/sim/fgcamera/mini-dialog-enable"));
        node.getChild("mini-dialog-autohide",  index, create).setBoolValue(getprop("/sim/fgcamera/mini-dialog-autohide"));
        node.getChild("use-ctrl-with-numkeys", index, create).setBoolValue(getprop("/sim/fgcamera/use-ctrl-with-numkeys"));

        io.write_properties(path ~ "/" ~ file, node);
        node.remove();
    },
};