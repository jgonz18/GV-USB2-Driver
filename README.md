GV-USB2 Linux Driver
====================

A linux driver for the IO-DATA GV-USB2 SD capture device.

Forked from Issac Lozano's main branch.

## Installation:

Ensure you have `build-essential` and updated `linux-headers`

Run: `sudo apt update && sudo apt install build-essential linux-headers-$(uname -r)`

Next, compile the drivers. They will have a few error/warning messages. This is fine (feature).

```
make clean

make
```

Next, test run the drivers. This can be done using `insmod`

Video:
`sudo insmod gvusb2-video.ko`

Audio (few more steps):

First, check your audio devices
`cat /proc/asound/cards`
Find the highest number, then add 1. This will be your sound card number when we install the sound driver.
Example:

```
user@computer:~$ cat /proc/asound/cards

 0 [NVidia	]: HDA-blah blah blah
		   more blah blah blah

 1 [Generic	]: HDA-blah blah blah
		   blah blah more blah
```

In this instance, the highest number is 1, so we would enter 2.

We then install the driver like so, using our special number:

`sudo insmod gvusb2-sound.ko mainIndex=2`

Both drivers should now be installed.

Test it:

Open VLC (or any video player that can open a camera/capture device). 
In VLC, set video device name to the highest option (`/dev/videoX` where x is a number).
Set the audio device name to the same number we used earlier (`hw:2,0` in our example).

Under advanced options, be sure to set Input to 0 for composite, and 1 for S-Video.
Set resolution to 720x480
Set Frame Rate to 29.97 (NTSC)

You should be up and running!

### Troubleshooting

The easiest way to troubleshoot is with `dmesg`, primarily for sound issues.

If you see something similar to: `gvusb2-snd 3-2:1.2: cannont find the slot for index 0 (range 0-X), error: -16`, you probably didn't set the correct `mainIndex` number, or didn't set one at all (it will default to 0).
