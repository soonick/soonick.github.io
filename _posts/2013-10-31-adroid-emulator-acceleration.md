---
id: 1824
title: Android emulator acceleration
date: 2013-10-31T06:05:58+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1824
permalink: /2013/10/adroid-emulator-acceleration/
categories:
  - Mobile development
tags:
  - android
  - automation
  - hardware
  - linux
  - mobile
  - productivity
---
The android emulator if used as it comes from the package is pretty slow, so it is good to know that there are ways to make it a little faster.

## Graphics acceleration

To use this feature you need to have these versions installed:

  * Android SDK Tools, Revision 17 or higher
  * Android SDK Platform API 15, Revision 3 or higher

You can verify that you meet these requirements by launching the android app:

```
/path/to/android-sdk/tools/android
```

<!--more-->

And checking the following values:

[<img src="http://ncona.com/wp-content/uploads/2013/10/Screenshot-1.png" alt="android versions" width="675" height="585" class="alignnone size-full wp-image-1825" srcset="https://ncona.com/wp-content/uploads/2013/10/Screenshot-1.png 675w, https://ncona.com/wp-content/uploads/2013/10/Screenshot-1-300x260.png 300w" sizes="(max-width: 675px) 100vw, 675px" />](http://ncona.com/wp-content/uploads/2013/10/Screenshot-1.png)

Once the requirements have been met you want to create a virtual device that can use the acceleration. For this you can use the avd tool.

```
/path/to/android-sdk/tools/android avd
```

Create a device with target value of Android 4.0.3 (API Level 15), revision 3 or higher and run it using this command:

```
/path/to/android-sdk/tools/emulator -avd EmulatorName -gpu on
```

## Virtual machine acceleration

To make use of virtual machine acceleration you need to complete these requirements:

  * Android SDK Tools, Revision 17 or higher
  * Android x86-based system image

You can use the **android** command to make sure they are installed the same way you did for graphics acceleration. You will also need to Make sure your emulator uses x86 in the CPU/ABI field, to verify or change this value you can use **android avd** command.

You will also need to install kvm:

```
yum install kvm
```

Now you can use this command to use the acceleration:

```
/path/to/android-sdk/tools/emulator -avd EmulatorName -gpu on -qemu -enable-kvm
```

Now the simulator takes a lot less time to start and runs a lot faster.
