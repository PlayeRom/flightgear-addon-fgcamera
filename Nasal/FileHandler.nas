#
# Save/Load cameras for current aircraft
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
        var isDefault = false;

        # search for user defined configuration (in fg-home)
        var path = getprop("/sim/fg-home") ~ "/aircraft-data/FGCamera/" ~ aircraft;
        if (call(io.readfile, [path ~ "/" ~ file], nil, nil, var err = []) == nil) {
            # search in aircraft directory
            path = getprop("/sim/aircraft-dir") ~ "/FGCamera/";
            if (call(io.readfile, [path ~ "/" ~ file], nil, nil, var err = []) == nil) {
                # default configuration
                path = me._addonBasePath;
                file = "default-cameras.xml";
                isDefault = true;
            }
        }

        props.copy(io.read_properties(path ~ "/" ~ file), cameraNode);

        cameras.clear();
        var vec = cameraNode.getChildren("camera");
        forindex (var i; vec) {
            cameras.append(vec[i].getValues());
        }

        if (isDefault) {
            me._setDefaultOffsets();
        }

        var version = cameraNode.getChild("version", 0, 1).getValue() or "v1.0";
        logprint(LOG_ALERT, "FGCamera: loaded version: ", version);
        if (version != me._currentVersion) {
            me._migration.upgradeVersion(version);
        }

        var value = cameraNode.getChild("mini-dialog-type", 0, 1).getValue() or "simple";
        setprop(g_myNodePath ~ "/mini-dialog-type", value);

        me._loadBoolOption(cameraNode, true,  "spring-loaded-mouse", "mouse/spring-loaded");
        me._loadBoolOption(cameraNode, true,  "force-look-around-mode-in-fg", "mouse/force-look-around-mode-in-fg");
        me._loadBoolOption(cameraNode, true,  "mini-dialog-enable");
        me._loadBoolOption(cameraNode, false, "mini-dialog-autohide");
        me._loadBoolOption(cameraNode, false, "use-ctrl-with-numkeys");
        me._loadBoolOption(cameraNode, false, "linux-track-handler", "handlers/linux-track");
        me._loadBoolOption(cameraNode, false, "track-ir-handler", "handlers/track-ir");

        cameraNode.remove();
        return cameras.size();
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

        var node = cameraNode.getChild(optionName);
        var value = node == nil ? defaultValue : node.getBoolValue();
        setprop(g_myNodePath ~ "/" ~ propName, value);
    },

    #
    # Load defaults offsets
    #
    # @return void
    #
    _setDefaultOffsets: func {
        forindex (var i; offsetsManager.coords) {
            cameras.getCamera(0).offsets[i] = num(getprop("/sim/view/config/" ~ offsetsManager.coords[i])) or 0;
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

        forindex (var i; cameras.getVector()) {
            foreach (var a; keys(cameras.getCamera(i))) {
                var data = {};
                data[a]  = cameras.getCamera(i)[a];

                node.getChild("camera", i, create).setValues(data);
            }
        }

        node.getChild("version",                      index, create).setValue(me._currentVersion);
        node.getChild("mini-dialog-type",             index, create).setValue(getprop(g_myNodePath ~ "/mini-dialog-type"));
        node.getChild("spring-loaded-mouse",          index, create).setBoolValue(getprop(g_myNodePath ~ "/mouse/spring-loaded"));
        node.getChild("force-look-around-mode-in-fg", index, create).setBoolValue(getprop(g_myNodePath ~ "/mouse/force-look-around-mode-in-fg"));
        node.getChild("mini-dialog-enable",           index, create).setBoolValue(getprop(g_myNodePath ~ "/mini-dialog-enable"));
        node.getChild("mini-dialog-autohide",         index, create).setBoolValue(getprop(g_myNodePath ~ "/mini-dialog-autohide"));
        node.getChild("use-ctrl-with-numkeys",        index, create).setBoolValue(getprop(g_myNodePath ~ "/use-ctrl-with-numkeys"));
        node.getChild("linux-track-handler",          index, create).setBoolValue(getprop(g_myNodePath ~ "/handlers/linux-track"));
        node.getChild("track-ir-handler",             index, create).setBoolValue(getprop(g_myNodePath ~ "/handlers/track-ir"));

        io.write_properties(path ~ "/" ~ file, node);
        node.remove();
    },
};