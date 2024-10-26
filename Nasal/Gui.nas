#
# GUI loader and handler class
#
var Gui = {
    #
    # Constants
    #
    MENU_NAME        : "fgcamera",
    AUTO_HIDE_ZONE_X : 220,
    AUTO_HIDE_ZONE_Y : 120,

    #
    # Constructor
    #
    # @param hash addon
    # @return me
    #
    new: func(addon) {
        var me = {
            parents        : [Gui],
            _addonBasePath : addon.basePath,

            # Mini dialog variables
            _nodeMiniDialogEnable   : globals.props.getNode(g_myNodePath ~ "/mini-dialog-enable"),
            _nodeMiniDialogType     : globals.props.getNode(g_myNodePath ~ "/mini-dialog-type"),
            _nodeMiniDialogAutoHide : globals.props.getNode(g_myNodePath ~ "/mini-dialog-autohide"),
            _nodeMouseX             : globals.props.getNode("/devices/status/mice/mouse/x"),
            _nodeMouseY             : globals.props.getNode("/devices/status/mice/mouse/y"),
            _nodeSizeY              : globals.props.getNode("/sim/startup/ysize"),
            _miniDialogSimple       : nil,
            _miniDialogSlots        : nil,
            _miniDialogListener     : nil,
        };

        me._load();

        return me;
    },

    #
    # Load all dialogs and menu
    #
    # @return void
    #
    _load: func {
        me._createDialogs();
        me._appendToMenu();

        fgcommand("gui-redraw");

        me._createMiniDialogs();
    },

    #
    # Crate all GUI dialogs
    #
    # @return void
    #
    _createDialogs: func {
        var dialogs = [
            { name: "fgcamera-main",           path: "/GUI/" },
            { name: "fgcamera-welcome",        path: "/GUI/" },
            { name: "confirm-delete-fgcamera", path: "/GUI/Main/" },
            { name: "create-new-camera",       path: "/GUI/Main/" },
            { name: "current-camera-config",   path: "/GUI/Main/" },
            { name: "fgcamera-help",           path: "/GUI/Main/" },
            { name: "fgcamera-options",        path: "/GUI/Main/" },
            { name: 'fgcamera-presets',        path: "/GUI/Main/" },
            { name: 'browse-dialog-names',     path: "/GUI/Main/CurrentCameraConfig/" },
            { name: "DHM-settings",            path: "/GUI/Main/CurrentCameraConfig/" },
            { name: "RND-mixer",               path: "/GUI/Main/CurrentCameraConfig/" },
            { name: "nasal-config",            path: "/GUI/Main/CurrentCameraConfig/" },
            { name: "RND-curves",              path: "/GUI/Main/CurrentCameraConfig/Rnd/" },
            { name: "RND-generator",           path: "/GUI/Main/CurrentCameraConfig/Rnd/" },
            { name: "RND-import",              path: "/GUI/Main/CurrentCameraConfig/Rnd/" },
        ];

        foreach (var dialog; dialogs) {
            gui.Dialog.new(
                "/sim/gui/dialogs/" ~ dialog.name ~ "/dialog",
                me._addonBasePath ~ dialog.path ~ dialog.name ~ ".xml"
            );
        }
    },

    #
    # Add FGCamera menu item to View
    #
    # @return void
    #
    _appendToMenu: func {
        var data = {
            label   : "FGCamera",
            name    : Gui.MENU_NAME,
            binding : {
                "command"     : "dialog-show",
                "dialog-name" : "fgcamera-main",
            }
        };

        if (!me._isMenuItemExists()) {
            props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);
        }
    },

    #
    # Prevent to add menu item more than once, e.g. after reload the sim by <Shift-Esc>
    #
    # @return bool
    #
    _isMenuItemExists: func {
        foreach (var item; props.globals.getNode("/sim/menubar/default/menu[1]").getChildren("item")) {
            var name = item.getChild("name");
            if (name != nil and name.getValue() == Gui.MENU_NAME) {
                logprint(LOG_INFO, "Menu item FGCamera already exists");
                return true;
            }
        }

        return false;
    },

    #
    # Show dialog assigned to the current camera
    #
    # @param bool show - If true then force to show
    # @return void
    #
    showDialog: func (show = 0) {
        var camera = cameras.getCurrent();

        if (camera["dialog-show"] or show) {
            gui.showDialog(camera["dialog-name"]);
        }
    },

    #
    # Close dialog assigned to the current camera
    #
    # @param bool show - If true then force to close
    # @return void
    #
    closeDialog: func (close = 0) {
        var camera = cameras.getCurrent();

        if (camera["dialog-show"] or close) {
            fgcommand("dialog-close", props.Node.new({
                "dialog-name": camera["dialog-name"],
            }));
        }
    },

    #
    # Create mini dialogs and set listener for auto hide
    #
    # @return void
    #
    _createMiniDialogs: func {
        me._miniDialogSimple = gui.Dialog.new(
            "/sim/gui/dialogs/fgcamera-mini-dialog-simple/dialog",
            me._addonBasePath ~ "/GUI/MiniDialog/fgcamera-mini-dialog-simple.xml"
        );

        me._miniDialogSlots = gui.Dialog.new(
            "/sim/gui/dialogs/fgcamera-mini-dialog-slots/dialog",
            me._addonBasePath ~ "/GUI/MiniDialog/fgcamera-mini-dialog-slots.xml"
        );

        me.setMiniDialogListener();
    },

    #
    # Set listener for auto hide mini dialog
    #
    # @return void
    #
    setMiniDialogListener: func {
        me._removeMiniDialogListener();

        if (!me._nodeMiniDialogEnable.getBoolValue()) {
            me._closeAllMiniDialogs();
            return;
        }

        if (!me._nodeMiniDialogAutoHide.getBoolValue()) {
            me._closeAllMiniDialogs();
            me._openMiniDialog();
            return;
        }

        me._miniDialogListener = _setlistener("/devices/status/mice/mouse/y", func {
            me._getMousePosY() > (me._nodeSizeY.getIntValue() - Gui.AUTO_HIDE_ZONE_Y) and
            me._getMousePosX() < Gui.AUTO_HIDE_ZONE_X
                ? me._openMiniDialog()
                : me._closeMiniDialog();
        }, 1, 0);
    },

    #
    # Get X position of mouse
    #
    # @return int
    #
    _getMousePosX: func {
        return me._nodeMouseX.getValue() or 0;
    },

    #
    # Get Y position of mouse
    #
    # @return int
    #
    _getMousePosY: func {
        return me._nodeMouseY.getValue() or 0;
    },

    #
    # Remove mini dialog listener
    #
    # @return void
    #
    _removeMiniDialogListener: func {
        if (me._miniDialogListener != nil) {
            removelistener(me._miniDialogListener);
            me._miniDialogListener = nil;
        }
    },

    #
    # Open mini dialog according to type setting
    #
    # @return void
    #
    _openMiniDialog: func {
        if (me._nodeMiniDialogType.getValue() == "slots") {
            if (me._miniDialogSimple.is_open()) {
                # Make sure that 2nd dialog is closed
                me._miniDialogSimple.close();
            }

            if (!me._miniDialogSlots.is_open()) {
                me._miniDialogSlots.open();
            }
        }
        else {
            if (me._miniDialogSlots.is_open()) {
                # Make sure that 2nd dialog is closed
                me._miniDialogSlots.close();
            }

            if (!me._miniDialogSimple.is_open()) {
                me._miniDialogSimple.open();
            }
        }
    },

    #
    # Close mini dialog according to type setting
    #
    # @return void
    #
    _closeMiniDialog: func {
        if (me._nodeMiniDialogType.getValue() == "slots") {
            if (me._miniDialogSlots.is_open()) {
                me._miniDialogSlots.close();
            }
        }
        else {
            if (me._miniDialogSimple.is_open()) {
                me._miniDialogSimple.close();
            }
        }
    },

    #
    # Close all mini dialogs if opened
    #
    # @return void
    #
    _closeAllMiniDialogs: func {
        if (me._miniDialogSimple.is_open()) {
            me._miniDialogSimple.close();
        }

        if (me._miniDialogSlots.is_open()) {
            me._miniDialogSlots.close();
        }
    },
};
