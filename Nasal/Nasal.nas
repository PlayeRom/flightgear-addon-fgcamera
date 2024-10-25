#==================================================
#   Class to execute Nasal scripts from string
#==================================================
var Nasal = {
    #
    # Constructor
    #
    # @return me
    #
    new: func {
        return { parents : [Nasal] };
    },

    #
    # Execute given Nasal script
    #
    # @param string|nil  script  Script to execute
    # @return void
    #
    exec: func (script) {
        if (script == "" or script == nil) {
            return;
        }

        if (!contains(globals, "__fgcamera")) {
            globals["__fgcamera"] = {};
        }

        var locals = globals["__fgcamera"];

        var tag = "<\"" ~ cameras.getCurrent().name ~ "\" FGCamera>";
        var err = [];

        var function = call(func { compile(script, tag) }, nil, nil, nil, err);

        if (size(err)) {
            logprint(LOG_ALERT, tag ~ ": " ~ err[0]);
            return;
        }

        function = bind(function, globals);

        call(function, nil, nil, locals, err);

        debug.printerror(err);
    },
};
