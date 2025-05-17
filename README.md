GV-USB2 Linux Driver
====================

A linux driver for the IO-DATA GV-USB2 SD capture device.

Forked from Issac Lozano's main branch.

## Installation:

Ensure you have `build-essential` and updated `linux-headers`

Run: `sudo apt update && sudo apt install build-essential linux-headers-$(uname -r)`

Next, compile the drivers. They will have a few error/warning messages. This is fine (feature).

Run: `make`

Next, test run the drivers. This can be done using `insmod`

#### Video:

Run: `sudo insmod gvusb2-video.ko`

#### Audio (few more steps):

First, check your audio devices

Run:`cat /proc/asound/cards`

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

run: `sudo insmod gvusb2-sound.ko mainIndex=2`

Using `insmod` will only keep the drivers installed for this session. Once you reboot, you will need to run `insmod` like above. I'll add a small section for a permanent install in the future. 

#### Test it:

The easiest way to test is to use VLC.
In VLC, set video device name to the highest option (`/dev/videoX` where x is a number).
Set the audio device name to the same number we used earlier (`hw:2,0` in our example).

Under advanced options, be sure to set Input to 0 for composite, and 1 for S-Video.
Set resolution to 720x480
Set Frame Rate to 29.97 (NTSC)

You should be up and running!

## Install Script

This script will install the drivers to your kernel's driver folder `/x.x.x-generic/kernel/drivers/video`.
Read this script before you run it! Make sure it won't screw up your system first!
I've noticed that it loads the config super early, so usually the device id's get set to `/dev/video0` and `hw:0,0`. Not a huge deal but you may need to modify the script if this would conflict with something on your system.

```
#!/bin/bash

#install script v1.0

#clean our make directory and build new kernel modules
echo "building..."
make clean
make

#remove old versions of drivers in case there's any there
echo "cleaning previous drivers..."
sudo rm -f /lib/modules/$(uname -r)/kernel/drivers/video/gvusb2-sound.ko
sudo rm -f /lib/modules/$(uname -r)/kernel/drivers/video/gvusb2-video.ko

#copy our newly built drivers to our driver directory
echo "copying new drivers..."
sudo cp gvusb2-sound.ko /lib/modules/$(uname -r)/kernel/drivers/video
sudo cp gvusb2-video.ko /lib/modules/$(uname -r)/kernel/drivers/video

#register these modules
echo "depmod..."
sudo depmod

#get our sound devices
alsa_id=$(cat /proc/asound/cards | grep ]: | wc -l)
echo "alsa device id is: " $alsa_id

#setup auto load config
echo "setting up config..."
sudo echo "usbtv
gvusb2-sound mainIndex=$alsa_id
gvusb2-video" > /etc/modprobe.d/gvusb.conf
```

Works on my machine :)

## Troubleshooting/Issues

`dmesg` shows: `gvusb2-snd 3-2:1.2: cannont find the slot for index 0 (range 0-X), error: -16` You probably didn't set the correct `mainIndex` number, or didn't set one at all (it will default to 0). There is a pull request on the original's main branch from LeetLeaf that auto selects an ALSA Id, may contact them about that.

Occasional audio drop outs. This could be due to the driver, audio desync or something else in the audio stack. Looking into it (maybe).

Video is just a bunch of gray blocks when i turn on a device. Restart the capture stream in VLC. Something to do with too much signal. I think this can happen on windows too.
