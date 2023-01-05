
#
# Panel 2D class
#
var panel_2d = {
    #
    # Constants
    #
    DEFAULT : "generic-vfr-panel",

    #
    # Show panel 2D of current camera
    #
    # @return void
    #
    show: func {
        me.show_path(cameras[current[1]]["panel-show-type"]);
    },

    #
    # Show panel 2D by given path
    #
    # @param string path
    # @return void
    #
    show_path: func(path) {
        if (!cameras[current[1]]["panel-show"]) {
            return;
        }

        if (path == nil or path == "") {
            path = panel_2d.DEFAULT;
        }

        path = "Aircraft/Panels/" ~ path ~ ".xml";

        setprop("/sim/panel/path", path);
        setprop("/sim/panel/visibility", 1);
    },

    #
    # Hide visible 2D panel
    #
    # @return void
    #
    hide: func {
        setprop("/sim/panel/visibility", 0);
    },
};
