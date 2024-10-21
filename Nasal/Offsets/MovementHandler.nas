#==================================================
#   View movement (interpolation) handler
#==================================================

var MovementHandler = {
    parents : [ TemplateHandler.new() ],

    free    : 1,

    blend   : 0,
    _b      : 0,
    _from   : zeros(TemplateHandler.COORD_SIZE),
    _to     : [],
    _fromFov: getprop("/sim/current-view/field-of-view"),
    _toFov  : getprop("/sim/current-view/field-of-view"),
    _diffFov: 0,

    _dlg    : nil,
    # timeF   : 0,

    #
    # @return bool
    #
    _setTower: func (twr) {
        var list = [
            "latitude-deg",
            "longitude-deg",
            "altitude-ft",
            "heading-deg",
            "pitch-deg",
            "roll-deg",
        ];

        var nextTwr = 0;
        foreach (var a; list) {
            var path = g_myNodePath ~ "/tower/" ~ a;
            if (getprop(path) != twr[a]) {
                setprop(path, twr[a]);
                nextTwr = 1;
            }
        }

        return nextTwr;
    },

    #
    # @return bool
    #
    _checkWorldView: func (id) {
        if (cameras.getCamera(id).type == "FGCamera5") {
            return me._setTower(cameras.getCamera(id).tower);
        }

        return 0;
    },

    _setFromTo: func (view_id, camera_id) {
        me._to    = cameras.getCamera(camera_id).offsets;
        var bTwr = me._checkWorldView(camera_id);

        if (cameras.getCurrentViewId() == view_id) {
            for (var i = 0; i <= 5; i += 1) {
                me._from[i] = offsetsManager.offsets[i] + RNDHandler.offsets[i]; # fix (cross-reference)
            }

            me._b = 0 + bTwr;
        }
        else {
            for (var i = 0; i <= 5; i += 1) {
                me._from[i] = me._to[i];
            }

            me._b = 1;
        }

        foreach (var a; ["_from", "_to"]) {
            for (var dof = 3; dof <= 5; dof += 1) {
                me[a][dof] = view.normdeg(me[a][dof]);
            }
        }

        cameras.setCurrentId(camera_id);
        cameras.setCurrentViewId(view_id);
    },

    _setView: func (view_id) {
        var path = "/sim/current-view/view-number";
        if (getprop(path) != view_id) {
            setprop(path, view_id);
        }
    },

    _trigger: func {
        var camera_id = getprop(g_myNodePath ~ "/current-camera/camera-id");
        if (camera_id + 1 > cameras.size()) {
            camera_id = 0;
        }

        var view_id = view.indexof(cameras.getCamera(camera_id).type);

        # timeF = (cameras.getCurrent().category == cameras.getCamera(camera_id).category);

        camGui.closeDialog();
        Panel2D.hide();

        if (getprop(g_myNodePath ~ "/popupTip") * cameras.getCamera(camera_id).popupTip) {
            gui.popupTip(cameras.getCamera(camera_id).name, 1);
        }

        me._setFromTo(view_id, camera_id);
        me._setView(view_id);
        offsetsManager._reset();

        me._fromFov = getprop("/sim/current-view/field-of-view");
        me._toFov = cameras.getCurrent().fov;
        me._diffFov = math.abs(me._fromFov - me._toFov);

        me._updateF = 1;
    },

    init: func {
        var path     = g_myNodePath ~ "/current-camera/camera-id";
        var listener = setlistener(path, func { me._trigger() });

        append(me._listeners, listener);

        Bezier3.generate([0.47, 0.01], [0.39, 0.98]); #[0.52, 0.05], [0.27, 0.97]
    },

    update: func (dt) {
        if (!me._updateF) {
            return;
        }

        me._updateF = 0;
        var data    = cameras.getCurrent().movement;

        # FIXME - remove comment ?
        if (data.time > 0) { # and (timeF != 0) )
            me._b += dt / data.time;
        }
        else {
            me._b = 1;
        }

        if (me._b >= 1) {
            me._b = 0;

            forindex (var i; me.offsets) {
                me.offsets[i] = me._to[i];
            }

            camGui.showDialog();
            Panel2D.show();
            setprop("/sim/current-view/field-of-view", cameras.getCurrent().fov); # to be sure that finally the fov is correct
        }
        else {
            # FIXME - remove comment ?
            me.blend = Bezier3.blend(me._b); #sBlend(me._b); #sinBlend(me._b); #Bezier2([0.2, 1.0], me._b);
            forindex (var i; me.offsets) {
                var delta = me._to[i] - me._from[i];
                if (i == 3) {
                    if (math.abs(delta) > 180) {
                        delta = (delta - math.sgn(delta) * 360);
                    }
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

    #
    # Override stop of parent (TemplateHandler) so it doesn't get called out
    #
    stop: func,
};
