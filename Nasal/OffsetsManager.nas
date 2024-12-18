#==================================================
#   Offsets Manager
#==================================================
var OffsetsManager = {
    #
    # Constructor
    #
    # @return me
    #
    new: func() {
        var me = {
            parents      : [OffsetsManager],
            _initialized : false,
            coords       : [
                "x-offset-m",
                "y-offset-m",
                "z-offset-m",
                "heading-offset-deg",
                "pitch-offset-deg",
                "roll-offset-deg",
            ],
            _handlers: std.Vector.new([
                MovementHandler,
                AdjustmentHandler,
                MouseLookHandler,
                DHMHandler,
                RNDHandler,
            ]),
            _deltaTimeNode: props.globals.getNode("/sim/time/delta-sec"),
        };

        me.offsets  = zeros(TemplateHandler.COORD_SIZE); # position (x, y, z) and rotation (h, p, r) of the camera
        me.offsets2 = zeros(TemplateHandler.COORD_SIZE);

        me._nodes = [];
        foreach (var name; me.coords) {
            append(me._nodes, props.globals.getNode("/sim/current-view/" ~ name, 1));
        }

        # Adding LinuxTrackHandler depending on options
        setlistener(g_myNodePath ~ "/handlers/linux-track", func(node) {
            if (node.getBoolValue()) {
                me._add(LinuxTrackHandler);
            }
            else {
                me._remove(LinuxTrackHandler);
            }
        }, true, 0);

        # Adding TrackIrHandler depending on options
        setlistener(g_myNodePath ~ "/handlers/track-ir", func(node) {
            if (node.getBoolValue()) {
                me._add(TrackIrHandler);
            }
            else {
                me._remove(TrackIrHandler);
            }
        }, true, 0);

        return me;
    },

    #
    # Check if the specified handler has already been added to use
    #
    # @return bool
    #
    _isAdded: func (handler) {
        foreach (var item; me._handlers.vector) {
            if (item.name == handler.name) {
                return true;
            }
        }

        return false;
    },

    #
    # Add given handler to use
    #
    # @param  hash handler  Handler object to add
    # @return bool
    #
    _add: func (handler) {
        if (me._isAdded(handler)) {
            return false;
        }

        me._callHandlerFunction(handler, "init");
        me._handlers.append(handler);
        return true;
    },

    #
    # Remove given handler from use
    #
    # @param  hash handler  Handler object to remove
    # @return bool
    #
    _remove: func (handler) {
        if (!me._isAdded(handler)) {
            return false;
        }

        me._handlers.remove(handler);
        me._callHandlerFunction(handler, "stop");
        return true;
    },

    #
    # Callback function from ViewHandler, called only once at startup
    #
    # @return void
    #
    init: func {
        if (me._initialized) {
            return;
        }

        me._callHandlersFunction("init");

        me._initialized = true;
    },

    #
    # Callback function from ViewHandler, called when view is switched to our view
    #
    # @return void
    #
    start: func {
        setprop(g_myNodePath ~ "/fgcamera-enabled", 1);

        me._callHandlersFunction("start");
    },

    #
    # Callback function from ViewHandler, called iteratively.
    #
    # @return double  Interval in seconds until next invocation.
    #
    update: func () {
        var dt = me._deltaTimeNode.getDoubleValue();

        var updateF = false;

        # Reset offsets
        for (var i = 0; i < TemplateHandler.COORD_SIZE; i += 1) {
            me.offsets[i] = 0;
            me.offsets2[i] = 0;
        }

        foreach (var handler; me._handlers.vector) {
            if (handler._updateF) {
                updateF = true;
            }

            handler.update(dt);

            me._updateOffsets(handler, handler._effect ? me.offsets2 : me.offsets);
        }

        if (updateF) {
            me._apply();
        }

        return 0;
    },

    #
    # @param  hash  handler
    # @param  vector  offsets  The vector is passed by reference by default, so we change the offset values ​​directly
    # @return void
    #
    _updateOffsets: func (handler, offsets) {
        forindex (var i; handler.offsets) {
            offsets[i] += handler.offsets[i];
        }
    },

    reset: func {
        me._callHandlersFunction("reset");
    },

    #
    # Callback function from ViewHandler, called when view is switched away from our view
    #
    # @return void
    #
    stop: func {
        setprop(g_myNodePath ~ "/fgcamera-enabled", 0);

        me._callHandlersFunction("stop");
    },

    _reset: func {
        me._callHandlersFunction("_reset", func (handler) {
            if (!handler._free) {
                forindex (var i; handler.offsets) {
                    handler.offsets[i] = 0;
                }
            }
        });
    },

    #
    # Apply offsets
    #
    _apply: func {
        forindex (var i; me._nodes) {
            me._nodes[i].setDoubleValue(me.offsets[i] + me.offsets2[i]);
        }
    },

    #
    # Save offsets
    #
    save: func {
        forindex (var i; cameras.getCurrent().offsets) {
            cameras.getCurrent().offsets[i] = me.offsets[i];
        }
    },

    #
    # Call for all handlers the given function name if the function exists,
    # if not then call the callback function
    #
    # @param  string  funcName  The name of function to call
    # @param  func  negativeCallback  The function that will be called if the handler does not have the function specified in the name
    # @return void
    #
    _callHandlersFunction: func (funcName, negativeCallback = nil) {
        foreach (var handler; me._handlers.vector) {
            var called = me._callHandlerFunction(handler, funcName);
            if (!called and negativeCallback != nil) {
                negativeCallback(handler);
            }
        }
    },

    #
    # Call for handler the given function name if the function exists.
    #
    # @param  hash  handler  Object of handler
    # @param  string  funcName  The name of function to call
    # @return bool  Return true if function was called, otherwise return false
    #
    _callHandlerFunction: func (handler, funcName) {
        if (view.hasmember(handler, funcName) and typeof(handler[funcName]) == "func") {
            # Calling the funcName function, without parameters, in a handler context
            call(handler[funcName], [], handler);
            return true;
        }

        return false;
    }
};
