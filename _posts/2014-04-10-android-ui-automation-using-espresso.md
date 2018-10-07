---
id: 1939
title: Android UI Automation using Espresso
date: 2014-04-10T01:00:13+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1939
permalink: /2014/04/android-ui-automation-using-espresso/
categories:
  - Automation
tags:
  - android
  - ant
  - automation
  - java
  - mobile
  - productivity
  - testing
---
I asked around my Android developers which was the best framework out there for Android automation and the most convincing answer was Espresso, so I decided to give it a try. Espresso is designed to be used in environments where the developers write their own tests (which I think should be everywhere), and promises a concise and beautiful syntax.

## Set up

To use espresso you have to set up a test project. I decided I was going to place all my automation tests under tests/automation so I created that folder, moved into it and ran this command:

```
android create test-project \
-n MyProjectAutomation \
-p . \
-m ../../
```

<!--more-->

You can make sure that things work fine by doing:

```
ant debug
adb -s emulator-5554 install -r bin/MyProjectAutomation-debug.apk
ant test
```

You will also need to [download the jar](https://code.google.com/p/android-test-kit/source/browse/bin/espresso-standalone/ "espresso standalone"). Get the latest version&#8217;s zip file. Then find the correct jar under bin/espresso-standalone/ and place it inside your libs folder. For this to work you need to tell ant where to find libraries by adding this line to ant.properties:

```
jar.libs.dir=libs
```

You need to open the AndroidManifest of your test project(The one in tests/automation), remove the currently defined instrumentation and add this one:


```xml
<instrumentation
    android:name="com.google.android.apps.common.testing.testrunner.GoogleInstrumentationTestRunner"
    android:targetPackage="com.yourapp.something" />
```

If you try to run your tests again using the steps above you will probably get this:

```
test:
     [echo] Running tests ...
     [exec] INSTRUMENTATION_STATUS: id=ActivityManagerService
     [exec] INSTRUMENTATION_STATUS: Error=Unable to find instrumentation info for: ComponentInfo{com.myapp.tests/android.test.InstrumentationTestRunner}
     [exec] INSTRUMENTATION_STATUS_CODE: -1
     [exec] android.util.AndroidException: INSTRUMENTATION_FAILED: com.myapp.tests/android.test.InstrumentationTestRunner
     [exec]     at com.android.commands.am.Am.runInstrument(Am.java:676)
     [exec]     at com.android.commands.am.Am.run(Am.java:119)
     [exec]     at com.android.commands.am.Am.main(Am.java:82)
     [exec]     at com.android.internal.os.RuntimeInit.nativeFinishInit(Native Method)
     [exec]     at com.android.internal.os.RuntimeInit.main(RuntimeInit.java:235)
     [exec]     at dalvik.system.NativeStart.main(Native Method)
```

This happens because under the hood **ant test** runs this command:

```
adb shell am instrument -w -e coverage false com.myapp.tests/android.test.InstrumentationTestRunner
```

Since we are going to use Espresso instrumentation we need to fix this so it uses the correct one:

```
adb shell am instrument -w -e coverage false com.myapp.tests/com.google.android.apps.common.testing.testrunner.GoogleInstrumentationTestRunner
```

You probably don&#8217;t want to have to type this command every time so we can redefine ant test in our build.xml file like this (Look at the comments for a better way to do this):

```xml
<target name="test" description="Run automation tests with espresso">
    <exec executable="${sdk.dir}/platform-tools/adb" failonerror="true">
        <arg line="shell am instrument -w -e coverage false com.myapp.tests/com.google.android.apps.common.testing.testrunner.GoogleInstrumentationTestRunner" />
    </exec>
</target>
```

## Writing tests

All testing frameworks say that it is really easy to write tests if you use them, so I was a little skeptic when I read the same statement for espresso. I was ready for a lot of pain writing my first test but I was surprised by how easy it was.

I created a simple test that will click a button and assert that something is found on the screen:

```java
package com.myapp;

import android.test.ActivityInstrumentationTestCase2;
import static com.google.android.apps.common.testing.ui.espresso.action.ViewActions.click;
import static com.google.android.apps.common.testing.ui.espresso.assertion.ViewAssertions.matches;
import static com.google.android.apps.common.testing.ui.espresso.Espresso.onView;
import static com.google.android.apps.common.testing.ui.espresso.matcher.ViewMatchers.withId;
import static com.google.android.apps.common.testing.ui.espresso.matcher.ViewMatchers.withText;

public class MyAppTest extends ActivityInstrumentationTestCase2<MyApp> {
    public MyAppTest() {
        super("com.myapp", MyApp.class);
    }

    @Override
    public void setUp() throws Exception {
        super.setUp();
        getActivity(); // We need to launch our activity
    }

    public void testSomething() {
        // Click on a button
        onView(withId(R.id.a_button))
                .perform(click());

        // Verify that an element is found
        onView(withId(R.id.an_element))
                .check(matches(withText("Some text")));
    }
}
```

And you can use this command to build, install and run:

```
ant debug install test
```

The test runs pretty smoothly, so from now on, I&#8217;ll be writing tests with my features.
