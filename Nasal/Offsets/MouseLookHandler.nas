#==================================================
#   "Mouse look" handler
#==================================================

var MouseLookHandler = {
    parents      : [ TemplateHandler.new() ],

    name         : "MouseLookHandler",
    _delta       : zeros(TemplateHandler.COORD_SIZE),
    _deltaT      : zeros(TemplateHandler.COORD_SIZE),
    _path        : "/devices/status/mice/mouse/",
    _sensitivity : 2.0,
    _filter      : 0.1,
    _mlook       : false,

    _reset: func {
        me.offsets      = zeros(TemplateHandler.COORD_SIZE);
        me._offsetsRaw = zeros(TemplateHandler.COORD_SIZE);

        forindex (var i; me._lp) {
            me._lp[i].set(me._offsetsRaw[i]);
        }
    },

    #
    # Mouse mode changed
    #
    _trigger: func {
        var mode = mouse.getMode();

        if (mode == Mouse.MODE_LOOK_AROUND or mode == 3) { # TODO: what is mode 3?
            me._mlook = true;

            mouse.reset();

            var m = cameras.getCurrent().mouse_look;
            me._sensitivity = m.sensitivity;
            me._filter      = m.filter;

            me._updateF = true;
        }
        else {
            me._mlook   = false;
        }
    },

    start: func {
        var path     = me._path ~ "mode";
        var listener = setlistener(path, func { me._trigger() });

        append(me._listeners, listener);
    },

    update: func {
        if (!me._updateF) {
            return;
        }

        me._updateF = me._mlook;

        me._delta = mouse.getDelta();
        me._rotate();

        var i = 0;
        forindex (var i; me._deltaT) {
            me._offsetsRaw[i] += me._deltaT[i] * me._sensitivity;
            me.offsets[i]      = me._lp[i].filter(me._offsetsRaw[i], me._filter);

            if (me.offsets[i] != me._offsetsRaw[i]) {
                me._updateF = true;
            }

            i += 1;
        }
    },

    stop: func {
        call(TemplateHandler.stop, [], me);
    },

    _rotate: func {
        var t = subvec(me._delta, 0, 3); # take the first 3 values from the _delta vector
        var r = subvec(offsetsManager.offsets, 3); # take the last 3 values from the offsetsManager.offsets vector
        var c = rotate3d(t, r);

        forindex (var i; c) {
            var _i         = i + 3;
            me._deltaT[i]  = c[i];
            me._deltaT[_i] = me._delta[_i];
        }
    },
};
