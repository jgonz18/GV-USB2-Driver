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
