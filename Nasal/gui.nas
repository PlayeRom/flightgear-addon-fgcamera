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

#--------------------------------------------------
var node_mini_dialog_enable   = globals.props.getNode("/sim/fgcamera/mini-dialog-enable");
var node_mini_dialog_type     = globals.props.getNode("/sim/fgcamera/mini-dialog-type");
var node_mini_dialog_augohide = globals.props.getNode("/sim/fgcamera/mini-dialog-autohide");

var node_mouse_x = globals.props.getNode("/devices/status/mice/mouse/x");
var node_mouse_y = globals.props.getNode("/devices/status/mice/mouse/y");
var node_ysize   = globals.props.getNode("/sim/startup/ysize");

var mini_dialog_simple = nil;
var mini_dialog_slots  = nil;
var miniDialogListener = nil;

var register_gui_mini_dialogs = func {
	mini_dialog_simple = gui.Dialog.new(
		"/sim/gui/dialogs/fgcamera-mini-dialog-simple/dialog",
		my_root_path ~ "/GUI/fgcamera-mini-dialog-simple.xml"
	);

	mini_dialog_slots = gui.Dialog.new(
		"/sim/gui/dialogs/fgcamera-mini-dialog-slots/dialog",
		my_root_path ~ "/GUI/fgcamera-mini-dialog-slots.xml"
	);

	setMiniDialogListener();
};

var setMiniDialogListener = func {
	removeMiniDialogListener();

	if (!node_mini_dialog_enable.getBoolValue()) {
		close_all_mini_dialogs();
		return;
	}

	if (!node_mini_dialog_augohide.getBoolValue()) {
		close_all_mini_dialogs();
		open_mini_dialog();
		return;
	}

	var __mouse = {
		x: func node_mouse_x.getIntValue() or 0,
		y: func node_mouse_y.getIntValue() or 0,
	};

	miniDialogListener = _setlistener("/devices/status/mice/mouse/y", func {
		__mouse.y() > (node_ysize.getIntValue() - 120) and __mouse.x() < 200
			? open_mini_dialog()
			: close_mini_dialog();
	}, 1, 0);
};

var removeMiniDialogListener = func {
	if (miniDialogListener != nil) {
		removelistener(miniDialogListener);
		miniDialogListener = nil;
	}
};

var open_mini_dialog = func {
	if (node_mini_dialog_type.getValue() == "slots") {
		if (mini_dialog_simple.is_open()) {
			# Make sure that 2nd dialog is closed
			mini_dialog_simple.close();
		}

		if (!mini_dialog_slots.is_open()) {
			mini_dialog_slots.open();
		}
	}
	else {
		if (mini_dialog_slots.is_open()) {
			# Make sure that 2nd dialog is closed
			mini_dialog_slots.close();
		}

		if (!mini_dialog_simple.is_open()) {
			mini_dialog_simple.open();
		}
	}
};

var close_mini_dialog = func {
	if (node_mini_dialog_type.getValue() == "slots") {
		if (mini_dialog_slots.is_open()) {
			mini_dialog_slots.close();
		}
	}
	else {
		if (mini_dialog_simple.is_open()) {
			mini_dialog_simple.close();
		}
	}
};

var close_all_mini_dialogs = func {
	if (mini_dialog_simple.is_open()) {
		mini_dialog_simple.close();
	}

	if (mini_dialog_slots.is_open()) {
		mini_dialog_slots.close();
	}
};

print("GUI loaded");
