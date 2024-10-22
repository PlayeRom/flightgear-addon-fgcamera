
# FIXME - remove ?
# rnd[0] = {
#     GEN: [
#         {sine: [0, 0, 0], resonance: [0, 2, 6, 0.5, 3, 0.005], noise: [1, 2.39, 0.04], LFO1: [0, 2.0, 0.43, 0.06], LFO2: [1, 2.0, 0.43, 0.06]},
#         {sine: [0, 0, 0], resonance: [1, 2.0, 3.0, 0.2, 0.7, 0.06], noise: [1, 4.24, 0.05], LFO1: [0, 2.1, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#         {sine: [0, 0, 0], resonance: [1, 1.7, 1.9, 0.1, 0.4, 0.09], noise: [1, 3.28, 0.12], LFO1: [0, 5, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#     ],
#     mixer: {x:[0.93, 0.0, 0.0, 0.43], y:[0.0, 0.53, 0.0, 0.32], z:[0.0, 0.11, 0.0, 0.37], h:[0,0,0,0], p:[0,0.9,0,0.1], r:[1.0, 0, 0.85, 0.25], s: 1.0},
#     curves: {
#         v2: [0, 1.62, 3.23, 5.4, 10.8, 16.2, 32.4, 48.6, 70.2, 110],
#         level: [0, 0.9, 0.98, 1.0, 0.99, 0.97, 0.91, 0.8, 0.6, 0.2],
#         filter:[0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.15, 0.05, 0.01, 0.0],
#     },
# };
# rnd[1] = {
#     GEN: [
#         {sine: [0, 0, 0], resonance: [0, 2, 6, 0.5, 3, 0.005], noise: [1, 2.39, 0.04], LFO1: [0, 2.0, 0.43, 0.06], LFO2: [1, 2.0, 0.43, 0.06]},
#         {sine: [0, 0, 0], resonance: [1, 2.0, 3.0, 0.2, 0.7, 0.06], noise: [1, 4.24, 0.05], LFO1: [0, 2.1, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#         {sine: [0, 0, 0], resonance: [1, 1.7, 1.9, 0.1, 0.4, 0.09], noise: [1, 3.28, 0.12], LFO1: [0, 5, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#     ],
#     mixer: {x:[0.93, 0.0, 0.0, 0.43], y:[0.0, 0.53, 0.0, 0.32], z:[0.0, 0.11, 0.0, 0.37], h:[0,0,0,0], p:[0,0.9,0,0.1], r:[1.0, 0, 0.85, 0.25], s: 1.0},
#     curves: {
#         v2: [0, 1.62, 3.23, 5.4, 10.8, 16.2, 32.4, 48.6, 70.2, 110],
#         level: [0, 0.9, 0.98, 1.0, 0.99, 0.97, 0.91, 0.8, 0.6, 0.2],
#         filter:[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
#     },
# };

#==================================================
#
#==================================================
var sine = {
    new: func {
        var me = { parents: [sine] };

        me.f       = 4;
        me.A       = 0.001;
        me.T       = 0;
        me.enabled = 0;
        me._offset = 0;
        me.output  = 0;

        return me;
    },

    offset: func(dt) {
        if (!me.enabled) {
            return me.output = 0;
        }

        me.T += dt;
        me.output = math.sin(2 * math.pi * me.f * me.T);

        me._offset = me.output * me.A;
    },

    set: func(v) {
        var i = 0;
        foreach (var name; ["enabled", "f", "A"]) {
            me[name] = v[i];
            i += 1;
        }
    },
};

var resonance = {
    new: func {
        var me = { parents: [resonance] };

        me.f         = 5.0;
        me.attack    = 0.25;
        me.release   = 0.5;
        me.intensity = 3.0;
        me.A         = 0.002;
        me.A2        = 1;
        me.enabled   = 0;
        me._offset   = 0;
        me.output    = 0;
        me.outputRaw = 0;
        me.T         = 0;
        me.T2        = 0;
        me._bump_T   = 0;
        me.lp1       = lowPass.new();
        me.lp2       = lowPass.new();

        return me;
    },

    offset: func(dt) {
        if (!me.enabled) {
            return me.output = 0;
        }

        if (me.T >= me._bump_T) {
            me._bump_T = me.intensity * rand();
            me.lp1.set(me.outputRaw);
            me.lp2.set(0);
            me.T = 0;
        }

        var a = me.lp1.filter(1, me.attack);
        me.outputRaw = a - me.lp2.filter(a, me.release);

        me.T  += dt;
        me.T2 += dt;

        me.output = me.outputRaw * math.cos(2 * math.pi * me.f * me.T2);
        me._offset = me.output * me.A;
    },

    set: func(v) {
        var i = 0;
        foreach (var name; ["enabled", "f", "intensity", "attack", "release", "A"]) {
            me[name] = v[i];
            i += 1;
        }
    },
};

