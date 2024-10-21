#==================================================
#   Template for handlers
#==================================================

var TemplateHandler = {
    COORD_SIZE: 6, # number of elements in the _coords array

    new: func {
        var me = { parents: [TemplateHandler] };

        me._coords     = ["x", "y", "z", "h", "p", "r"];
        me.offsets     = zeros(TemplateHandler.COORD_SIZE);
        me._offsetsRaw = zeros(TemplateHandler.COORD_SIZE);
        me._lp         = [];
        me._listeners  = [];
        me._free       = 0;
        me._effect     = 0;
        me._updateF    = 0;

        forindex (var i; me.offsets) {
            append(me._lp, lowPass.new(0));

            me._lp[i].filter(0);
        }

        return me;
    },

    stop: func {
        if (size(me._listeners)) {
            foreach (var l; me._listeners) {
                removelistener(l);
            }

            setsize(me._listeners, 0);
        }
    },
};
