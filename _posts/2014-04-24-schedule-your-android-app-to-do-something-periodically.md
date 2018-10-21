---
id: 1972
title: Schedule your Android app to do something periodically
date: 2014-04-24T05:44:23+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1972
permalink: /2014/04/schedule-your-android-app-to-do-something-periodically/
tags:
  - android
  - bootstrapping
  - java
  - mobile
  - programming
---
I am writing a little Android app that will send alarms to the user based on certain rules. For this there are certain things that I need:

  * I want to have something that will run periodically and check my DB to see if there are any alarms I should send to the user.
  * I want this to run even if my app is closed or the phone is asleep
  * I want this to start automatically every time the phone is turned on

I did a little research and these are the pieces we need:

  * [Services](http://developer.android.com/guide/components/services.html "Android services") &#8211; To have our app do something in the background
  * [AlarmManager](http://developer.android.com/reference/android/app/AlarmManager.html "Android AlarmManager") &#8211; To schedule the service to be executed in the future
  * [ACTION\_BOOT\_COMPLETED](http://developer.android.com/reference/android/content/Intent.html "Boot completed broadcast intent") &#8211; This is a broadcast intent that Android sends when it boots

Now, lets start putting things together.

<!--more-->

## Service

To create a Service we just need to create a class that extends Service. This is an abstract class so you need to implement onBind:

```java
public class MyService extends Service {
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
```

We want our service to do something as soon as it is created so we overwrite the onStartCommand method:

```java
public class MyService extends Service {
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Query the database and show alarm if it applies

        // Here you can return one of some different constants.
        // This one in particular means that if for some reason
        // this service is killed, we don't want to start it
        // again automatically
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
```

Now that we have our service, we need to have it start when we want it to start:

  * When the app is launched
  * When the phone is turned on
  * Every time we schedule it to start

For the service to launch when the app is started you can simply add this line to the onCreate method of your main activity:

```java
startService(new Intent(this, MyService.class));
```

For starting the service when the phone is turned on you will have to register a BroadcastReceiver to listen for BOOT_COMPLETE. First lets create the BroadcastReceiver:

```java
public class AutoStart extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        context.startService(new Intent(context, MyService.class));
    }
}
```

The only thing this BroadcastReceiver does is start the service when it receives an Intent. Now we need to tell our manifest that we want this class to listen to boot complete:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
   package="some.app"
   android:versionCode="1"
   android:versionName="1.0" >

    <!-- Some more stuff in here -->

    <!-- We need permission to listen to boot_completed -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application>
        <!-- Some more stuff in here -->

        <!-- Here we specify that we want to send BOOT_COMPLETED to our
       AutoStart class -->
        <receiver android:name=".AutoStart">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

Now, for starting our service based on a schedule requires us to use AlarmManager, so lets take a look at it.

## AlarmManager

AlarmManager allows you to schedule an Intent to be triggered in the future. Most specifically we will use the AlamManager.set(int type, long triggerAtMillis, PendingIntent operation) method to have am Intent be fired in the future:

```java
AlarmManager alarm = (AlarmManager)getSystemService(ALARM_SERVICE);
alarm.set(
    // This alarm will wake up the device when System.currentTimeMillis()
    // equals the second argument value
    alarm.RTC_WAKEUP,
    System.currentTimeMillis() + (1000 * 60 * 60), // One hour from now
    // PendingIntent.getService creates an Intent that will start a service
    // when it is called. The first argument is the Context that will be used
    // when delivering this intent. Using this has worked for me. The second
    // argument is a request code. You can use this code to cancel the
    // pending intent if you need to. Third is the intent you want to
    // trigger. In this case I want to create an intent that will start my
    // service. Lastly you can optionally pass flags.
    PendingIntent.getService(this, 0, new Intent(this, MyService.class), 0)
);
```

Now, almost everything is in place, we just need to put it together:

```java
public class MyService extends Service {
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Query the database and show alarm if it applies

        // I don't want this service to stay in memory, so I stop it
        // immediately after doing what I wanted it to do.
        stopSelf();

        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        // I want to restart this service again in one hour
        AlarmManager alarm = (AlarmManager)getSystemService(ALARM_SERVICE);
        alarm.set(
            alarm.RTC_WAKEUP,
            System.currentTimeMillis() + (1000 * 60 * 60),
            PendingIntent.getService(this, 0, new Intent(this, MyService.class), 0)
        );
    }
}
```