var noise = {
    new: func {
        var me = { parents: [noise] };

        me.f       = 3.0;
        me.A       = 0.005;
        me.A2      = 0;
        me.dir     = 1;
        me.enabled = 1;
        me._offset = 0;
        me.output  = 0;
        me.T       = 0;
        me.lp      = lowPass.new();

        return me;
    },

    offset: func(dt) {
        if (!me.enabled) {
            return me.output = 0;
        }

        if (me.T >= (1 / me.f)) {
            me.T = 0;
            #me.dir *= -1;
            me.A2 = rand() * me.f / 9; # * math.sgn(0.5 - rand());
        }

        me.output = me.lp.filter(me.A2, 0.1) * math.sin(2 * math.pi * me.f * me.T);
        #me.output = me.A2 * (math.cos(2 * math.pi * me.f * me.T) - 1) / 2;
        me.T += dt;

        me._offset = me.output * me.A;
    },

    set: func(v) {
        var i = 0;
        foreach (var a; ["enabled", "f", "A"]) {
            me[a] = v[i];
            i += 1;
        }
    },
};

var LFO1 = {
    new: func {
        var me = { parents: [LFO1] };

        # FIXME - remove comment ?
        me.f         = 3; # actually 2 * f
        me.L         = 5.0;
        me.intensity = 15.0;
        me.filter    = 0;
        me.A         = 0.005;
        me.A2        = 0;
        me.A3        = 0;
        me.dir       = 1;
        me.enabled   = 1;
        me.output    = 0;
        me.outputRaw = 0;
        me.lp1       = lowPass.new();
        me.lp2       = lowPass.new();
        me.lp3       = lowPass.new();
        me._offset   = 0;
        me.T         = 0;
        me._bump_T   = 0;

        return me;
    },

    offset: func(dt) {
        if (!me.enabled)  {
            return me.output = 0;
        }

        if (me.T >= me._bump_T) {
            srand();
            me._bump_T = 0.4 + (me.intensity - 0.4) * rand();

            var d = me.A3 - me.A2;
            if (d >= 0) { # moving up
                me.dir = (me.A2 < 0 ? -1 : 1);
            }
            else { # moving down
                me.dir = (me.A2 >= 0 ? 1 : -1);
            }

            me.A2 = rand() * me.dir; #(me.A2 >= 0 ? 1 : -1);

            #me.lp1.set(me.output);
            me.lp2.set(0);
            me.T = 0;
        }

        me.A3 = me.A2;
        me.A2 -= me.lp2.filter(me.A2, 0.5);
        me.output = me.lp1.filter(me.A2, me.filter);
        # if (math.abs( var a = me.output - me.A2 ) < 0.1)
        #     me.A2 = 0;

        # me.output = me.lp2.filter(me.outputRaw, 0.1);

        me.T  += dt;

        me._offset = me.A * me.output;
    },

    set: func(v) {
        var i = 0;
        foreach (var a; ["enabled", "intensity", "filter", "A"]) {
            me[a] = v[i];
            i += 1;
        }
    },
};

var LFO2 = {
    new: func {
        var me = { parents: [LFO2] };

        me.enabled       = 1;
        me.A             = 0.01;
        me.A2            = 0;
        me.T             = 0;
        me.intensity     = 1;
        me._dir          = 1;
        me._bump         = 1;
        me._bump_T       = 0;
        me._offset       = 0;
        me.output        = 0;
        me.outputRaw     = 0;
        me._storedOffset = 0;
        me._t            = 0.4;
        me.lp            = lowPass.new();
        me.filter        = 0;

        return me;
    },

    offset: func(dt) {
        if (!me.enabled) {
            return me.output = 0;
        }

        if (me.T >= me._bump_T) {
            srand();
            me._bump_T = me._t + (me.intensity - me._t) * rand();
            me._storedOffset = me.outputRaw;
            me._dir *= -1;
            me.A2 = (1 - me._dir * me._storedOffset) * rand() * me._dir;

            me._bump = 1;
            me.T     = 0;
        }

        if (me._bump) {
            me.outputRaw = me._storedOffset - me.A2 * (math.cos(math.pi * me.T / me._t) - 1) / 2;
            if (me.T >= me._t) {
                me._bump = 0;
            }
        }
        else {
            me.outputRaw = me.A2 + me._storedOffset;
        }

        me.T += dt;
        me.output = me.lp.filter(me.outputRaw, me.filter);
        me._offset = me.A * me.output;
    },

    set: func(v) {
        var i = 0;
        foreach (var a; ["enabled", "intensity", "filter", "A"]) {
            me[a] = v[i];
            i += 1;
        }
    },
};

