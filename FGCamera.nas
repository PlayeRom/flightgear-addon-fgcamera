var g_Addon = nil;
var g_myNodePath = nil;

#==================================================
#   "Objects"
#==================================================
var g_offsetsManager = nil;
var g_mouse          = nil;
var g_camGui         = nil;
var g_fileHandler    = nil;
var g_helicopter     = nil;
var g_views          = nil;
var g_cameras        = Cameras.new();
var g_walker         = Walker.new();
var g_nasal          = Nasal.new();

# Scripts for dialogs
var g_browseDialogNames   = nil;
var g_currentCameraConfig = nil;
var g_nasalConfig         = nil;

#
# Initialize FGCamera.
#
# @param  hash  addon  Object of addons.Addon.
# @return void
#
var init = func(addon) {
    g_Addon = addon;
    g_myNodePath = g_Addon.node.getPath() ~ "/addon-devel";

    g_offsetsManager = OffsetsManager.new();

    # Scripts for dialogs
    g_browseDialogNames   = BrowseDialogNames.new();
    g_currentCameraConfig = CurrentCameraConfig.new();
    g_nasalConfig         = NasalConfig.new();

    var fdmInitListener = _setlistener("/sim/signals/fdm-initialized", func {
        removelistener(fdmInitListener);

        Commands.new();
        g_helicopter  = Helicopter.new();
        g_mouse       = Mouse.new(addon);
        g_fileHandler = FileHandler.new(addon);
        g_camGui      = Gui.new(addon);
        g_views       = ViewsManager.new();

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
        if (g_mouse != nil) {
            g_mouse.init();
        }

        fgcommand("gui-redraw");
        fgcommand("fgcamera-reset-view");

        if (g_helicopter != nil) {
            g_helicopter.check();
        }
    });

    setlistener("/sim/signals/exit", func(node) {
        if (node.getBoolValue()) {
            # sim is going to exit, back previous FG settings for correct autosave
            if (g_views != nil) {
                g_views.configureFG(0);
            }
        }
    });
};
