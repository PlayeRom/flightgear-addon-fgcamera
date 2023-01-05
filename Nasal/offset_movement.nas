#==================================================
#	View movement (interpolation) handler
#==================================================

var movement_handler = {
	parents : [ t_handler.new() ],

	free    : 1,

	blend   : 0,
	_b      : 0,
	_from   : zeros(6),
	_to     : [],
	_fromFov: getprop("/sim/current-view/field-of-view"),
	_toFov  : getprop("/sim/current-view/field-of-view"),
	_diffFov: 0,

	_dlg    : nil,
#--------------------------------------------------
	_set_tower: func (twr) {
		var list = [
			"latitude-deg",
			"longitude-deg",
			"altitude-ft",
			"heading-deg",
			"pitch-deg",
			"roll-deg",
		];
		var next_twr = 0;
		foreach(var a; list) {
			var path = my_node_path ~ "/tower/" ~ a;
			if ( getprop(path) != twr[a] ) {
				setprop(path, twr[a]);
				next_twr = 1;
			}
		}
		return next_twr;
	},
#--------------------------------------------------
	_check_world_view: func (id) {
		if (cameras[id].type == "FGCamera5")
			return me._set_tower(cameras[id].tower);
		else return 0;
	},
#--------------------------------------------------
	_set_from_to: func (view_id, camera_id) {
		me._to    = cameras[camera_id].offsets;
		var b_twr = me._check_world_view(camera_id);

		if ( current[0] == view_id ) {
			for (var i = 0; i <= 5; i += 1)
				me._from[i] = offsets[i] + RND_handler.offsets[i]; # fix (cross-reference)

			me._b = 0 + b_twr;
		} else {
			for (var i = 0; i <= 5; i += 1) me._from[i] = me._to[i];

			me._b = 1;
		}

		foreach (var a; ["_from", "_to"])
			for (var dof = 3; dof <= 5; dof += 1)
				me[a][dof] = view.normdeg(me[a][dof]);

		current = [view_id, camera_id];
	},
#--------------------------------------------------
	_set_view: func (view_id) {
		var path = "/sim/current-view/view-number";
		if ( getprop(path) != view_id )
			setprop(path, view_id);
	},
#--------------------------------------------------
	_trigger: func {
		var camera_id = getprop ( my_node_path ~ "/current-camera/camera-id" );
		if ( (camera_id + 1) > size(cameras) )
			camera_id = 0;

		var view_id = view.indexof(cameras[camera_id].type);

		#timeF = (cameras[current[1]].category == cameras[camera_id].category);

		camGui.closeDialog();
		panel_2d.hide();

		if (popupTipF * cameras[camera_id].popupTip)
			gui.popupTip(cameras[camera_id].name, 1);

		me._set_from_to(view_id, camera_id);
		me._set_view(view_id);
		manager._reset();

		me._fromFov = getprop("/sim/current-view/field-of-view");
		me._toFov = cameras[current[1]].fov;
		me._diffFov = math.abs(me._fromFov - me._toFov);

		me._updateF = 1;
	},
#--------------------------------------------------
	init: func {
		var path      = my_node_path ~ "/current-camera/camera-id";
		var listener  = setlistener( path, func { me._trigger() } );

		append (me._listeners, listener);
	},
	stop: func,
#--------------------------------------------------
	update: func (dt) {
		if ( !me._updateF ) return;

		me._updateF = 0;
		var data    = cameras[current[1]].movement;

		# FIXME - remove comment ?
		if ( data.time > 0 ) #and (timeF != 0) )
			me._b += dt / data.time;
		else
			me._b = 1;

		if ( me._b >= 1 ) {
			me._b = 0;

			forindex (var i; me.offsets)
				me.offsets[i] = me._to[i];

			camGui.showDialog();
			panel_2d.show();
			setprop("/sim/current-view/field-of-view", cameras[current[1]].fov); # to be sure that finally the fov is correct

		} else {
			# FIXME - remove comment ?
			me.blend = Bezier3.blend(me._b); #s_blend(me._b); #sin_blend(me._b); #Bezier2( [0.2, 1.0], me._b );
			forindex (var i; me.offsets) {
				var delta = me._to[i] - me._from[i];
				if (i == 3) {
					if (math.abs(delta) > 180)
						delta = (delta - math.sgn(delta) * 360);
				}
				me.offsets[i] = me._from[i] + me.blend * delta;
			}

			if (me._fromFov > me._toFov) {
				var fov = me._fromFov - (me._diffFov * me._b);
				if (fov < me._toFov) {
					fov = me._toFov;
				}
				setprop("/sim/current-view/field-of-view", fov);
			}
			else if (me._fromFov < me._toFov) {
				var fov = me._fromFov + (me._diffFov * me._b);
				if (fov > me._toFov) {
					fov = me._toFov;
				}
				setprop("/sim/current-view/field-of-view", fov);
			}

			me._updateF = 1;
		}
	},
};
