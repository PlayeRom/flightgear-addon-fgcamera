var g_Addon = nil;
var g_myNodePath = "/sim/fgcamera";

var cameras      = [];
var offsets      = [0, 0, 0, 0, 0, 0];
var offsets2     = [0, 0, 0, 0, 0, 0];
var current      = [0, 0]; # [view, camera]

#==================================================
#	"Objects"
#==================================================
var mouse       = nil;
var camGui      = nil;
var fileHandler = nil;
var helicopter  = nil;
var walker      = Walker.new();

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
        Views.register();

        if (getprop("/sim/fgcamera/enable")) {
            # setting camera-id
            var delayTimer = maketimer(2, func {
                # Delay selecting default camera for fix FOV
                setprop(g_myNodePath ~ "/current-camera/camera-id", 0);

                # Check helicopter with delay, the "torque" property is not set so quickly
                helicopter.check();
                print("FGCamera: helicopter: ", helicopter.isHelicopter());
            });
            delayTimer.singleShot = 1;
            delayTimer.start();

            # Disable pilot model in cockpit
            var is_occupants_models_visible = getprop("/sim/model/occupants");
            if (is_occupants_models_visible) {
                setprop("/sim/model/occupants", 0);
            }
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
            Views.configureFG(0);
        }
    });
};
