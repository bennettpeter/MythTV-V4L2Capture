# MythTV-V4l2Capture

This is a method for recording from a set top box. The concept is similar to the HD-PVR except that this uses the cable box HDMI output, and this requires no special drivers.

## Advantages

- Do not need a cable card device
- You can record all channnels, including those the cable company has converted to IPTV.
- All recordings use H264 encoding.

## Disadvantages

- Only records stereo audio (no surround sound).
- Does not support closed captions.
- You need a script to change channels, using firewire or IR blaster. That is not addressed here. If you are coming from an HD-PVR setup you may already have a solution for this.

## Hardware required

- Cable company set top box with HDMI output.
- USB Capture device. There are many brands available from Amazon. Those that advertise 3840x2160 input and 1920x1080 output, costing $5 and up, have been verified to work. These are USB 2 devices. Running `lsusb` with any of them mounted shows the device with `ID 534d:2109`.
- USB 2 or USB 3 extension cable, 6 inches or more. Plugging the capture device directly into the MythTV backend without an extension cable is unstable. Note that some capture devices have the usb connector on a wire attached to the device and these will not need a USB extension.
- You can use additional sets of the above three items to support multiple recordings at the same time.
- MythTV backend on a Linux device. This must have a CPU capable of real-time encoding the number of simultaneous channels you will be recording.

### CPU power required

Since the backend will be encoding real-time, it needs sufficient CPU power. To determine how many fire sticks you can connect, find out how many encodes you can do at one time.

Run this on your backend to get a value:

    sysbench --num-threads=$(nproc) --max-time=10 --test=cpu run

Look at the resulting *events per second*. Based on my simple testing, each encode will take approximately 1200 out of this, when using CRF 21 and preset veryfast. I do not recommend loading the CPU to 100%, preferably do not go much over 50%. If your *events per second* is 2400 you could theoretically do 2 encodes at a time, but should limit it to 1 to allow for other things running in the system. if it is 10000, you could theoretically do 8 at a time, but I would limit it to 4 or 5.

With preset faster and CRF 22 it needs 2000 events per second for each encode. With preset veryfast and CRF 21 it needs 1200 events per second for each encode. Varying these parameters gives different quality, file size and cpu usage. These parameters are set in the /etc/opt/mythtv/v4l2capture.conf file.

https://superuser.com/questions/490683/cheat-sheets-and-presets-settings-that-actually-work-with-ffmpeg-1-0

Since I tested on only a few backends, these figures may not be reliable. This is only a rough guide. Once you have your setup running, set a recording going and run mpstat 1 10 to see the %idle to get a better idea of how much CPU is being used.

A raspberry pi 2 shows events per second of 178. Do not try to run *V4l2Capture* on a raspberry pi!

## Hardware Installation

Connect each set top box to a capture device. Connect each to a USB socket on the MythTV backend.

## Software installation

### Linux Machine

Prerequisite software for these scripts can be installed on Linux with the distribution package manager.

- vlc
- ffmpeg

If you are using MythTV with the default user and group mythtv, install the scripts by running

    sudo ./install.sh

If you are not using the default user and group, run ./install.sh as follows. Put in your user id and group (the user that will be doing recording).

    sudo MYTHTVUSER=<user> MYTHTVGROUP=<group> ./install.sh

The install.sh script tests for the presence of required versions and stops if they are not present. After installing, reboot the system so the udev rule can take effect.

The install script assumes the mythbackend user id is mythtv, and group id is mythtv. It assumes script directory /opt/mythtv/v4l2cap. You can use different values by setting appropriate environment variables before running install.sh the first time. See the top of install.sh for the names.

If there is a new or updated version of the scripts, make sure you save any customizations of the scripts before running ./install.sh again. It will not overwrite settings files you have updated, but it will overwrite scripts. After the initial install you do not need the MYTHTVUSER=<user> MYTHTVGROUP=<group> It uses stored entries from the first install. If you need to change the user and group, run sudo ./uninstall.sh and then install again with the new settings.

After installing, reboot so that the udev setting can take effect.

## Configuration

### Linux

#### /etc/opt/mythtv/v4l2capture.conf

Parameters for recordings are set here. The default settings work well. Comments in the file explain the settings.

#### /etc/opt/mythtv/v4l2cap1.conf

Set the video and audio device here. You can use vlc to check the settings.

There are comment lines in the default file explaining the settings. You need to decide on the screen resolution and frame rate you want to use for recordings. The capture devices mentioned above can handle 1920x1080 at 30fps and 1280x720 at 60fps. The settings here determine what is recorded. If the set top box uses different resolution, it will be converted in the capture device.

You need one file for each fire stick device, named /etc/opt/mythtv/v4l2capx, where x is a single character, normally 1-9.

You can add your own parameters here and access them in the tuning and cleanup scripts. For an example see the ANDROID_DEVICE parameter in the file

#### /etc/udev/rules.d/89-pulseaudio-usb.rules

This file prevents pulseaudio or pipewire grabbing the audio output of your capture devices. Run `lsusb` and see if there is a value of `ID 534d:2109` in the results. This identifies the specific capture device I have listed above. If that is present you need not change this file, it is correctly set up. Otherwise identify the device id by running `lsusb -v|less` and search for "Video". Look for `ID xxxx:xxxx` in the corresponding entry and enter those values in the 89-pulseaudio-usb.rules file.

If you change the udev rules, reboot to make sure the change takes effect.

#### /opt/mythtv/v4l2cap/v4l2_tune.sh

Customize the script by adding your own code to change the channel in place of the sample code in the file.

#### /opt/mythtv/v4l2cap/v4l2_cleanup.sh

Customize the script by adding your own code to clean up at the end of a recording in place of the sample code in the file.

### MythTV

#### Capture Cards

Add a capture card for each Fire Stick / Capture device.

- Card Type: External (black box) Recorder
- Command Path: As below. Change the path if you used a different install location. Set the parameter to the name of the conf file for the specific USB device (v4l2capx).


`/opt/mythtv/v4l2cap/v4l2capture.sh v4l2cap1`


#### Video Sources

Set up as normal for MythTV.

#### Input Connections

For each EXTERNAL entry, set up as follows:

- Input Name: MPEG2TS
- Display Name: Your preference for identifying the device
- Video Source: Name of the source you set up
- External Channel Change Command: Leave blank. Channel Change is set up in the /opt/mythtv/v4l2cap/v4l2_tune.sh file
- Preset Tuner to Channel: Leave Blank
- Scan for Channels: Do not use
- Fetch Channels from Listings Source: Do not use
- Starting Channel: Set a value that is in your channel list.
- Interactions Between Inputs
    - Max Recordings: 2
    - Schedule as Group: Checked
    - Input Priority: 0 or other value as needed to determine which device to use.
    - Schedule Order: Set to sequence order for using vs other capture cards. Set to 0 to prevent recordings on this device.
    - Live TV Order:  Set to sequence order for using vs other capture cards. Set to 0 to prevent Live TV on this device.

### Test audio/video setup

Run this from a command line

    /opt/mythtv/v4l2cap/v4l2vlc.sh v4l2cap1

This will open vlc and show the picture at 1280x720. Make sure audio and video are working. Repeat this with v4l2cap2 etc. if you have those set up.


