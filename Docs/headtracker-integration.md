Head Tracker integration
========================

Head Tracking is implemented in `Nasal/Offsets/HeadTrackers/{trackername}.nas` files. Currently available integration with:

* Linux Track - `Nasal/Offsets/HeadTrackers/LinuxTrackHandler.nas`
* TrackIR - `Nasal/Offsets/HeadTrackers/TrackIrHandler.nas`

However, these trackers are not enabled by default because most people don't need them. You can enable the tracker you need in FGCamera Options.

# Adding new integration

* Create file with content similar to core head tracking software.
* Add offset handler to handlers variable in `Nasal/OffsetsManager.nas` file.