var generator = {
    new: func {
        var me = { parents: [generator] };

        me._generators = [];
        me._offset = 0;

        foreach (var object; [sine, resonance, noise, LFO1, LFO2]) {
            append(me._generators, object.new());
        }

        return me;
    },

    _update: func (dt) {
        me._offset = 0;

        forindex (var i; me._generators) {
            me._offset += me._generators[i].offset(dt);
        }

        return me._offset;
    },

    set: func(data) {
        var i = 0;
        foreach (var a; ["sine", "resonance", "noise", "LFO1", "LFO2"]) {
            me._generators[i].set(data[a]);
            i += 1;
        }
    },
};

#==================================================
#   Random effects handler
#==================================================
var RNDHandler = {
    parents  : [ TemplateHandler.new() ],

    name    : "RNDHandler",
    _free    : true,
    guiEdit  : false,
    guiMode  : 0, # 0 - ground; 1 - air;
    G_output : [,,,],
    _effect  : true,
    _updateF : true,
    _wow     : [1, 1, 1],
    _mode    : 0, # 0 - ground; 1 - air;
    _GEN     : [],

    hpCoeff  : 0.5,
    rnd      : [],
    rndEffectNode : nil, # for copy/pase in Rnd-mixer dialog

    updateRndData: func {
        me.rnd = cameras.getCurrent().RND;
    },

    init: func {
        me.updateRndData();

        for (var i = 0; i <= 2; i += 1) {
            append(me._GEN, generator.new());
        }

        me._setGenerators();
    },

    _setGenerators: func {
        for (var i = 0; i <= 2; i += 1) {
            me._GEN[i].set(me.rnd[me._mode].GEN[i]);
        }

        setprop(g_myNodePath ~ "/current-camera/RND-updated", 1); # trigger GUI update
    },

    start: func {
        var getWow = func (i) me._wow[i] = getprop("/gear/gear[" ~ i ~ "]/wow");

        me._listeners = [
            setlistener("/gear/gear[0]/wow", func { getWow(0) }, 1, 0),
            setlistener("/gear/gear[1]/wow", func { getWow(1) }, 1, 0),
            setlistener("/gear/gear[2]/wow", func { getWow(2) }, 1, 0),
            setlistener(g_myNodePath ~ "/current-camera/camera-id", func {
                me.updateRndData();
                me._setGenerators();
            }),
        ];
    },

    update: func (dt) {
        if (!cameras.getCurrent()["enable-RND"]) {
            me.offsets = zeros(TemplateHandler.COORD_SIZE);
            return;
        }

        var prev_mode = me._mode;
        var level = 1;

        if (me.guiEdit) {
            me.hpCoeff = 0;
            me._mode   = me.guiMode;
        }
        else {
            me._mode = me._checkMode();

            var v = getprop(
                helicopter.isHelicopter()
                    ? "/rotors/main/rpm"
                    : "/velocities/groundspeed-kt"
            );

            if (v == nil or v < 0) {
                v = 0;
            }

            me.hpCoeff = me._findValue(me.rnd[me._mode].curves.v2, me.rnd[me._mode].curves.filter, v);
            level      = me._findValue(me.rnd[me._mode].curves.v2, me.rnd[me._mode].curves.level,  v);
        }

        if (prev_mode != me._mode) {
            me._setGenerators();
        }

        #var output = [,,,];
        #for (var i = 0; i <= 2; i += 1) #why not "forindex" ?
        forindex (var i; me.G_output) {
            me.G_output[i] = me._GEN[i]._update(dt);
        }

        var i = 0;
        foreach (var dof; me._coords) {
            var offset = 0;

            for (var gen = 0; gen <= 2; gen += 1) {
                offset += me.rnd[me._mode].mixer[dof][gen] * me.G_output[gen];
            }

            var b = MovementHandler.blend;
            me.offsets[i] = me._lp[i].filter(offset * me.rnd[me._mode].mixer[dof][3] * level * me.rnd[me._mode].mixer.s, me.hpCoeff) * b;
            if (i > 2) {
                me.offsets[i] *= 50;
            }

            i += 1;
        }
    },

    stop: func {
        call(TemplateHandler.stop, [], me);
    },

    _findValue: func (x_vector, y_vector, x_value) {
        for (var i = 0; 1; i += 1) {
            if (x_value <= x_vector[i]) {
                break;
            }
            elsif (i == 9) {
                x_value = x_vector[i];
                break;
            }
        }

        linearInterp(
            x_vector[i - 1],
            y_vector[i - 1],
            x_vector[i],
            y_vector[i],
            x_value
        );
    },

    _checkMode: func { # 0 - ground; 1 - air
        foreach (var a; me._wow) {
            if (a) {
                return 0; # ground
            }
        }

        return 1; # air
    },
};
#end
