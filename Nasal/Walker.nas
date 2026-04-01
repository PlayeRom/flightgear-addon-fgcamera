#
# Walker handler class for support walk view toggle, when he gets out.
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
        var obj = {
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
                obj.getOutCallback();
                timer = maketimer(obj.getOutTime + 0.5, func {
                    # went outside
                    me.lastCamera = getprop("/sim/current-view/view-number-raw");
                    view.setViewByIndex(Walker.VIEW_ID);
                });
            }
            else {
                obj.getInCallback();
                timer = maketimer(obj.getInTime + 0.5, func {
                    # went inside
                    view.setViewByIndex(obj.lastCamera);
                    obj.lastCamera = nil;
                });
            }

            timer.singleShot = true; # timer will only be run once
            timer.start();
        });

        return obj;
    },
};
