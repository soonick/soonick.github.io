---
id: 1206
title: 'Introduction to Android development - Building an application without an IDE'
date: 2013-02-28T03:41:16+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1206
permalink: /2013/02/introduction-to-android-development-building-an-application-without-an-ide/
tags:
  - android
  - java
  - mobile
---
> Android doesn&#8217;t support ant anymore. Take a look at: [Building an Android project from scratch using Gradle](http://ncona.com/2014/09/building-an-android-project-from-scratch-using-gradle/) to learn how to create a project with gradle. 

## Getting the environment set up

There are two packages needed for developing android applications. One is the Java Development Kit and the other is the Android SDK. You can install JDK with this command:

```
sudo apt-get install default-jdk
```

You can get Android SDK from this site: <http://developer.android.com/sdk/index.html>. The site will give you two options, to download ADT (Android Development Tookit), which is the SDK + Eclipse or just the SDK. Choose to download only the SDK.

After downloading the package you need to unzip it, open a terminal, navigate to the folder where you downloaded it, go the the tools folder and run the android script:

```
cd /android-sdk/tools
./android
```

<!--more-->

Now you will find yourself in the Android SDK Manager. This tool allows us to download the libraries we need to start developing for Android. The official documentation recommends to begin by downloading all the **Tools** folder, the latest **Android** folder and the package **Android Support Library** under **Extras**.

For running on Fedora I also needed these libraries:

```
yum install ncurses-libs.i686 libstdc++.i686 glibc.i686
```

## Creating an Android Virtual Device (AVD)

To be able to run our programs from our computers we need to create a virtual device that will work as an emulator to test our changes. To configure an emulator:

```
cd /android-sdk/tools
./android avd
```

Once the AVD is open you can click the **New** button and a window will open asking you for information about the device. Most fields are select boxes so you can create your device however you see fit. You can test your new emulator with this command:

```
./emulator -avd YourEmulatorName
```

## Our first project

Before we can create our project we need to find out wich targets are available in our installation:

```
./android list targets
```

You will get back a list of android devices with numeric ids. We will need those ids when we create our project.

Now we can use the **create project** command. This is how it works:

```
./android create project \
--target <target_ID> \
--name <your_project_name> \
--path path/to/your/project \
--activity <your_activity_name> \
--package <your_package_namespace>
```

This is an example of how I used it:

```
./android create project --target 1 --name TestApp --path /home/myself/android/myapp --activity MyMainActivity --package com.example.testapp
```

The activity name is the name of your application&#8217;s main class. The package name should follow the same rules as Java packages.

Now we can go to /home/myself/android/myapp/src/com/example/testapp/ and open my main class MyMainActivity.java

```java
package com.example.testapp;

import android.app.Activity;
import android.os.Bundle;

public class MyMainActivity extends Activity
{
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }
}
```

## Building the project

The first thing we need to do is to set the JAVA_HOME environment variable. To do this we need to execute these commands:

```
export JAVA_HOME=/usr
echo 'export JAVA_HOME=/usr' >> ~/.bashrc
```

To build the project we need ant 1.8 or later. Since my package manager doesn&#8217;t have that version I had to download it directly from <http://ant.apache.org/> and compile it.

Now you can go to your project folder and build it:

```
cd /home/myself/android/myapp
ant debug
```

The **ant debug** command builds the application in debug mode which is good for testing but shouldn&#8217;t be used for an application that will go live. You will now see a **.apk** file on your **bin** directory.

## Running your application on the emulator

Start the emulator:

```
cd /android-sdk/tools
./emulator -avd YourEmulatorName
```

Install your app in the running emulator:

```
cd /android-sdk/platform-tools
./adb -s emulator-5554 install /home/myself/android/myapp/bin/MyTestApp-debug.apk
```

Where 5554 is your emulator id number. You can find this number on the title bar of your emulator window. When the installation completes you should see your application on the application launcher. If you don&#8217;t see it try restarting the emulator.

The application is only a string in the screen saying &#8220;Hello world&#8221;. I will go over the code in another article.

## Running your application on your android device

Testing the application in an actual android device is even easier. Connect your device to your computer via USB and run this command:

```
cd /android-sdk/platform-tools
./adb install /home/myself/android/myapp/bin/MyTestApp-debug.apk
```

Now you will see your application on your applications list.

## Building an existing project without eclipse

Now that I have all the tools to start developing for android I felt like checking what is available on Github to see some samples of programs. I found that most people are using eclipse (or something similar) for developing, but luckily this doesn&#8217;t mean that we need to have eclipse to compile and run the app. I downloaded the code as with any other project and used this command to create my ant build file:

```
cd /android-sdk/tools
./android update project --name someprojectname --target 1 --path /home/myself/android/somegithubapp/
```

This command generates the build.xml file necessary to build with ant. Once we have this file we can build it and run it following the steps I already explained.
