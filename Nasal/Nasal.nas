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
    # Execute entry Nasal script if it's set
    #
    cameraEntryAction: func {
        # I use full names and not string concatenation so that I can later find places to call by full name
        me._cameraExecAction("enable-nasal-entry", "script-for-entry");
    },

    #
    # Execute leave Nasal script if it's set
    #
    cameraLeaveAction: func {
        me._cameraExecAction("enable-nasal-leave", "script-for-leave");
    },

    #
    # @param  string  enableActionName  It can be "enable-nasal-entry" or "enable-nasal-leave"
    # @param  string  scriptFieldName  It can be "script-for-entry" or "script-for-leave"
    # @return void
    #
    _cameraExecAction: func(enableActionName, scriptFieldName) {
        var camera = cameras.getCurrent();

        if (camera["enable-exec-nasal"] and camera[enableActionName]) {
            var script = camera[scriptFieldName];
            me.exec(script);
        }
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
