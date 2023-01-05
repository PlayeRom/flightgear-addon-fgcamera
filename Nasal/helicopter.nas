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

        me.check();

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
