#
# Class for GUI current-camera-config.xml
#
var CurrentCameraSettings = {
    #
    # Constructor
    #
    new: func {
        var me = {
            parents: [CurrentCameraSettings],
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
    # Geat data used in current-camera-config dialog
    #
    # @return vector  Vector of hash
    #
    cameraData: func {
        var camera = cameras.getCurrent();
        return [
            { name: "popup-tip",                   value: camera.popupTip },
            { name: "show-panel",                  value: camera["panel-show"] },
            { name: "show-panel-type",             value: camera["panel-show-type"] },
            { name: "show-dialog",                 value: camera["dialog-show"] },
            { name: "dialog-name",                 value: camera["dialog-name"] },
            { name: "enable-exec-nasal",           value: camera["enable-exec-nasal"] },
            { name: "enable-RND",                  value: camera["enable-RND"] },
            { name: "enable-DHM",                  value: camera["enable-DHM"] },
            { name: "field-of-view",               value: camera.fov },
            { name: "movement-transition-time",    value: camera.movement.time },
            { name: "adjustment-linear-velocity",  value: camera.adjustment.v[0] },
            { name: "adjustment-angular-velocity", value: camera.adjustment.v[1] },
            { name: "adjustment-filter",           value: camera.adjustment.filter },
            { name: "mlook-sensitivity",           value: camera.mouse_look.sensitivity },
            { name: "mlook-filter",                value: camera.mouse_look.filter },
            { name: "label-bar",                   value: "\"" ~ camera.name ~ "\" Config" },
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
    dialogName: func {
        var dialogName = getprop(g_myNodePath ~ "/dialogs/camera-settings/dialog-name");

        if (me.isShowDialogEnabled()) {
            camGui.closeDialog(1);
            cameras.getCurrent()["dialog-show"] = false;
        }

        cameras.getCurrent()["dialog-name"] = dialogName;
        me.updateValues();
    },

    isExecNasalEnabled: func {
        return getprop(g_myNodePath ~ "/dialogs/camera-settings/enable-exec-nasal");
    },

    #==================================================
    #   Toggle Exec Nasal
    #==================================================
    toggleExecNasal: func {
        var enabled = me.isExecNasalEnabled();

        cameras.getCurrent()["enable-exec-nasal"] = enabled;
        nasal.exec(enabled
            ? nasalConfig.getEntryScript()
            : nasalConfig.getLeaveScript()
        );
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
    applyAdjustmentAangularVelocity: func {
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
};
