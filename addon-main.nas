#
# FGCamera addon
#
# Started by Marius_A
# Started on December 2013
#
# Converted to a FlightGear addon by
# Slawek Mikula, October 2017

var main = func(addon) {
    var basePath = addon.basePath;

    # load scripts
    foreach (var file; ["fgcamera"]) {
        io.load_nasal(basePath ~ "/" ~ file ~ ".nas", "fgcamera");
    }
}
