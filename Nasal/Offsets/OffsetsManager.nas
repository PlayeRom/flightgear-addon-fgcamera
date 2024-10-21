#==================================================
#	Offsets offsetsManager
#==================================================
var OffsetsManager = {
	#
	# Constructor
	#
	# @return me
	#
	new: func() {
		var me = {
			parents      : [OffsetsManager],
			_initialized : 0,
			coords       : [
				"x-offset-m",
				"y-offset-m",
				"z-offset-m",
				"heading-offset-deg",
				"pitch-offset-deg",
				"roll-offset-deg",
			],
			handlers     : [
				MovementHandler,
				AdjustmentHandler,
				MouseLookHandler,
				DHMHandler,
				RNDHandler,
				TrackIrHandler,
				LinuxTrackHandler,
			],
			_deltaTimeNode: props.globals.getNode("/sim/time/delta-sec"),
		};

		me.offsets  = zeros(TemplateHandler.COORD_SIZE);
		me.offsets2 = zeros(TemplateHandler.COORD_SIZE);

		me._nodes = [];
		foreach (var name; me.coords) {
			append(me._nodes, props.globals.getNode("/sim/current-view/" ~ name, 1));
		}

		return me;
	},

	#
	# Callback function form ViewHandler, called only once at startup
	#
	# @return void
	#
	init: func {
		if (me._initialized) {
			return;
		}

		me._callHandlersFunction("init");

		me._initialized = 1;
	},

	#
	# Callback function form ViewHandler, called when view is switched to our view
	#
	# @return void
	#
	start: func {
		setprop(g_myNodePath ~ "/fgcamera-enabled", 1);

		me._callHandlersFunction("start");
	},

	#
	# Callback function form ViewHandler, called iteratively.
	#
	# @return double  Interval in seconds until next invocation.
	#
	update: func () {
		var dt = me._deltaTimeNode.getDoubleValue();

		var updateF  = 0;
		var offsets  = zeros(TemplateHandler.COORD_SIZE);
		var offsets2 = zeros(TemplateHandler.COORD_SIZE);

		foreach (var handler; me.handlers) {
			if (handler._updateF) {
				updateF = 1;
			}

			handler.update(dt);

			if (handler._effect) {
				forindex (var i; handler.offsets) {
					offsets2[i] += handler.offsets[i];
				}
			}
			else {
				forindex (var i; handler.offsets) {
					offsets[i] += handler.offsets[i];
				}
			}
		}

		me.offsets  = offsets;
		me.offsets2 = offsets2;

		if (updateF) {
			me._apply();
		}

		return 0;
	},

	reset: func {
		me._callHandlersFunction("reset");
	},

	#
	# Callback function form ViewHandler, called when view is switched away from our view
	#
	# @return void
	#
	stop: func {
		setprop(g_myNodePath ~ "/fgcamera-enabled", 0);

		me._callHandlersFunction("stop");
	},

	_reset: func {
		me._callHandlersFunction("_reset", func (handler) {
			if (!handler.free) {
				forindex (var i; handler.offsets) {
					handler.offsets[i] = 0;
				}
			}
		});
	},

	#
	# Apply offsets
	#
	_apply: func {
		forindex (var i; me._nodes) {
			me._nodes[i].setDoubleValue(me.offsets[i] + me.offsets2[i]);
		}
	},

	#
	# Save offsets
	#
	save: func {
		forindex (var i; cameras.getCurrent().offsets) {
			cameras.getCurrent().offsets[i] = me.offsets[i];
		}
	},

	#
	# Call for all handlers the given function name if the function exists,
	# if not then call the callback function
	#
	# @param  string  funcName  The neme of function to call
	# @param  func  nagativeCallback  The function that will be called if the handler does not have the function specified in the name
	# @return void
	#
	_callHandlersFunction: func (funcName, nagativeCallback = nil) {
		foreach (var handler; me.handlers) {
			var called = me._callHandlerFunction(handler, funcName);
			if (!called and nagativeCallback != nil) {
				nagativeCallback(handler);
			}
		}
	},

	#
	# Call for handler the given function name if the function exists.
	#
	# @param  hash  handler  Object of handler
	# @param  string  funcName  The neme of function to call
	# @return bool  Return true if function was called, otherwise return false
	#
	_callHandlerFunction: func (handler, funcName) {
		if (view.hasmember(handler, funcName) and typeof(handler[funcName]) == "func") {
			# Calling the funcName function, without parameters, in a handler context
			call(handler[funcName], [], handler);
			return 1;
		}

		return 0;
	}
};
