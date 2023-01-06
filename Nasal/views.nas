
var Views = {
    NAMES              : ["FGCamera1", "FGCamera2", "FGCamera3", "FGCamera4", "FGCamera5"],
    _rightBtnModeCycle : nil,
    _preventListener   : 0,
    _viewHandler       : {
        init   : func { manager.init() },
        start  : func { manager.start(); Views.configureFG(1) },
        update : func { return manager.update() },
        stop   : func { manager.stop(); Views.configureFG(0) },
    },

    #
    # Constructor
    #
    # @return me
    #
    new: func {
        var me = {
            parents : [Views],
        };

        me.register();

        setlistener("/sim/mouse/right-button-mode-cycle-enabled", func(node) {
            if (Views._preventListener) {
                # It's internal state change by changing the view from FGCamera to FG and vice versa.
                # And in this listener we want to capture the change of the option only when the user chooses
                # the one from the menu.
                Views._preventListener = 0;
                return;
            }

            Views._rightBtnModeCycle = node.getBoolValue();
            print("FGCamera: mouse mode; user slected = ", (Views._rightBtnModeCycle ? "cycle" :  "look around"));
        });

        return me;
    },

    #
    # Register FGCamera views to FG
    #
    # @retrun void
    #
    register: func {
        foreach (var name; me.NAMES) {
            view.manager.register(name, me._viewHandler);
        }
    },

    #
    # When FGCamera view is going to start then change right mouse button behavior to cycle mode.
    # When FGCamera view is going to stop then bring back previous right button behavior.
    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # return void
    #
    configureFG: func (start) {
        var path = "/sim/mouse/right-button-mode-cycle-enabled";
        if (Views._rightBtnModeCycle == nil) {
            Views._rightBtnModeCycle = getprop(path);
            print("FGCamera: mouse mode; initial = ", (Views._rightBtnModeCycle ? "cycle" :  "look around"));
        }

        Views._preventListener = 1;
        setprop(path, Views._getRightBtnModeCycle(start));
    },

    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # return bool
    #
    _getRightBtnModeCycle: func(start) {
        if (start) {
            print("FGCamera: mouse mode; start force = ", (1 ? "cycle" :  "look around"));
            return 1;
        }
        else if (getprop("/sim/fgcamera/mouse/force-look-around-mode-in-fg")) {
            print("FGCamera: mouse mode; stop; option force-look-around-mode-in-fg force = ", (0 ? "cycle" :  "look around"));
            return 0;
        }

        print("FGCamera: mouse mode; stop; use previous setting = ", (Views._rightBtnModeCycle ? "cycle" : "look around"));
        return Views._rightBtnModeCycle;
    },
};
