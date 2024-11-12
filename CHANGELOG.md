CHANGELOG
=========

# 1.2.7

* Head trackers as an option (until now, they all always worked, even though they might not have been used).
* Add camera presets and possibility to import them in runtime. We don't have a lot of presets at the moment, but I'm counting on your support. Please submit your configuration of any aircraft using https://fgcamera.flightgear.org.pl/
* Add "Browse Dialog Names" to the "Show Dialog" option, which will make it easier to point to dialog names, at least the FlightGear ones, which were too technical for many.
* DHM config affect the camera (until now, these DHM sliders were a dummy and the configuration was hard-coded).
* Add button to set default DHM config.
* Add possibility to execute custom Nasal scripts for camera entry and leave actions.
* Display current camera name in the bar of  "Current Camera Config" dialog.
* Rearrange the layout:
    * move "Copy camera" button to "Current camera" section in main dialog, because the copy is strictly for the current camera;
    * move "Store position" button from "Current Camera Config" dialog to "Current camera" section in main dialog, and change it's name to "Confirm position". "Confirm position" in the Config dialog could erroneously suggest that changes in the Config dialog must be confirmed with this button, which is not true. This button is used to confirm changes to the camera position made using the keyboard and looking around with the mouse, nothing related to Config dialog.
    * change camera group text input to combobox (there numbers must be given and text input allowed to enter anything)
* The main dialog is now resizable
* Update documentations

# 1.2.6

* Restore the "world (look at)" camera which positions itself in the tower position and the view always follows the aircraft.

# 1.2.5

* Fix iterate through camera categories in mini-dialog

# 1.2.4

* add mini-dialogs to toggle cameras and categories,
* add option to user 0-9 keys with Ctrl to possibility control the aircraft,
* add options to mini-dialogs,
* add smooth FOV changes when transitioning between cameras with different FOVs,
* add confirmation dialog for delete camera,
* fix selecting default FGCamera on startup,
* fix inputs for save changes immediately after click save/store button without the needed for change focus first,
* others small GUI improvements,

# 1.2.3

* fix create new camera,
* fix count cameras from 1,
* add welcome message,
* add help message

# 1.2.2

* #5 (reverse mouse controls - the same as in FG),
* #3 disable space keyboard mapping,
* #10 adds additional API for walker aircraft integration

# 1.2.1

* addon compatibility + small fixes

# 1.0-1.2

* versions published on the FlightGear forum
