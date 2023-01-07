var g_Addon = nil;
var g_myNodePath = "/sim/fgcamera";

#==================================================
#	"Objects"
#==================================================
var mouse       = nil;
var camGui      = nil;
var fileHandler = nil;
var helicopter  = nil;
var cameras     = Cameras.new();
var walker      = Walker.new();
var views       = nil;

#
# Initialize FGCamera
#
# @param hash addon - addons.Addon object
# @return void
#
var init = func(addon) {
    g_Addon = addon;

    var fdmInitListener = _setlistener("/sim/signals/fdm-initialized", func {
        removelistener(fdmInitListener);

        Commands.new();
        helicopter  = Helicopter.new();
        mouse       = Mouse.new(addon);
        fileHandler = FileHandler.new(addon);
        camGui      = Gui.new(addon);
        views       = Views.new();

        if (getprop("/sim/fgcamera/enable")) {
            # setting camera-id
            var delayTimer = maketimer(2, func {
                # Delay selecting default camera for fix FOV
                setprop(g_myNodePath ~ "/current-camera/camera-id", 0);
            });
            delayTimer.singleShot = 1;
            delayTimer.start();
        }

        # welcome message
        if (getprop("/sim/fgcamera/welcome-skip") != 1) {
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
