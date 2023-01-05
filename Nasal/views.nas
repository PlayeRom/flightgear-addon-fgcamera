
var Views = {
    NAMES             : ["FGCamera1", "FGCamera2", "FGCamera3", "FGCamera4", "FGCamera5"],
    rightBtnModeCycle : nil,

    viewHandler : {
        init   : func { manager.init() },
        start  : func { manager.start(); Views.configureFG(1) },
        update : func { return manager.update() },
        stop   : func { manager.stop(); Views.configureFG(0) },
    },

    #
    # Register FGCamera views to FG
    #
    # @retrun void
    #
    register: func {
        foreach (var name; me.NAMES) {
            view.manager.register(name, me.viewHandler);
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
        if (me.rightBtnModeCycle == nil) {
            me.rightBtnModeCycle = getprop(path);
        }

        setprop(path, start ? 1 : me.rightBtnModeCycle);
    },
};
