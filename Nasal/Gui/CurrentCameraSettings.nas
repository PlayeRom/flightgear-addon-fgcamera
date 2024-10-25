#
# Nasal for GUI current-camera-config.xml
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

    calcData: func {
        var camera = cameras.getCurrent();
        return [
            [ "popup-tip"                  , camera.popupTip                  ],
            [ "show-panel"                 , camera["panel-show"]             ],
            [ "show-panel-type"            , camera["panel-show-type"]        ],
            [ "show-dialog"                , camera["dialog-show"]            ],
            [ "dialog-name"                , camera["dialog-name"]            ],
            [ "enable-RND"                 , camera["enable-RND"]             ],
            [ "enable-DHM"                 , camera["enable-DHM"]             ],
            [ "field-of-view"              , camera.fov                       ],
            [ "movement-transition-time"   , camera.movement.time             ],
            [ "adjustment-linear-velocity" , camera.adjustment.v[0]           ],
            [ "adjustment-angular-velocity", camera.adjustment.v[1]           ],
            [ "adjustment-filter"          , camera.adjustment.filter         ],
            [ "mlook-sensitivity"          , camera.mouse_look.sensitivity    ],
            [ "mlook-filter"               , camera.mouse_look.filter         ],
            [ "label-bar"                  , "\"" ~ camera.name ~ "\" Config" ],
        ];
    },

    updateValues: func {
        foreach (var a; var data = me.calcData()) { #?
            setprop(g_myNodePath ~ "/dialogs/camera-settings/" ~ a[0], a[1]);
            me.dialogUpdate(a[0]);
        }
    },

    dialogUpdate: func (dlgObj = nil) {
        var hash = {
            "object-name" : dlgObj,
            "dialog-name" : "current-camera-config"
        };
        fgcommand("dialog-update", props.Node.new(hash));
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
        } else {
            Panel2D.hide();
        }
    },

    #==================================================
    #   Toggle dialog
    #==================================================
    toggleDialog: func {
        var value = getprop(g_myNodePath ~ "/dialogs/camera-settings/show-dialog");

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

        if (getprop(g_myNodePath ~ "/dialogs/camera-settings/show-dialog")) {
            camGui.closeDialog(1);
            cameras.getCurrent()["dialog-show"] = false;
        }

        cameras.getCurrent()["dialog-name"] = dialogName;
        #camGui.showDialog();
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
