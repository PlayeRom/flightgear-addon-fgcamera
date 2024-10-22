#==================================================
#   View adjustment handler
#   Used to move the camera with the Up/Down/Left/Right/PgUp/PgDn keys.
#==================================================

var AdjustmentHandler = {
    parents : [ TemplateHandler.new() ],

    _v      : zeros(TemplateHandler.COORD_SIZE),
    _vT     : zeros(TemplateHandler.COORD_SIZE), # transformed

    _reset: func {
        forindex (var i; me.offsets) {
            me.offsets[i] = me._offsetsRaw[i] = 0;
            me._lp[i].set(0);
        }
    },

    _trigger: func {
        forindex (var i; me._coords) {
            var vCfg = cameras.getCurrent().adjustment.v;
            var v = vCfg[i < 3 ? 0 : 1];

            me._v[i] = getprop(g_myNodePath ~ "/controls/adjust-" ~ me._coords[i]) or 0;
            if ((me._v[i] *= v) != 0) {
                me._updateF = true;
            }
        }
    },

    start: func {
        foreach (var a; me._coords) {
            var listener = setlistener(g_myNodePath ~ "/controls/adjust-" ~ a, func { me._trigger() }, 0, 0);
            append(me._listeners, listener);
        }
    },

    update: func (dt) {
        if (me._updateF) {
            me._updateF = false;

            var filter  = cameras.getCurrent().adjustment.filter;

            me._rotate();

            # FIXME - remove ?
            # forindex (var dof; me.offsets) {
            #     me._offsetsRaw[dof] += me._vT[dof] * dt;
            #     me.offsets[dof]       = me._lp[dof].filter(me._offsetsRaw[dof], filter);

            #     if (me.offsets[dof] != me._offsetsRaw[dof] or me._v[dof] != 0)
            #         me._updateF = true;
            # }

            forindex (var dof; me.offsets) {
                var v = me._lp[dof].filter(me._vT[dof], filter);
                me.offsets[dof] += v * dt;
                # FIXME - remove ?
                # me.offsets[dof] = me._lp[dof].filter(me._offsetsRaw[dof], filter);

                if (v != 0) {
                    me._updateF = true;
                }
            }
        }
    },

    stop: func {
        call(TemplateHandler.stop, [], me);
    },

    _rotate: func {
        var t = subvec(me._v, 0, 3);
        var r = subvec(offsetsManager.offsets, 3);
        var c = rotate3d(t, r);

        forindex (var i; c) {
            var _i     = i + 3;
            me._vT[i]  = c[i];
            me._vT[_i] = me._v[_i];
        }
    },
};
