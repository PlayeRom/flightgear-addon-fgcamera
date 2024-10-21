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
		"Nasal/Offsets/TrackIrHandler",
		"Nasal/Offsets/LinuxTrackHandler",
		"Nasal/Offsets/AdjustmentHandler",
		"Nasal/Offsets/MouseLookHandler",
		"Nasal/Offsets/OffsetsManager",
		"Nasal/Panel2D",
		"Nasal/Views",
		"Nasal/Walker",
		"FGCamera",
	];

	# load scripts
	foreach (var file; files) {
		if (!io.load_nasal(basePath ~ "/" ~ file ~ ".nas", "fgcamera")) {
			logprint(LOG_ALERT, "FGCamera: add-on module \"", file, "\" loading failed");
		}
	}

	fgcamera.init(addon);
}
