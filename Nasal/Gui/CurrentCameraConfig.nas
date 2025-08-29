#
# Class for GUI current-camera-config.xml
#
var CurrentCameraConfig = {
    #
    # Constructor
    #
    new: func {
        var me = {
            parents: [CurrentCameraConfig],
            _listener: nil,
        };

        return me;
    },

    #
    # Called in <open> tag of dialog XML.
    #
    open: func {
        me._listener = setlistener(g_myNodePath ~ "/current-camera/camera-id", func {
            me.updateValues();
        });

        me.updateValues();
    },

    #
    # Called in <close> tag of dialog XML.
    #
    close: func {
        if (me._listener != nil) {
            removelistener(me._listener);
        }
    },

    #
    # Get data used in current-camera-config dialog.
    #
    # @return vector  Vector of hash.
    #
    cameraData: func {
        var camera = cameras.getCurrent();
        return [
            { name: "popup-tip",                   value: camera.popupTip,                  dlgUpdate: true },
            { name: "show-panel",                  value: camera["panel-show"],             dlgUpdate: true },
            { name: "show-panel-type",             value: camera["panel-show-type"],        dlgUpdate: true },
            { name: "show-dialog",                 value: camera["dialog-show"],            dlgUpdate: true },
            { name: "dialog-name",                 value: camera["dialog-name"],            dlgUpdate: true },
            { name: "enable-exec-nasal",           value: camera["enable-exec-nasal"],      dlgUpdate: true },
            { name: "enable-RND",                  value: camera["enable-RND"],             dlgUpdate: true },
            { name: "enable-DHM",                  value: camera["enable-DHM"],             dlgUpdate: true },
            { name: "field-of-view",               value: camera.fov,                       dlgUpdate: true },
            { name: "movement-transition-time",    value: camera.movement.time,             dlgUpdate: true },
            { name: "adjustment-linear-velocity",  value: camera.adjustment.v[0],           dlgUpdate: true },
            { name: "adjustment-angular-velocity", value: camera.adjustment.v[1],           dlgUpdate: true },
            { name: "adjustment-filter",           value: camera.adjustment.filter,         dlgUpdate: true },
            { name: "mlook-sensitivity",           value: camera.mouse_look.sensitivity,    dlgUpdate: true },
            { name: "mlook-filter",                value: camera.mouse_look.filter,         dlgUpdate: true },
            { name: "label-bar",                   value: "\"" ~ camera.name ~ "\" Config", dlgUpdate: true },

            # We also need to update variables from nasal-config.xml here, but only setprop because it's a different window
            { name: "enable-nasal-entry",          value: camera["enable-nasal-entry"],     dlgUpdate: false },
            { name: "enable-nasal-leave",          value: camera["enable-nasal-leave"],     dlgUpdate: false },
            { name: "script-for-entry",            value: camera["script-for-entry"],       dlgUpdate: false },
            { name: "script-for-leave",            value: camera["script-for-leave"],       dlgUpdate: false },
        ];
    },

    updateValues: func {
        foreach (var item; me.cameraData()) {
            setprop(g_myNodePath ~ "/dialogs/camera-settings/" ~ item.name, item.value);

            if (item.dlgUpdate) {
                me.dialogUpdate(item.name);
            }
        }
    },

    dialogUpdate: func (objName) {
        fgcommand("dialog-update", props.Node.new({
            "object-name": objName,
            "dialog-name": "current-camera-config",
        }));
    },

    validateValue: func(value, min, max) {
        var v = num(value);
        if (v != nil) {
            if (v < min or v > max) {
                return nil;
            }
        }
        return v;
    },

    #==================================================
    #   Toggle popupTip
    #==================================================
    togglePopupTip: func {
        var value = getprop(g_myNodePath ~ "/dialogs/camera-settings/popup-tip");

        cameras.getCurrent().popupTip = value;
    },

    #==================================================
    #   Toggle 2d panel
    #==================================================
    toggle2DPanel: func {
        var value = getprop(g_myNodePath ~ "/dialogs/camera-settings/show-panel");
        var selected_type = getprop(g_myNodePath ~ "/dialogs/camera-settings/show-panel-type") or Panel2D.DEFAULT;

        cameras.getCurrent()["panel-show"] = value;
        cameras.getCurrent()["panel-show-type"] = selected_type;
        if (value) {
            Panel2D.showPath(selected_type);
        }
        else {
            Panel2D.hide();
        }
    },

    isShowDialogEnabled: func {
        return getprop(g_myNodePath ~ "/dialogs/camera-settings/show-dialog");
    },

    #==================================================
    #   Toggle dialog
    #==================================================
    toggleDialog: func {
        var value = me.isShowDialogEnabled();

        cameras.getCurrent()["dialog-show"] = value;
        if (value) {
            camGui.showDialog(1);
        }
        else {
            camGui.closeDialog(1);
        }
    },

    #==================================================
    #   Dialog name
    #==================================================
    applyDialogName: func {
        var dialogName = getprop(g_myNodePath ~ "/dialogs/camera-settings/dialog-name");

        if (me.isShowDialogEnabled()) {
            camGui.closeDialog(1);
            cameras.getCurrent()["dialog-show"] = false;
        }

        cameras.getCurrent()["dialog-name"] = dialogName;
        me.updateValues();
    },

    #==================================================
    #   Apply FOV
    #==================================================
    applyFov: func {
        var path  = g_myNodePath ~ "/dialogs/camera-settings/field-of-view";
        var value = getprop(path);
        var min   = 10;
        var max   = 120;

        if (me.validateValue(value, min, max) == nil) {
            value = cameras.getCurrent().fov;
            setprop(path, value);
            me.updateValues();
        }
        else {
            cameras.getCurrent().fov = value;
            setprop("/sim/current-view/field-of-view", value);
        }
    },

    #==================================================
    #   Apply transition time
    #==================================================
    applyMovementTime: func {
        var path  = g_myNodePath ~ "/dialogs/camera-settings/movement-transition-time";
        var value = getprop(path);
        var min   = 0;
        var max   = 10;

        if (me.validateValue(value, min, max) == nil) {
            value = cameras.getCurrent().movement.time;
            setprop(path, value);
            me.updateValues();
        }
        else {
            cameras.getCurrent().movement.time = value;
        }
    },

    #==================================================
    #   Apply linear_velocity
    #==================================================
    applyAdjustmentLinearVelocity: func {
        var path  = g_myNodePath ~ "/dialogs/camera-settings/adjustment-linear-velocity";
        var value = getprop(path);
        var min   = 0.001;
        var max   = 1000;

        if (me.validateValue(value, min, max) == nil) {
            value = cameras.getCurrent().adjustment.v[0];
            setprop(path, value);
            me.updateValues();
        }
        else {
            cameras.getCurrent().adjustment.v[0] = value;
        }
    },

    #==================================================
    #   Apply angular_velocity
    #==================================================
    applyAdjustmentAngularVelocity: func {
        var path  = g_myNodePath ~ "/dialogs/camera-settings/adjustment-angular-velocity";
        var value = getprop(path);
        var min   = 0.01;
        var max   = 360;

        if (me.validateValue(value, min, max) == nil) {
            value = cameras.getCurrent().adjustment.v[1];
            setprop(path, value);
            me.updateValues();
        }
        else {
            cameras.getCurrent().adjustment.v[1] = value;
        }
    },

    #==================================================
    #   Apply adjustment_filter
    #==================================================
    applyAdjustmentFilter: func {
        var path  = g_myNodePath ~ "/dialogs/camera-settings/adjustment-filter";
        var value = getprop(path);
        var min   = 0;
        var max   = 10;

        if (me.validateValue(value, min, max) == nil) {
            value = cameras.getCurrent().adjustment.filter;
            setprop(path, value);
            me.updateValues();
        }
        else {
            cameras.getCurrent().adjustment.filter = value;
        }
    },

    #==================================================
    #   Apply mouse_look_sensitivity
    #==================================================
    applyMouseLookSensitivity: func {
        var path  = g_myNodePath ~ "/dialogs/camera-settings/mlook-sensitivity";
        var value = getprop(path);
        var min   = 0;
        var max   = 10;

        if (me.validateValue(value, min, max) == nil) {
            value = cameras.getCurrent().mouse_look.sensitivity;
            setprop(path, value);
            me.updateValues();
        }
        else {
            cameras.getCurrent().mouse_look.sensitivity = value;
        }
    },

    #==================================================
    #   Apply mouse_look_filter
    #==================================================
    applyMouseLookFilter: func () {
        var path  = g_myNodePath ~ "/dialogs/camera-settings/mlook-filter";
        var value = getprop(path);
        var min   = 0;
        var max   = 10;

        if (me.validateValue(value, min, max) == nil) {
            value = cameras.getCurrent().mouse_look.filter;
            setprop(path, value);
            me.updateValues();
        }
        else {
            cameras.getCurrent().mouse_look.filter = value;
        }
    },

    #==================================================
    #   Toggle DHM
    #==================================================
    toggleDHM: func {
        var value = getprop(g_myNodePath ~ "/dialogs/camera-settings/enable-DHM");

        cameras.getCurrent()["enable-DHM"] = value;
    },

    #==================================================
    #   Toggle RND
    #==================================================
    toggleRND: func {
        var value = getprop(g_myNodePath ~ "/dialogs/camera-settings/enable-RND");

        cameras.getCurrent()["enable-RND"] = value;
    },

    #==================================================
    #   Toggle Exec Nasal
    #==================================================
    toggleExecNasal: func {
        var enabled = me.isExecNasalEnabled();

        cameras.getCurrent()["enable-exec-nasal"] = enabled;

        if (enabled and nasalConfig.isEnableNasalEntry()) {
            nasal.exec(nasalConfig.getEntryScript());
        }
        elsif (!enabled and nasalConfig.isEnableNasalLeave()) {
            nasal.exec(nasalConfig.getLeaveScript());
        }
    },

    isExecNasalEnabled: func {
        return getprop(g_myNodePath ~ "/dialogs/camera-settings/enable-exec-nasal");
    },
};
