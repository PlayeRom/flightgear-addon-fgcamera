#
# Helicopter class.
#
var Helicopter = {
    #
    # Constructor
    #
    # @return me
    #
    new: func () {
        var obj = {
            parents       : [Helicopter],
            _isHelicopter : false,
        };

        var delayTimer = maketimer(2, func {
            # Check helicopter with delay, the "torque" property is not set so quickly
            obj.check();
            logprint(LOG_INFO, "FGCamera: helicopter: ", obj.isHelicopter());
        });
        delayTimer.singleShot = true;
        delayTimer.start();

        return obj;
    },

    #
    # @return bool  Return true if current aircraft was recognized as helicopter.
    #
    isHelicopter: func {
        return me._isHelicopter;
    },

    #
    # Check if the aircraft is a helicopter.
    #
    # @return bool  Return true if current aircraft was recognized as helicopter.
    #
    check: func {
        me._isHelicopter = props.globals.getNode("/rotors/main/torque", 0, 0) != nil;
        return me._isHelicopter;
    },
};
