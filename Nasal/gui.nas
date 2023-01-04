#==================================================
#	GUI loader and handler
#==================================================

#--------------------------------------------------
var load_gui = func {
	var dialogs   = [
		"fgcamera-main",
		"create-new-camera",
		"current-camera-settings",
		"fgcamera-options",
		"DHM-settings",
		"RND-mixer",
		"RND-generator",
		"RND-curves",
		"RND-import",
		"fgcamera-help",
		"fgcamera-welcome",
	];

	var menu_item_name = "fgcamera";

	foreach (var name; dialogs) {
		gui.Dialog.new(
			"/sim/gui/dialogs/" ~ name ~ "/dialog",
			my_root_path ~ "/GUI/" ~ name ~ ".xml"
		);
	}

	var data = {
		label   : "FGCamera",
		name    : menu_item_name,
		binding : {
			"command"     : "dialog-show",
			"dialog-name" : "fgcamera-main",
		}
	};

	if (!is_menu_item_exists(menu_item_name)) {
		props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);
	}

	fgcommand("gui-redraw");

	register_gui_mini_dialogs();
}

#--------------------------------------------------
var show_dialog = func (show = 0) {
	if (cameras[current[1]]["dialog-show"] or show)
		gui.showDialog(cameras[current[1]]["dialog-name"]);
}

#--------------------------------------------------
var close_dialog = func (close = 0) {
	if (cameras[current[1]]["dialog-show"] or close)
		fgcommand ( "dialog-close", props.Node.new({ "dialog-name" : cameras[current[1]]["dialog-name"] }) );
}

#--------------------------------------------------
# Prevent to add menu item more than once, e.g. after reload the sim by <Shift-Esc>
var is_menu_item_exists = func (menu_item_name) {
	foreach (var item; props.globals.getNode("/sim/menubar/default/menu[1]").getChildren("item")) {
		var name = item.getChild("name");
		if (name != nil and name.getValue() == menu_item_name) {
			print("Menu item FGCamera alredy exists");
			return 1;
		}
	}

	return 0;
}

var register_gui_mini_dialogs = func {

	var x_size = getprop("/sim/startup/xsize");
	var y_size = getprop("/sim/startup/ysize");

	var calc_screen_xsize = func x_size = getprop("/sim/startup/xsize");
	var calc_screen_ysize = func y_size = getprop("/sim/startup/ysize");

	setlistener("/sim/startup/xsize", func calc_screen_xsize());
	setlistener("/sim/startup/ysize", func calc_screen_ysize());

	var __mouse = {
		x: func getprop("/devices/status/mice/mouse/x") or 0,
		y: func getprop("/devices/status/mice/mouse/y") or 0,
	};


	mini_dialog = gui.Dialog.new(
		"/sim/gui/dialogs/fgcamera-mini-dialog/dialog",
		my_root_path ~ "/GUI/fgcamera-mini-dialog.xml"
	);

	setlistener("/devices/status/mice/mouse/y", func {
		if (!getprop("/sim/fgcamera/mini-dialog-enable")) {
			if (mini_dialog.is_open()) {
				mini_dialog.close();
			}

			return;
		}

		if (getprop("/sim/fgcamera/mini-dialog-autohide")) {
			if ( (__mouse.y() > (y_size - 120)) and (__mouse.x() < 200) ) {
				if (!mini_dialog.is_open()) {
					mini_dialog.open();
				}
			}
			else if (mini_dialog.is_open()) {
				mini_dialog.close();
			}
		}
		else if (!mini_dialog.is_open()) {
			mini_dialog.open();
		}
	}, 1, 0);
}

print("GUI loaded");
