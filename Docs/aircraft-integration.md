Aircraft integration API
========================

This file documents some integration API for your aircraft nasal code.

## Walker compatibility callbacks

|Callback / Variable|Description|
|-----------------------|---------------|
|`fgcamera.walker.getOutTime`|wait time in seconds after the `getOutCallback` executed|
|`fgcamera.walker.getInTime`|wait time in seconds after the `getInCallback` executed|
|`fgcamera.walker.getOutCallback()`|callback  when getting out|
|`fgcamera.walker.getInCallback()`|callback when getting in|


The example code for the Cessna C182S which opens the door if not open yet.

```nasal
#
# Example to open the door on the C182S/T when getting out or in:
# (this code should go to the aircraft nasal script)
#
if (addons.isAddonLoaded("a.marius.FGCamera")) {
    fgcamera.walker.getOutCallback = func {
        fgcamera.walker.getOutTime = getprop("/sim/model/door-positions/DoorL/opened") == 0 ? 2 : 0;
        c182s.DoorL.open();
    };

    fgcamera.walker.getInCallback = func {
        view.setViewByIndex(110); # so we stay outside (under the hood we are already switched one frame into the pilot seat, which we must roll back)
        fgcamera.walker.getInTime = getprop("/sim/model/door-positions/DoorL/opened") == 0 ? 2 : 0;
        c182s.DoorL.close();
    };
}
```