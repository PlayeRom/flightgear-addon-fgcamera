#
# Walker handler class for support walk view toggle, when he gets out
#
var Walker = {
    #
    # Constants
    #
    VIEW_ID : 110, # 110 is defined as walk view by fgdata/walker-include.xml

    #
    # Constructor
    #
    # @return me
    #
    new: func () {
        var me = {
            parents       : [Walker],

            # The following variables define the behavior and may be overridden by aircraft (for example to open the door before going out)
            # (See examples below)
            getOutTime     : 0.0,      # wait time after the getOutCallback executed
            getInTime      : 0.0,      # wait time after the getInCallback executed
            getOutCallback : func {0}, # callback when getting out
            getInCallback  : func {0}, # callback when getting in
            lastCamera     : nil,      # here we store what view we were in when the walker exits
        };

        setlistener("sim/walker/key-triggers/outside-toggle", func(node) {
            # we let pass some time so the walker code can execute first
            var timer = nil;
            if (node.getBoolValue()) {
                me.getOutCallback();
                timer = maketimer(me.getOutTime + 0.5, func {
                    # went outside
                    me.lastCamera = getprop("/sim/current-view/view-number-raw");
                    view.setViewByIndex(Walker.VIEW_ID);
                });
            }
            else {
                me.getInCallback();
                timer = maketimer(me.getInTime + 0.5, func {
                    # went inside
                    view.setViewByIndex(me.lastCamera);
                    me.lastCamera = nil;
                });
            }
            timer.singleShot = 1; # timer will only be run once
            timer.start();
        });

        return me;
    },
};
