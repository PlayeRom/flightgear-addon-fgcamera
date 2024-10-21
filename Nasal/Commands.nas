#==================================================
#   API for fgcommands
#
#   fgcamera-select (<camera-id>)
#   fgcamera-adjust (<dof>, <velocity>)
#   fgcamera-save   ()
#   fgcamera-reset-view ()
#   fgcamera-next-category ()
#   fgcamera-prev-category ()
#   fgcamera-next-in-category ()
#   fgcamera-prev-in_category ()
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
        var commands = me._getCommandsHash();
        foreach (var name; keys(commands)) {
            addcommand(name, commands[name]);
        }
    },

    #
    # Get all commands in hash
    #
    # @return hash
    #
    _getCommandsHash: func {
        return {
            "fgcamera-select": func {
                var data = cmdarg().getValues();
                setprop(g_myNodePath ~ "/popupTip", 1);
                setprop(g_myNodePath ~ "/current-camera/camera-id", data["camera-id"]);
            },

            "fgcamera-adjust": func {
                var data = cmdarg().getValues();
                setprop(g_myNodePath ~ "/controls/adjust-" ~ data.dof, data.velocity);
            },

            "fgcamera-save": func {
                setprop(g_myNodePath ~ "/save-cameras", 1);
            },

            "fgcamera-reset-view": func {
                setprop(g_myNodePath ~ "/popupTip", 0);
                setprop(g_myNodePath ~ "/current-camera/camera-id", cameras.getCurrentId());
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
        var maxCategory = -999999;
        var minCategory = 999999;

        # Prepare sorting structure without category duplicates
        var camerasToSort = std.Vector.new();
        forindex (var index; cameras.getVector()) {
            var category = cameras.getCamera(index).category;

            # is category already included
            var exist = 0;
            forindex (var i; camerasToSort.vector) {
                if (camerasToSort.vector[i].category == category) {
                    exist = 1;
                    break;
                }
            }

            if (!exist) {
                if (category > maxCategory) {
                    maxCategory = category;
                }

                if (category < minCategory) {
                    minCategory = category;
                }

                camerasToSort.append({
                    'id': index,
                    'category': category,
                });
            }
        }

        # Sorting by category
        var size = camerasToSort.size();
        forindex (var i; camerasToSort.vector) {
            for (var j = 0; j < size - 1; j += 1) {
                if (camerasToSort.vector[i].category < camerasToSort.vector[j].category) {
                    # swap position
                    var id       = camerasToSort.vector[i].id;
                    var category = camerasToSort.vector[i].category;

                    camerasToSort.vector[i].id       = camerasToSort.vector[j].id;
                    camerasToSort.vector[i].category = camerasToSort.vector[j].category;

                    camerasToSort.vector[j].id       = id;
                    camerasToSort.vector[j].category = category;
                }
            }
        }

        var categoryIterator = cameras.getCurrent().category;
        var br = 0;
        while (!br) {
            if (direction > 0) { # Button [>>]
                categoryIterator += 1;
            }
            else { # Button [<<]
                categoryIterator -= 1;
            }

            # protect against overreach
            if (categoryIterator < 0) {
                categoryIterator = maxCategory;
            }
            elsif (categoryIterator > maxCategory) {
                categoryIterator = minCategory;
            }

            # find matching category
            forindex (var i; camerasToSort.vector) {
                var camera = camerasToSort.vector[i];
                if (camera.category == categoryIterator) {
                    # found it
                    setprop(g_myNodePath ~ "/popupTip", 1);
                    setprop(g_myNodePath ~ "/current-camera/camera-id", camera.id);
                    br = 1;
                    break;
                }
            }
        }
    },

    #
    # Cycle through cameras within current category
    #
    # @param int direction - If direction > 0 - move forward, direction < 0 - move backward
    # @return void
    #
    _cycleCameraInCategory: func(direction) {
        var cameraId        = cameras.getCurrentId();
        var currentCategory = cameras.getCurrent().category;

        setprop(g_myNodePath ~ "/popupTip", 1);

        var br = 0;
        while (!br) {
            if (direction < 0) { # Button [<]
                cameraId -= 1;
            }
            else { # Button [>]
                cameraId += 1;
            }

            if (cameraId < 0) {
                cameraId = cameras.size() - 1;
            }
            elsif (cameraId > (cameras.size() - 1)) {
                cameraId = 0;
            }

            var category = cameras.getCamera(cameraId).category;

            if (currentCategory == category) {
                setprop(g_myNodePath ~ "/current-camera/camera-id", cameraId);
                br = 1;
            }

            if (cameraId == cameras.getCurrentId()) {
                br = 1;
            }
        }
    },
};

