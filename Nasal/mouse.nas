#==================================================
#   fgcamera.mouse routines
#
#   getXY()      - ... returns [x, y],
#   get_dxdy()   - ... returns [dx, dy],
#   getButton(n) - ... returns 0 / 1.
#==================================================
var Mouse = {
    #
    # Constants
    #
    MODE_LOOK_AROUND : 2,

    #
    # Constructor
    #
    # @param hash addon
    # @return me
    #
    new: func(addon) {
        var me = {
            parents        : [Mouse],
            _addonBasePath : addon.basePath,
            _current       : zeros(6),
            _previous      : zeros(6),
            _delta         : zeros(6),
            _path          : "/devices/status/mice/mouse/",
            _pathInternal  : g_myNodePath ~ "/mouse/",
            _controlMode   : 0, # 0 - mouse; 1 - yoke;
            _prevMode      : 0, # previous mode, before using spring-loaded mode
        };

        me.init();

        setlistener("/devices/status/mice/mouse/button[2]", func(node) {
            me._useSpringLoaded(node);
        });

        return me;
    },

    #
    # Load new mouse configuration & reinit input subsystem
    #
    # @return bool
    #
    init: func {
        props.getNode("/input/mice").removeAllChildren();
        io.read_properties(me._addonBasePath ~ "/fgmouse.xml", "/input/mice");

        return fgcommand("reinit", props.Node.new({"subsystem": "input"}));
    },

    #--------------------------------------------------
    getXY: func {
        foreach (var a; [[0, "x"], [1, "y"]] ) {
            var i   = a[0];
            var dof = a[1];

            me._previous[i] = me._current[i];
            me._current[i]  = getprop(me._path ~ dof);
            me._delta[i]    = me._current[i] - me._previous[i];
        }
        return me._current;
    },

    #--------------------------------------------------
    getDelta: func {
        var i = 0;
        foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
            me._previous[i] = me._current[i];
            me._current[i]  = getprop(me._pathInternal ~ a) or 0;

            me._delta[i]    = me._current[i] - me._previous[i];

            i += 1;
        }
        return me._delta;
    },

    #
    # Set mouse mode
    #
    # @param int mode - 0 - pointer mode, 1 - control mode, 2 - look around mode
    # @return void
    #
    setMode: func(mode) {
        setprop(me._path ~ "mode", mode);
    },

    #
    # Get current mouse mode
    #
    # @return int - 0 - pointer mode, 1 - control mode, 2 - look around mode
    #
    getMode: func {
        getprop(me._path ~ "mode");
    },

    #
    # Get button state
    #
    # @param int n - Button index, 0 - left button, 1 - middle button, 2 - right button
    # @return bool - If return true then button is pressed
    #
    getButton: func(n) {
        getprop(me._path ~ "button[" ~ n ~ "]") or 0;
    },

    #--------------------------------------------------
    reset: func {
        var i = 0;
        foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
            me._previous[i] = 0;
            me._current[i]  = 0;
            me._delta[i]    = 0;

            setprop(me._pathInternal ~ a, 0);
            i += 1;
        }
    },

    #
    # Called by Ctrl-Space keyboard shortcut
    #
    # @return void
    #
    toggleYoke: func {
        me._controlMode = !me._controlMode;

        setprop("/devices/status/mice/mouse/mode", me._controlMode);
        # setprop(g_myNodePath ~ "/mouse/mouse-yoke", me._controlMode);
    },

    #
    # Listener callback function for right mouse button
    #
    # @param hash node - Node object of right mouse button
    # @return void
    #
    _useSpringLoaded: func(node) {
        if (!getprop(g_myNodePath ~ "/mouse/spring-loaded") or
            !getprop(g_myNodePath ~ "/fgcamera-enabled")
        ) {
            return;
        }

        var rightButton = node.getIntValue();
        if (rightButton) {
            me._prevMode = mouse.getMode();
            me.setMode(Mouse.MODE_LOOK_AROUND); # set "look around" mode
        } else {
            me.setMode(me._prevMode);
        }
    }
};
