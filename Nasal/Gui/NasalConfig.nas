#
# Class for GUI nasal-config.xml
#
var NasalConfig = {
    #
    # Constructor
    #
    new: func {
        var me = {
            parents: [NasalConfig],
            propScriptForEntry: g_myNodePath ~ "/dialogs/camera-settings/script-for-entry",
            propScriptForLeave: g_myNodePath ~ "/dialogs/camera-settings/script-for-leave",
            _listener: nil,
        };

        return me;
    },

    #
    # Called in <open> tag of dialog XML
    #
    open: func {
        me._listener = setlistener(g_myNodePath ~ "/current-camera/camera-id", func {
            me.updateValues();
        });

        me.updateValues();
    },

    #
    # Called in <close> tag of dialog XML
    #
    close: func {
        if (me._listener != nil) {
            removelistener(me._listener);
        }
    },

    #
    # Geat data used in nasal-config dialog
    #
    # @return vector  Vector of hash
    #
    cameraData: func {
        var camera = cameras.getCurrent();
        return [
            { name: "enable-nasal-entry", value: camera["enable-nasal-entry"] },
            { name: "enable-nasal-leave", value: camera["enable-nasal-leave"] },
            { name: "script-for-entry",   value: camera["script-for-entry"] },
            { name: "script-for-leave",   value: camera["script-for-leave"] },
        ];
    },

    updateValues: func {
        foreach (var item; me.cameraData()) {
            setprop(g_myNodePath ~ "/dialogs/camera-settings/" ~ item.name, item.value);

            me.dialogUpdate(item.name);
        }
    },

    dialogUpdate: func (objName) {
        fgcommand("dialog-update", props.Node.new({
            "object-name": objName,
            "dialog-name": "nasal-config",
        }));
    },

    isEnableNasalEntry: func { return getprop(g_myNodePath ~ "/dialogs/camera-settings/enable-nasal-entry"); },
    isEnableNasalLeave: func { return getprop(g_myNodePath ~ "/dialogs/camera-settings/enable-nasal-leave"); },

    toggleNasalEntry: func {
        var enabledNasal = currentCameraConfig.isExecNasalEnabled();
        var enabledEntry = me.isEnableNasalEntry();

        cameras.getCurrent()["enable-nasal-entry"] = enabledEntry;
        if (enabledNasal and enabledEntry) {
            nasal.exec(me.getEntryScript());
        }
    },

    toggleNasalLeave: func {
        var enabledNasal = currentCameraConfig.isExecNasalEnabled();
        var enabledLeave = me.isEnableNasalLeave();

        cameras.getCurrent()["enable-nasal-leave"] = enabledLeave;
        if (enabledNasal and enabledLeave) {
            nasal.exec(me.getLeaveScript());
        }
    },

    getEntryScript: func { return getprop(me.propScriptForEntry) },
    getLeaveScript: func { return getprop(me.propScriptForLeave) },

    #
    # Update entry script to camera and update dialog
    #
    applyScriptForEntry: func {
        var script = me.getEntryScript();

        if (currentCameraConfig.isExecNasalEnabled()) {
            nasal.exec(script);
        }

        cameras.getCurrent()["script-for-entry"] = script;
        me.updateValues();
    },

    #
    # Update leave script to camera and update dialog
    #
    applyScriptForLeave: func {
        var script = me.getLeaveScript();

        if (!currentCameraConfig.isExecNasalEnabled()) {
            nasal.exec(script);
        }

        cameras.getCurrent()["script-for-leave"] = script;
        me.updateValues();
    },

    copyEntryScript:  func { me._copyScript(true); },
    pasteEntryScript: func { me._setScript(true, clipboard.getText()); },
    clearEntryScript: func { me._setScript(true); },

    copyLeaveScript:  func { me._copyScript(false); },
    pasteLeaveScript: func { me._setScript(false, clipboard.getText()); },
    clearLeaveScript: func { me._setScript(false); },

    #
    # Copy the content of the script to clipboard
    #
    # @param  bool  entry  True for entry camera action, false for leave camera action
    # @return void
    #
    _copyScript: func (entry) {
        clipboard.setText(entry
            ? me.getEntryScript()
            : me.getLeaveScript());
    },

    #
    # Set property with script code
    #
    # @param  bool  entry  True for entry camera action, false for leave camera action
    # @param  string  script  The content of the script that will be assigned to the property
    # @return void
    #
    _setScript: func(entry, script = "") {
        var prop = entry
            ? me.propScriptForEntry
            : me.propScriptForLeave;

        setprop(prop, script);

        entry
            ? me.applyScriptForEntry()
            : me.applyScriptForLeave();
    },
};
