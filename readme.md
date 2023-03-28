FGCamera FlightGear Addon
=========================

# About

FlightGear virtual camera. Written in NASAL. Adds features similar to Ezdok Camera Addon for FSX.

# Running

- extract zip (if downloaded as a zip) to a given location. For example let's
  say we have `/myfolder/addons/fgcamera` with contents of this addon.
- add path to the addon in the Launcher application in 'Add-On' section **OR**
  run FlightGear with `--addon` option with path to FGCamera like
  `--addon="/myfolder/addons/fgcamera"`.

# Documentation

More documents can be found in the Docs folder.

# Configuration

- all can be configured through GUI available in the main menu under `View -> FGCamera`
- settings regarding each aircraft are stored in
  `$FG_HOME/aircraft-data/FGCamera/{aircraft name}/` directory.

# History

- 1.0-1.2 - versions published on the FlightGear forum
- 1.2.1 - addon compatiblity + small fixes
- 1.2.2
    * #5 (reverse mouse controls - the same as in FG),
    * #3 disable space keyboard mapping,
    * #10 adds additional API for walker aircraft integration
- 1.2.3:
    * fix create new camera,
    * fix count cameras from 1,
    * add welcome message,
    * add help message
- 1.2.4:
    * add mini-dialogs to toggle cameras and categories,
    * add option to user 0-9 keys with Ctrl to possibility control the aircraft,
    * add options to mini-dialogs,
    * add smooth FOV changes when transitioning between cameras with different FOVs,
    * add confirmation dialog for delete camera,
    * fix selecting default FGCamera on startup,
    * fix inputs for save changes immediately after click save/store button without the needed for change focus first,
    * others small GUI improvements,
- 1.2.5:
    * Fix iterate through camera categories in mini-dialog

# Planned (branch next)

- 2.x
  - new GUI for configuration
  - logic moved to property-rules

# Authors

- Marius_A - concept, coding
- Slawek Mikula - addon compatiblity
- Roman Ludwicki (PlayeRom) - fixes and improvements

# Links

- FlightGear wiki: [Wiki](http://wiki.flightgear.org/FGCamera)
- FlightGear forum: [Forum](https://forum.flightgear.org/viewtopic.php?f=6&t=21685)

# License

GNU General Public License version 2 or, at your option, any later version
(https://forum.flightgear.org/viewtopic.php?f=6&t=21685&p=314678#p314678)
