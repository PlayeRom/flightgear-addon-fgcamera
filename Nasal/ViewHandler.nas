#
# ViewHandler representing one of the five camera views that is registered to the FlightGear
#
var ViewHandler = {
    #
    # Constructor
    #
    # @param  hash  viewsManager  Object of ViewsManager
    # @return me
    #
    new: func (viewsManager) {
        return {
            parents       : [ViewHandler],
            _viewsManager : viewsManager,
        };
    },

    #
    # Callback function form FlightGear, called only once at startup
    #
    # @return void
    #
    init: func {
        offsetsManager.init();
    },

    #
    # Callback function form FlightGear, called when view is switched to our view
    #
    # @return void
    #
    start: func {
        offsetsManager.start();
        me._viewsManager.configureFG(1);
    },

    #
    # Callback function form FlightGear, called iteratively.
    #
    # @return double  Interval in seconds until next invocation.
    #
    update: func {
        return offsetsManager.update();
    },

    #
    # Callback function form FlightGear, called when view is switched away from our view
    #
    # @return void
    #
    stop: func {
        offsetsManager.stop();
        me._viewsManager.configureFG(0);
    },
};
