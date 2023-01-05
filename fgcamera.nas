var my_addon_id  = "a.marius.FGCamera";
var my_version   = getprop("/addons/by-id/" ~ my_addon_id ~ "/version");
var my_root_path = getprop("/addons/by-id/" ~ my_addon_id ~ "/path");
var my_node_path = "/sim/fgcamera";
var my_settings  = {};

var cameras      = [];
var offsets      = [0, 0, 0, 0, 0, 0];
var offsets2     = [0, 0, 0, 0, 0, 0];
var current      = [0, 0]; # [view, camera]

var popupTipF    = 0;
var panelF       = 0;
var dialogF      = 0;
var timeF        = 0;

var mouse       = nil;
var camGui      = nil;
var fileHandler = nil;
var helicopter  = nil;
var walker      = Walker.new();

#==================================================
#	"Shortcuts"
#==================================================
var sin       = math.sin;
var cos       = math.cos;
var hasmember = view.hasmember;

#==================================================
#	Start
#==================================================
var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);

	Commands.new();
	helicopter  = Helicopter.new();
	mouse       = Mouse.new();
	fileHandler = FileHandler.new();
	camGui      = Gui.new();
	Views.register();

	if (getprop("/sim/fgcamera/enable")) {
		# setting camera-id
		var delayTimer = maketimer(2, func {
			# Delay selecting default camera for fix FOV
			setprop(my_node_path ~ "/current-camera/camera-id", 0);

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

var reinit_listener = setlistener("/sim/signals/reinit", func {

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
