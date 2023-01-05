#==================================================
#	API for fgcommands
#
#	fgcamera-select (<camera-id>)
#	fgcamera-adjust (<dof>, <velocity>)
#	fgcamera-save   ()
#	fgcamera-reset-view ()
#	fgcamera-next-category ()
#	fgcamera-prev-category ()
#	fgcamera-next-in-category ()
#	fgcamera-prev-in_category ()
#==================================================

var Commands = {
    #
    # Constructor
    #
    # @return me
    #
    new: func () {
        var me = { parents: [Commands] };

        me._addCommands();

        return me;
    },

    #
    # Load all commands
    #
    # @return void
    #
    _addCommands: func {
        var commands = me._getCommansHash();
        foreach (var name; keys(commands)) {
            addcommand(name, commands[name]);
        }
    },

    #
    # Get all commands in hash
    #
    # @return hash
    #
    _getCommansHash: func {
        return {
            "fgcamera-select": func {
                var data = cmdarg().getValues();
                popupTipF = 1;
                setprop(my_node_path ~ "/current-camera/camera-id", data["camera-id"]);
            },

            "fgcamera-adjust": func {
                var data = cmdarg().getValues();
                setprop(my_node_path ~ "/controls/adjust-" ~ data.dof, data.velocity);
            },

            "fgcamera-save": func {
                setprop(my_node_path ~ "/save-cameras", 1);
            },

            "fgcamera-reset-view": func {
                popupTipF = 0;
                setprop(my_node_path ~ "/current-camera/camera-id", current[1]);
            },

            "fgcamera-next-category": func {
                me._cycleCategoryOnly(1);
            },

            "fgcamera-prev-category": func {
                me._cycleCategoryOnly(-1);
            },

            "fgcamera-next-in-category": func {
                me._cycleCameraInCategory(1);
            },

            "fgcamera-prev-in-category": func {
                me._cycleCameraInCategory(-1);
            },
        }
    },

    #
    # Cycle through categories
    #
    # @param int direction - If direction > 0 - move forward, direction < 0 - move backward
    # @return void
    #
    _cycleCategoryOnly: func(direction) {
        var currentCamera   = current[1];
        var currentCategory = cameras[currentCamera].category;
        var cameraId = -1;

        if (direction > 0) { # >>
            forindex (var index; cameras) {
                if (index > currentCamera and cameras[index].category > currentCategory) {
                    cameraId = index;
                    break;
                }
            }

            if (cameraId == -1) {
                currentCategory = -1;

                forindex (var index; cameras) {
                    if (cameras[index].category > currentCategory) {
                        cameraId = index;
                        break;
                    }
                }
            }
        }
        else { # <<
            var maxCategory = -1;
            for (var index = size(cameras) - 1; index >= 0; index -= 1) {
                if (index < currentCamera and cameras[index].category < currentCategory) {
                    if (cameras[index].category > maxCategory) {
                        # find the first smaller by 1 and not smaller by 2 or 3,
                        # e.g. we have category 0, 1, 0, 3, we are on 3, and from 3 we have to go to 1 and not to 0
                        maxCategory = cameras[index].category;
                        cameraId = index;
                    }
                }
            }

            if (cameraId == -1) {
                currentCategory = -1;

                for (var index = size(cameras) - 1; index >= 0; index -= 1) {
                    if (cameras[index].category > currentCategory) {
                        cameraId = index;
                        break;
                    }
                }
            }
        }

        if (cameraId > -1) {
            popupTipF = 1;
            setprop(my_node_path ~ "/current-camera/camera-id", cameraId);
        }
    },

    #
    # Cycle through cameras within current category
    #
    # @param int direction - If direction > 0 - move forward, direction < 0 - move backward
    # @return void
    #
    _cycleCameraInCategory: func(direction) {
        var cameraId        = current[1];
        var currentCategory = cameras[cameraId].category;

        popupTipF = 1;

        var br = 0;
        while (!br) {
            if (direction < 0)
                cameraId -= 1;
            else
                cameraId += 1;

            if (cameraId < 0)
                cameraId += size(cameras);
            elsif (cameraId > (size(cameras) - 1))
                cameraId = 0;

            var category = cameras[cameraId].category;

            if (currentCategory == category) {
                setprop(my_node_path ~ "/current-camera/camera-id", cameraId);
                br = 1;
            }

            if (cameraId == current[1]) {
                br = 1;
            }
        }
    },
};

