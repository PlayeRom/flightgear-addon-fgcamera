
var ViewsManager = {
    #
    # Constants:
    #
    NAMES: ["FGCamera1", "FGCamera2", "FGCamera3", "FGCamera4", "FGCamera5"],

    #
    # Constructor
    #
    # @return me
    #
    new: func {
        var me = {
            parents : [ViewsManager],
            _rightBtnModeCycle : nil,
            _modelOccupants    : nil,
            _preventListener   : 0,
        };

        me.register();

        setlistener("/sim/mouse/right-button-mode-cycle-enabled", func(node) {
            if (me._preventListener) {
                # It's internal state change by changing the view from FGCamera to FG and vice versa.
                # And in this listener we want to capture the change of the option only when the user chooses
                # the one from the menu.
                me._preventListener = 0;
                return;
            }

            me._rightBtnModeCycle = node.getBoolValue();
            # logprint(LOG_INFO, "FGCamera: mouse mode; user selected = ", (me._rightBtnModeCycle ? "cycle" :  "look around"));
        });

        return me;
    },

    #
    # Register FGCamera views to FG
    #
    # @return void
    #
    register: func {
        foreach (var name; ViewsManager.NAMES) {
            view.manager.register(name, ViewHandler.new(me));
        }
    },

    #
    # Changing the FG configuration depending on whether you enable the FGCamera view or the FG view.
    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # @return void
    #
    configureFG: func (start) {
        me._configureRightBtnMode(start);
        me._configureModelOccupants(start);
    },

    #
    # When FGCamera view is going to start then change right mouse button behavior to cycle mode.
    # When FGCamera view is going to stop then bring back previous right button behavior.
    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # @return void
    #
    _configureRightBtnMode: func(start) {
        var path = "/sim/mouse/right-button-mode-cycle-enabled";
        if (me._rightBtnModeCycle == nil) {
            me._rightBtnModeCycle = getprop(path);
            # logprint(LOG_INFO, "FGCamera: mouse mode; initial = ", (me._rightBtnModeCycle ? "cycle" :  "look around"));
        }

        me._preventListener = 1;
        setprop(path, me._getRightBtnModeCycle(start));
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

        # logprint(LOG_INFO, "FGCamera: mouse mode; stop; use previous setting = ", (me._rightBtnModeCycle ? "cycle" : "look around"));
        return me._rightBtnModeCycle;
    },

    #
    # When the FGCamera view is launched then remove the models of people in the cockpit.
    # When the FGCamera view is going to stop then bring back previous setting.
    #
    # @param bool start - If true then then called on start, otherwise called on stop
    # @return void
    #
    _configureModelOccupants: func(start) {
        var path = "/sim/model/occupants";
        if (me._modelOccupants == nil) {
            me._modelOccupants = getprop(path);
        }

        setprop(path, start ? 0 : me._modelOccupants);
    },
};
