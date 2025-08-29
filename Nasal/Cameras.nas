#
# Cameras class
#
var Cameras = {
    #
    # Constructor
    #
    # @return me
    #
    new: func () {
        return {
            parents  : [Cameras],
            _cameras : std.Vector.new(),
            _current : {
                viewId   : 0,
                cameraId : 0,
            },
        };
    },

    #
    # Append new camera.
    #
    # @param  hash  camera
    # @return void
    #
    append: func(camera) {
        me._cameras.append(camera);
    },

    #
    # Remove all cameras.
    #
    # @return void
    #
    clear: func {
        me._cameras.clear();
    },

    #
    # Remove all cameras and append new ones.
    #
    # @param  vector  cameras  Vector of new cameras.
    # @return void
    #
    replace: func (cameras) {
        me._cameras.clear();
        me._cameras.extend(cameras);
    },

    #
    # Return vector of all cameras.
    #
    # @return vector
    #
    getVector: func {
        return me._cameras.vector;
    },

    #
    # Return camera given by index.
    #
    # @param  int  index
    # @return hash
    #
    getCamera: func(index) {
        if (index < 0 or index >= me.size()) {
            index = 0;
        }

        return me._cameras.vector[index];
    },

    #
    # Get current camera.
    #
    # @return hash
    #
    getCurrent: func {
        return me.getCamera(me._current.cameraId);
    },

    #
    # Return the number of cameras.
    #
    # @return int
    #
    size: func {
        return me._cameras.size();
    },

    #
    # Return ID of current camera.
    #
    # @return int
    #
    getCurrentId: func {
        return me._current.cameraId;
    },

    #
    # Set ID of current camera.
    #
    # @param  int  id
    # @return void
    #
    setCurrentId: func (id) {
        return me._current.cameraId = id;
    },

    #
    # Return ID of current view.
    #
    # @return int
    #
    getCurrentViewId: func {
        return me._current.viewId;
    },

    #
    # Set ID of current view.
    #
    # @param  int  id
    # @return void
    #
    setCurrentViewId: func (id) {
        return me._current.viewId = id;
    },
};
