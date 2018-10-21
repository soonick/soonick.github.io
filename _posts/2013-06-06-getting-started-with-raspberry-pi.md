---
id: 1359
title: Getting started with Raspberry Pi
date: 2013-06-06T05:41:52+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1359
permalink: /2013/06/getting-started-with-raspberry-pi/
tags:
  - linux
  - bootstrapping
  - hardware
  - raspberry_pi
---
I got my hands into a Raspberry Pi, so I thought it was time to start playing with it. My goal is to show the first steps to get your Pi running, so basically installing the OS in the SD card.

I am going to install Raspbian, which you can get from [Raspberry Pi&#8217;s download page](http://www.raspberrypi.org/downloads "Raspberry Pi download page"). I used the torrent option, which downloaded a zip file. After getting the zip file, extract it&#8217;s contents and keep it handy for later.

To verify which devices are mounted run:

```
df -h
```

Now insert your SD card in your computer and run the command again. The device that wasn&#8217;t there is your SD card. The output looks something like this:

```
/dev/sdb1  3.7G 4.0K  3.7G  1% /media/adrian/Pi
```

Now that we know the device, we need to unmount it:

```
umount /dev/sdb1
```

<!--more-->

Now we need to use the dd command to copy the image to our SD card. Be careful with this command because it will overwrite the contents of the target partition, so make sure you specify the right one. Replace **2013-02-09-wheezy-raspbian.img** below with the location of your Raspbian image and **/dev/sdb1** with your device partition.

```
sudo dd bs=4M if=2013-02-09-wheezy-raspbian.img of=/dev/sdb1
```

The dd command will not give you any information about the progress, so don&#8217;t worry and expect a ten minute wait. When the command is finished you can remove the the SD card from your computer and insert it into your Raspberry Pi.

The first time the system starts you will see a box with many options to select from. I selected:

  * expand_rootfs, to make the root partition ocuppy the whole disk
  * change_pass, to set the system password
  * ssh, to enable ssh server
  * boot_behaviour, to disable desktop boot
  * update, to update raspi config with my selections

Clicked the Finish button and got a terminal prompt. Executed:

```
sudo reboot
```

And my system is ready. When the system restarts you can login using user **pi** and the password you selected in the previous step.
