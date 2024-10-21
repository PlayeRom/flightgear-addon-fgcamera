#==================================================
#   Linuxtrack inputs handler
#==================================================
var LinuxTrackHandler = {
    #
    # Constants
    #
    HT_FILTER: 0.05,

    parents  : [ TemplateHandler.new() ],

    free     : 1,
    _updateF : 1,
    _effect  : 1,

    init: func {
        var i = 0;
        foreach (var a; me._coords) {
            me._coords[i] = "/sim/linuxtrack/data/" ~ a;
            i += 1;
        }
    },

    update: func (dt) {
        for (var i = 0; i <= 5; i += 1) {
            if (i <= 2) {
                # x,y,z values dependent if enabled
                var prop = me._getPropPathByIndex(i);
                if (prop != nil and getprop(prop, 0) == 1) {
                    me._offsetsRaw[i] = getprop(me._coords[i]) or 0;
                }
            }
            else if (i >= 3) {
                # h,p,r values
                me._offsetsRaw[i] = getprop(me._coords[i]) or 0;
            }

            me.offsets[i] = me._lp[i].filter(me._offsetsRaw[i], LinuxTrackHandler.HT_FILTER);
        }
    },

    stop: func {
        call(TemplateHandler.stop, [], me);
    },

    _getPropPathByIndex: func (index) {
                if (index == 0) return "/sim/linuxtrack/track-x";
        else if (index == 1) return "/sim/linuxtrack/track-y";
        else if (index == 2) return "/sim/linuxtrack/track-z";

        return nil;
    },
};
