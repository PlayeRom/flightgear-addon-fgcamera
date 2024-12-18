#==================================================
#   View movement (interpolation) handler
#==================================================

var MovementHandler = {
    parents : [ TemplateHandler.new() ],

    name    : "MovementHandler",
    _free   : true,
    blend   : 0.0,
    _b      : 0,
    _from   : zeros(TemplateHandler.COORD_SIZE),
    _to     : [],
    _fromFov: getprop("/sim/current-view/field-of-view"),
    _toFov  : getprop("/sim/current-view/field-of-view"),
    _diffFov: 0.0,

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

        var nextTwr = false;
        foreach (var a; list) {
            var path = g_myNodePath ~ "/tower/" ~ a;
            if (getprop(path) != twr[a]) {
                setprop(path, twr[a]);
                nextTwr = true;
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

        return false;
    },

    _setFromTo: func (viewId, cameraId) {
        me._to   = cameras.getCamera(cameraId).offsets;
        var bTwr = me._checkWorldView(cameraId);

        if (cameras.getCurrentViewId() == viewId) {
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

        cameras.setCurrentId(cameraId);
        cameras.setCurrentViewId(viewId);
    },

    _setView: func (viewId) {
        var path = "/sim/current-view/view-number";
        if (getprop(path) != viewId) {
            setprop(path, viewId);
        }
    },

    _trigger: func {
        # ID of the camera we will switch to
        var cameraId = getprop(g_myNodePath ~ "/current-camera/camera-id");
        if (cameraId + 1 > cameras.size()) {
            cameraId = 0;
        }

        var currentCamera  = cameras.getCurrent();
        var incomingCamera = cameras.getCamera(cameraId);

        var viewId = view.indexof(incomingCamera.type);

        # timeF = (currentCamera.category == incomingCamera.category);

        camGui.closeDialog(); # close dialog for cameras.getCurrent();
        Panel2D.hide();
        nasal.cameraLeaveAction();

        if (getprop(g_myNodePath ~ "/popupTip") and incomingCamera.popupTip) {
            gui.popupTip(incomingCamera.name, 1);
        }

        me._setFromTo(viewId, cameraId); # <- this function change cameras.getCurrent();
        me._setView(viewId);
        offsetsManager._reset();

        me._fromFov = getprop("/sim/current-view/field-of-view");
        me._toFov = cameras.getCurrent().fov;
        me._diffFov = math.abs(me._fromFov - me._toFov);

        me._updateF = true;
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

        me._updateF = false;
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
            nasal.cameraEntryAction();
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

            me._updateF = true;
        }
    },

    #
    # Override stop of parent (TemplateHandler) so it doesn't get called out
    #
    stop: func,
};
