#
# Helicopter class
#
var Helicopter = {
    #
    # Constructor
    #
    # @return me
    #
    new: func () {
        var me = {
            parents       : [Helicopter],
            _isHelicopter : 0,
        };

        var delayTimer = maketimer(2, func {
            # Check helicopter with delay, the "torque" property is not set so quickly
            me.check();
            logprint(LOG_INFO, "FGCamera: helicopter: ", helicopter.isHelicopter());
        });
        delayTimer.singleShot = 1;
        delayTimer.start();

        return me;
    },

    #
    # @return bool - Return true if currect aircraft was recognized as helicopter
    #
    isHelicopter: func {
        return me._isHelicopter;
    },

    #
    # Check if the aircraft is a helicopter
    #
    # @return bool - Return true if currect aircraft was recognized as helicopter
    #
    check: func {
        me._isHelicopter = props.globals.getNode("/rotors/main/torque", 0, 0) != nil;
        return me._isHelicopter;
    },
};
