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
var commands = {
#--------------------------------------------------
	"fgcamera-select": func {
		var data = cmdarg().getValues();
		popupTipF = 1;
		setprop (my_node_path ~ "/current-camera/camera-id", data["camera-id"]);
	},
#--------------------------------------------------
	"fgcamera-adjust": func {
		var data = cmdarg().getValues();

		setprop (my_node_path ~ "/controls/adjust-" ~ data.dof, data.velocity);
	},
#--------------------------------------------------
	"fgcamera-save": func {
		setprop (my_node_path ~ "/save-cameras", 1);
	},
#--------------------------------------------------
	"fgcamera-reset-view": func {
		popupTipF = 0;
		setprop (my_node_path ~ "/current-camera/camera-id", current[1]);
	},
#--------------------------------------------------
	"fgcamera-next-category": func {
		cycle_category_only(1);
	},
#--------------------------------------------------
	"fgcamera-prev-category": func {
		cycle_category_only(-1);
	},
#--------------------------------------------------
	"fgcamera-next-in-category": func {
		cycle_camera_in_category(1);
	},
#--------------------------------------------------
	"fgcamera-prev-in-category": func {
		cycle_camera_in_category(-1);
	},
};

var cycle_category_only = func(dir) {
	var current_camera   = current[1];
	var current_category = cameras[current_camera].category;
	var camera_id = -1;

	if (dir > 0) { # >>
		forindex (var index; cameras) {
			if (index > current_camera and cameras[index].category > current_category) {
				camera_id = index;
				break;
			}
		}

		if (camera_id == -1) {
			current_category = -1;

			forindex (var index; cameras) {
				if (cameras[index].category > current_category) {
					camera_id = index;
					break;
				}
			}
		}
	}
	else { # <<
		var max_category = -1;
		for (var index = size(cameras) - 1; index >= 0; index -= 1) {
			if (index < current_camera and cameras[index].category < current_category) {
				if (cameras[index].category > max_category) {
					# find the first smaller by 1 and not smaller by 2 or 3,
					# e.g. we have category 0, 1, 0, 3, we are on 3, and from 3 we have to go to 1 and not to 0
					max_category = cameras[index].category;
					camera_id = index;
				}
			}
		}

		if (camera_id == -1) {
			current_category = -1;

			for (var index = size(cameras) - 1; index >= 0; index -= 1) {
				if (cameras[index].category > current_category) {
					camera_id = index;
					break;
				}
			}
		}
	}

	if (camera_id > -1) {
		popupTipF = 1;
		setprop(my_node_path ~ "/current-camera/camera-id", camera_id);
	}
};

#--------------------------------------------------
var cycle_camera_in_category = func(dir) {
	var camera_id        = current[1];
	var current_category = cameras[camera_id].category;

	popupTipF = 1;

	var br = 0;
	while (!br) {
		if (dir < 0)
			camera_id -= 1;
		else
			camera_id += 1;

		if (camera_id < 0)
			camera_id += size(cameras);
		elsif (camera_id > (size(cameras) - 1))
			camera_id = 0;

		var category = cameras[camera_id].category;

		if (current_category == category) {
			setprop(my_node_path ~ "/current-camera/camera-id", camera_id);
			br = 1;
		}

		if (camera_id == current[1]) {
			br = 1;
		}
	}
}

#--------------------------------------------------
var add_commands = func {
	foreach (var name; keys(commands)) {
		addcommand(name, commands[name]);
	}
}

print("Commands script loaded");
