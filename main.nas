#
# FGCamera addon
#
# Started by ....
# Started ....
#
# Converted to a FlightGear addon by
# Slawek Mikula, October 2017


var main = func( root ) {
    # setting root path to addon
    setprop("/sim/fgcamera/root_path", root);

    # load scripts
    foreach(var f; ['loader.nas','fgcamera.nas'] ) {
        io.load_nasal( root ~ "/" ~ f, "fgcamera" );
    }

    # load properties
    io.read_properties(root ~ "/prop_CR.xml", "/fgcamera/cr");
    io.read_properties(root ~ "/prop_RND.xml", "/fgcamera/rnd");
}
