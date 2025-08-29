var g_Addon = nil;
var g_myNodePath = nil;

#==================================================
#   "Objects"
#==================================================
var offsetsManager = nil;
var mouse          = nil;
var camGui         = nil;
var fileHandler    = nil;
var helicopter     = nil;
var views          = nil;
var cameras        = Cameras.new();
var walker         = Walker.new();
var nasal          = Nasal.new();

# Scripts for dialogs
var browseDialogNames   = nil;
var currentCameraConfig = nil;
var nasalConfig         = nil;

#
# Initialize FGCamera.
#
# @param  hash  addon  Object of addons.Addon.
# @return void
#
var init = func(addon) {
    g_Addon = addon;
    g_myNodePath = g_Addon.node.getPath() ~ "/addon-devel";

    offsetsManager = OffsetsManager.new();

    # Scripts for dialogs
    browseDialogNames   = BrowseDialogNames.new();
    currentCameraConfig = CurrentCameraConfig.new();
    nasalConfig         = NasalConfig.new();

    var fdmInitListener = _setlistener("/sim/signals/fdm-initialized", func {
        removelistener(fdmInitListener);

        Commands.new();
        helicopter  = Helicopter.new();
        mouse       = Mouse.new(addon);
        fileHandler = FileHandler.new(addon);
        camGui      = Gui.new(addon);
        views       = ViewsManager.new();

        if (getprop(g_myNodePath ~ "/enable")) {
            # setting default FGCamera
            fgcommand("fgcamera-select", props.Node.new({ "camera-id": 0 }));

            var delayTimer = maketimer(1, func {
                # Delay selecting default camera 2nd time for fix FOV and RND effects
                fgcommand("fgcamera-select", props.Node.new({ "camera-id": 0 }));
            });
            delayTimer.singleShot = true;
            delayTimer.start();
        }

        # welcome message
        if (getprop(g_myNodePath ~ "/welcome-skip") != true) {
            fgcommand("dialog-show", props.Node.new({'dialog-name':'fgcamera-welcome'}));
        }
    });

    setlistener("/sim/signals/reinit", func {
        if (mouse != nil) {
            mouse.init();
        }

        fgcommand("gui-redraw");
        fgcommand("fgcamera-reset-view");

        if (helicopter != nil) {
            helicopter.check();
        }
    });

    setlistener("/sim/signals/exit", func(node) {
        if (node.getBoolValue()) {
            # sim is going to exit, back previous FG settings for correct autosave
            if (views != nil) {
                views.configureFG(0);
            }
        }
    });
};
