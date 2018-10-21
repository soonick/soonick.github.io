---
id: 1888
title: Detect when Android emulator is ready
date: 2014-01-24T01:28:20+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1888
permalink: /2014/01/detect-when-android-emulator-is-ready/
tags:
  - android
  - mobile
  - automation
  - productivity
  - testing
---
I am writing an Android app, so as any good developer I want to have some tests in place that run continuously to make sure my app doesn&#8217;t break. The thing about Android is that I need an emulator in order to run my unit tests, so I need a way to start the emulator and detect that it is ready to be used. To do this we need to verify if the boot animation has finished using this command:

```
adb shell getprop init.svc.bootanim
```

Now, the only thing we need to do is call this command constantly until we get &#8220;stopped&#8221;:

```sh
#!/usr/bin/env bash

# Kill emulator
adb -s emulator-5554 emu kill

# Start the emulator
emulator -avd NexusOne -gpu on -qemu -enable-kvm &

# Don't exit until emulator is loaded
output=''
while [[ ${output:0:7} != 'stopped' ]]; do
  output=`adb shell getprop init.svc.bootanim`
  sleep 1
done
```

<!--more-->
