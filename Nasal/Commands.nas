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
    # Constants
    #
    TIMER_INTERVAL: 0.4,

    #
    # Constructor
    #
    # @return me
    #
    new: func () {
        var me = { parents: [Commands] };

        me._addCommands();

        me._timers = {
            x: maketimer(Commands.TIMER_INTERVAL, func setprop(g_myNodePath ~ "/controls/adjust-x", 0) ),
            y: maketimer(Commands.TIMER_INTERVAL, func setprop(g_myNodePath ~ "/controls/adjust-y", 0) ),
            z: maketimer(Commands.TIMER_INTERVAL, func setprop(g_myNodePath ~ "/controls/adjust-z", 0) ),
        };

        me._timers.x.singleShot = true;
        me._timers.y.singleShot = true;
        me._timers.z.singleShot = true;

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

            #
            # Parameters:
            #  * dof - the axis along which we move the camera, "x", "y" and "z"
            #  * velocity - move direction, for X: -1 - left,    1 - right
            #                               for Y: -1 - down,    1 - up
            #                               for Z: -1 - forward, 1 - backward
            #               A value of 0 means stopping the movement for a given axis.
            "fgcamera-adjust": func {
                var data = cmdarg().getValues();
                setprop(g_myNodePath ~ "/controls/adjust-" ~ data.dof, data.velocity);

                # FlightGear has a keyboard handling bug that if you hold, for example, Ctrl+Up, and release the Ctrl
                # key first, FlightGear won't recognize the “<mod-up>” key raise event, and we won't get a signal that
                # the key has been released and that we need to stop moving the camera. So the camera will keep moving
                # indefinitely until the user gives another key command.
                # Therefore, I made a workaround with timers, for each X, Y and Z axis.
                # When the user holds the keys for any of the axes, the timer for that axis starts counting. When the
                # user keeps holding the keys, the timer restarts and the timer function does not execute. If the user
                # releases the keys (especially in the wrong order), the timer function is finally executed (we stop
                # receiving "fgcamera-adjust" events) and the camera stops moving.
                if (data.velocity != 0) {
                    me._timers[data.dof].isRunning
                        ? me._timers[data.dof].restart(Commands.TIMER_INTERVAL)
                        : me._timers[data.dof].start();
                }
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
            var exist = false;
            forindex (var i; camerasToSort.vector) {
                if (camerasToSort.vector[i].category == category) {
                    exist = true;
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
        var br = false;
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
            foreach (var camera; camerasToSort.vector) {
                if (camera.category == categoryIterator) {
                    # found it
                    fgcommand("fgcamera-select", props.Node.new({ "camera-id": camera.id }));
                    br = true;
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

        var br = false;
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

            var category = num(cameras.getCamera(cameraId).category);

            if (currentCategory == category) {
                fgcommand("fgcamera-select", props.Node.new({ "camera-id": cameraId }));
                br = true;
            }
            elsif (cameraId == cameras.getCurrentId()) {
                br = true;
            }
        }
    },
};

