
var Views = {
    NAMES              : ["FGCamera1", "FGCamera2", "FGCamera3", "FGCamera4", "FGCamera5"],
    _rightBtnModeCycle : nil,
    _modelOccupants    : nil,
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
            # logprint(LOG_INFO, "FGCamera: mouse mode; user slected = ", (Views._rightBtnModeCycle ? "cycle" :  "look around"));
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
    # Changing the FG configuration depending on whether you enable the FGCamera view or the FG view.
    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # return void
    #
    configureFG: func (start) {
        Views._configureRightBtnMode(start);
        Views._configureModelOccupants(start);
    },

    #
    # When FGCamera view is going to start then change right mouse button behavior to cycle mode.
    # When FGCamera view is going to stop then bring back previous right button behavior.
    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # return void
    #
    _configureRightBtnMode: func(start) {
        var path = "/sim/mouse/right-button-mode-cycle-enabled";
        if (Views._rightBtnModeCycle == nil) {
            Views._rightBtnModeCycle = getprop(path);
            # logprint(LOG_INFO, "FGCamera: mouse mode; initial = ", (Views._rightBtnModeCycle ? "cycle" :  "look around"));
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
            # logprint(LOG_INFO, "FGCamera: mouse mode; start force = ", (1 ? "cycle" :  "look around"));
            return 1;
        }

        if (getprop(g_myNodePath ~ "/mouse/force-look-around-mode-in-fg")) {
            # logprint(LOG_INFO, "FGCamera: mouse mode; stop; option force-look-around-mode-in-fg force = ", (0 ? "cycle" :  "look around"));
            return 0;
        }

        # logprint(LOG_INFO, "FGCamera: mouse mode; stop; use previous setting = ", (Views._rightBtnModeCycle ? "cycle" : "look around"));
        return Views._rightBtnModeCycle;
    },

    #
    # When the FGCamera view is launched then remove the models of people in the cockpit.
    # When the FGCamera view is going to stop then bring back previous setting.
    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # return void
    #
    _configureModelOccupants: func(start) {
        var path = "/sim/model/occupants";
        if (Views._modelOccupants == nil) {
            Views._modelOccupants = getprop(path);
        }

        setprop(path, start ? 0 : Views._modelOccupants);
    },
};
