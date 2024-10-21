#==================================================
#	Headtracker inputs handler
#==================================================

var TrackIrHandler = {
	#
	# Constants
	#
	HT_FILTER: 0.1,

	parents  : [ TemplateHandler.new() ],

	free     : 1,

	_updateF : 1,
	_effect  : 1,

	init: func {
		var i = 0;
		foreach (var a; ["x-m", "y-m", "z-m", "heading-deg", "pitch-deg", "roll-deg"] ) {
			me._coords[i] = "/sim/TrackIR/" ~ a;
			i += 1;
		}
	},

	update: func (dt) {
		for (var i = 0; i <= 5; i += 1) {
			me._offsetsRaw[i] = getprop(me._coords[i]) or 0;
		}

		me._rotate();

		for (var i = 0; i <= 5; i += 1) {
			me.offsets[i] = me._lp[i].filter(me._offsetsRaw[i], TrackIrHandler.HT_FILTER);
		}
	},

	stop: func {
		call(TemplateHandler.stop, [], me);
	},

	_rotate: func {
		var a = offsetsManager.offsets[3] * D2R; #math.pi / 180;
		var c = math.cos(a);
		var s = math.sin(a);

		var x =  me._offsetsRaw[0] * c + me._offsetsRaw[2] * s;
		var z = -me._offsetsRaw[0] * s + me._offsetsRaw[2] * c;

		me._offsetsRaw[0] = x;
		me._offsetsRaw[2] = z;
	},
};
