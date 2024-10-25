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

    var files = [
        "Nasal/math",
        "Nasal/Cameras",
        "Nasal/Migration",
        "Nasal/Gui",
        "Nasal/Helicopter",
        "Nasal/Commands",
        "Nasal/FileHandler",
        "Nasal/Mouse",
        "Nasal/Offsets/TemplateHandler",
        "Nasal/Offsets/MovementHandler",
        "Nasal/Offsets/DHMHandler",
        "Nasal/Offsets/RNDHandler",
        "Nasal/Offsets/AdjustmentHandler",
        "Nasal/Offsets/MouseLookHandler",
        "Nasal/Offsets/HeadTrackers/TrackIrHandler",
        "Nasal/Offsets/HeadTrackers/LinuxTrackHandler",
        "Nasal/OffsetsManager",
        "Nasal/Panel2D",
        "Nasal/ViewHandler",
        "Nasal/ViewsManager",
        "Nasal/Walker",
        "Nasal/Nasal",
        "Nasal/Gui/CurrentCameraConfig",
        "Nasal/Gui/NasalConfig",
        "FGCamera",
    ];

    if (!isFG2024Version()) {
        # Nasal in 2024.x version is support `true` and `false` keywords but previous FG versions not,
        # so for them add Boolean.nas file
        files = ["Boolean"] ~ files;
    }

    # load scripts
    foreach (var file; files) {
        if (!io.load_nasal(basePath ~ "/" ~ file ~ ".nas", "fgcamera")) {
            logprint(LOG_ALERT, "FGCamera: add-on module \"", file, "\" loading failed");
        }
    }

    fgcamera.init(addon);
}

#
# @return bool  Return true if running on FG version 2024.x and later
#
var isFG2024Version = func() {
    var fgversion = getprop("/sim/version/flightgear");
    var (major, minor, patch) = split(".", fgversion);
    return major >= 2024;
}
