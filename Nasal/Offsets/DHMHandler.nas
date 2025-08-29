
var DHM = {
    #
    # Constants
    #
    # FIXME - remove comment ?
    RATE: 0.1, #150;
    # RATE2: 5,
    SCALE: 1,

    #
    # @param  string  props  Property path.
    # @return hash
    #
    new: func (prop) {
        var me = { parents: [ DHM ] };

        me.prop = prop;

        me.m = 0;
        me.c = 0;

        me.v0 = 0; me.v1 = 0;
        me.a0 = 0; me.a1 = 0;
        me.u0 = 0; me.u1 = 0;
        me.F0 = 0; me.F1 = 0;
        me.Fr = lowPass.new(0);

        me.outputFilter = 0.1;
        me.output = lowPass.new(0);

        me.defaultAcc = 0;
        me.correction = 0;

        me._bank   = 0;
        me._pitch  = 0;
        me.uLim    = 0;

        me.constantG = 0;
        me.impulseG  = 0;

        me._offset = 0;

        return me;
    },

    offset: func (dt) {
        if (dt > 0.04) {
            dt = 0.03;
        }

        me.a1 = (getprop(me.prop) or me.defaultAcc) * 0.3048 + me.correction;

        var Fi = me.m * (me.a1 * me.constantG + (me.a1 - me.a0) * me.impulseG);

        me.F1 = Fi - me.m * 10 * me.u0 / 1 - me.v0 * me.c - me.Fr.filter(Fi, DHM.RATE);
        me.v1 = me.F1 / me.m * dt + me.v0;
        me.u1 = me.v1 * dt + me.u0;

        me.F0 = me.F1;
        me.v0 = me.v1;
        me.a0 = me.a1;
        me.u0 = me.u1;

        if (math.abs(me.u0) >= me.uLim) {
            me._offset = math.sgn(me.u0) * me.uLim;
        }
        else {
            me._offset = me.u0;
        }

        me._offset = me.output.filter(me._offset, me.outputFilter) * DHM.SCALE;
    },

    bank  : func { me._offset * me._bank  },
    pitch : func { me._offset * me._pitch },

    setMass        : func { me.m            = arg[0]; me },
    setDamping     : func { me.c            = arg[0]; me },
    setLimit       : func { me.uLim         = arg[0]; me },
    setBank        : func { me._bank        = arg[0]; me },
    setPitch       : func { me._pitch       = arg[0]; me },
    setFilter      : func { me.outputFilter = arg[0]; me },
    setDefaultAcc  : func { me.defaultAcc   = arg[0]; me },
    setCorrection  : func { me.correction   = arg[0]; me },
    setImpulseG    : func { me.impulseG     = arg[0]; me },
    setConstantG   : func { me.constantG    = arg[0]; me },
};

#==================================================
#   Dynamic Head Movement effect handler
#==================================================
var DHMHandler = {
    parents : [ TemplateHandler.new() ],

    name     : "DHMHandler",
    _free    : true,
    _effect  : true,
    _updateF : true,

    init: func {
        me.dhmX = DHM.new("/accelerations/pilot/y-accel-fps_sec");
        me.dhmY = DHM.new("/accelerations/pilot/z-accel-fps_sec");
        me.dhmZ = DHM.new("/accelerations/pilot/x-accel-fps_sec");

        me.updateValues();
    },

    start: func {
        append(me._listeners, setlistener(fgcamera.g_myNodePath ~ "/current-camera/camera-id", func {
            me.updateValues();
        }, false, 0));
    },

    updateValues: func {
        var dhm = cameras.getCurrent().DHM;
        var headMass = dhm["head-mass"];
        var x = dhm["x-axis"];
        var y = dhm["y-axis"];
        var z = dhm["z-axis"];

        me.dhmX
            .setMass(headMass)
            .setConstantG(x["constant-g"])
            .setImpulseG(x["impulse-g"])
            .setBank(x["head-bank"])
            .setDamping(x["damping"])
            .setLimit(x["movement-limit"]);

        me.dhmY
            .setMass(headMass)
            .setConstantG(y["constant-g"])
            .setImpulseG(y["impulse-g"])
            .setPitch(y["head-pitch"])
            .setDamping(y["damping"])
            .setLimit(y["movement-limit"])
            .setDefaultAcc(32.18516)
            .setCorrection(9.81);

        me.dhmZ
            .setMass(headMass)
            .setConstantG(z["constant-g"])
            .setImpulseG(z["impulse-g"])
            .setDamping(z["damping"])
            .setLimit(z["movement-limit"]);
    },

    _trigger: func {},

    update: func (dt) {
        if (!cameras.getCurrent()["enable-DHM"]) {
            return;
        }

        me.offsets[0] = me.dhmX.offset(dt); # x
        me.offsets[1] = me.dhmY.offset(dt); # y
        me.offsets[2] = me.dhmZ.offset(dt); # z
        me.offsets[4] = me.dhmY.pitch();    # pitch
        me.offsets[5] = me.dhmX.bank();     # roll
    },

    stop: func {
        call(TemplateHandler.stop, [], me);
    },
};
