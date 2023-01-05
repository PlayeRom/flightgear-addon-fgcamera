#==================================================
#	fgcamera.mouse raoutines
#
#		get_xy()      - ... returns [x, y],
#		get_dxdy()    - ... returns [dx, dy],
#		get_button(n) - ... returns 0 / 1.
#==================================================
var Mouse = {
	#
	# Constructor
	#
	# @return me
	#
	new: func {
		var me = {
			parents        : [Mouse],
			_current       : zeros(6),
			_previous      : zeros(6),
			_delta         : zeros(6),
			_path          : "/devices/status/mice/mouse/",
			_path_internal : "/sim/fgcamera/mouse/",
			_control_mode  : 0, # 0 - mouse; 1 - yoke;
			_prev_mode     : 0, # prevous mode, before using spring-loaded mode
		};

		me.init();

		me.right_mouse_btn_listener = setlistener("/devices/status/mice/mouse/button[2]", func(node) {
			me.use_spring_loaded(node);
		});

		return me;
	},

	#
	# Destructor
	#
	# @return void
	#
	del: func {
		removelistener(me.right_mouse_btn_listener);
	},

	#
	# Load new mouse configuration & reinit input subsystem
	#
	# @return bool
	#
	init: func {
		props.getNode("/input/mice").removeAllChildren();
		io.read_properties(my_root_path ~ "/fgmouse.xml", "/input/mice");

		return fgcommand("reinit", props.Node.new({"subsystem": "input"}));
	},

	#--------------------------------------------------
	get_xy: func {
		foreach (var a; [[0, "x"], [1, "y"]] ) {
			var i   = a[0];
			var dof = a[1];

			me._previous[i] = me._current[i];
			me._current[i]  = getprop(me._path ~ dof);
			me._delta[i]    = me._current[i] - me._previous[i];
		}
		return me._current;
	},

	#--------------------------------------------------
	get_delta: func {
		var i = 0;
		foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
			me._previous[i] = me._current[i];
			me._current[i]  = getprop(me._path_internal ~ a) or 0;

			me._delta[i]    = me._current[i] - me._previous[i];

			i += 1;
		}
		return me._delta;
	},

	#--------------------------------------------------
	#
	# @param int mode - 0 - pointer mode, 1 - control mode, 2 - look around mode
	# @return void
	#
	set_mode: func(mode) {
		setprop(me._path ~ "mode", mode);
	},

	#--------------------------------------------------
	#
	# @retrun int - 0 - pointer mode, 1 - control mode, 2 - look around mode
	#
	get_mode: func {
		getprop(me._path ~ "mode");
	},

	#--------------------------------------------------
	#
	# Get button state
	#
	# @param int n - Button index, 0 - left button, 1 - middle button, 2 - right button
	# @return bool - If return true then button is pressed
	#
	get_button: func(n) {
		getprop(me._path ~ "button[" ~ n ~ "]") or 0;
	},

	#--------------------------------------------------
	reset: func {
		var i = 0;
		foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
			me._previous[i] = 0;
			me._current[i]  = 0;
			me._delta[i]    = 0;

			setprop(me._path_internal ~ a, 0);
			i += 1;
		}
	},

	#
	# Called by Ctrl-Space keyboard shortcut
	#
	# @return void
	#
	toggle_yoke: func {
		me._control_mode = !me._control_mode;

		setprop("/devices/status/mice/mouse/mode", me._control_mode);
		# setprop("/sim/fgcamera/mouse/mouse-yoke", me._control_mode);
	},

	#
	# Listener callback function for right mouse button
	#
	# @param hash node - Node object of right mouse button
	# @return void
	#
	use_spring_loaded: func(node) {
		if (!getprop("/sim/fgcamera/mouse/spring-loaded") or
			!getprop("/sim/fgcamera/fgcamera-enabled")
		) {
			return;
		}

		var right_button = node.getIntValue();
		if (right_button) {
			me._prev_mode = mouse.get_mode();
			me.set_mode(2); # set "look around" mode
		} else {
			me.set_mode(me._prev_mode);
		}
	}
};
