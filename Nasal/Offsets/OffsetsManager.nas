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
		};

		me.offsets  = zeros(TemplateHandler.COORD_SIZE);
		me.offsets2 = zeros(TemplateHandler.COORD_SIZE);

		me._nodes = [];
		foreach (var name; me.coords) {
			append(me._nodes, props.globals.getNode("/sim/current-view/" ~ name, 1));
		}

		return me;
	},

	init: func {
		if (me._initialized) {
			return;
		}

		foreach (var h; me.handlers) {
			if (view.hasmember(h, "init")) {
				h.init();
			}
		}

		me._initialized = 1;
	},

	start: func {
		setprop(g_myNodePath ~ "/fgcamera-enabled", 1);

		foreach (var h; me.handlers) {
			if (view.hasmember(h, "start")) {
				h.start();
			}
		}
	},

	update: func (dt = nil) {
		if (dt == nil) {
			dt = getprop("/sim/time/delta-sec");
		}

		var updateF  = 0;
		var offsets  = zeros(TemplateHandler.COORD_SIZE);
		var offsets2 = zeros(TemplateHandler.COORD_SIZE);

		foreach (var h; me.handlers) {
			if (h._updateF) {
				updateF = 1;
			}

			h.update(dt);

			if (h._effect) {
				forindex (var i; h.offsets) {
					offsets2[i] += h.offsets[i];
				}
			}
			else {
				forindex (var i; h.offsets) {
					offsets[i] += h.offsets[i];
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
		foreach (var h; me.handlers) {
			if (view.hasmember(h, "reset")) {
				h.reset();
			}
		}
	},

	stop: func {
		setprop(g_myNodePath ~ "/fgcamera-enabled", 0);

		foreach (var h; me.handlers) {
			if (view.hasmember(h, "stop")) {
				h.stop();
			}
		}
	},

	_reset: func {
		foreach (var h; me.handlers) {
			if (view.hasmember(h, "_reset")) {
				h._reset();
			}
			elsif (!h.free) {
				forindex (var i; h.offsets) {
					h.offsets[i] = 0;
				}
			}
		}
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
};
