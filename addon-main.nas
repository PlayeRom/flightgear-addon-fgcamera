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
		"Nasal/version",
		"Nasal/gui",
		"Nasal/commands",
		"Nasal/io",
		"Nasal/mouse",
		"Nasal/offset_template",
		"Nasal/offset_movement",
		"Nasal/offset_DHM",
		"Nasal/offset_RND",
		"Nasal/offset_trackir",
		"Nasal/offset_linuxtrack",
		"Nasal/offset_adjustment",
		"Nasal/offset_mouselook",
		"Nasal/offsets_manager",
		"fgcamera",
	];

	# load scripts
	foreach (var file; files) {
		io.load_nasal(basePath ~ "/" ~ file ~ ".nas", "fgcamera");
	}
}
