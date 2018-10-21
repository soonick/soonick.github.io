---
id: 1718
title: Unit testing Android Apps
date: 2013-09-19T05:14:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1718
permalink: /2013/09/unit-testing-android-apps/
tags:
  - android
  - ant
  - automation
  - java
  - mobile
  - programming
  - testing
---
I have written about unit testing in other posts so this time I will only focus on how to create a test suite and test cases for Android applications. Writing unit tests for Java is a little different than doing it for other languages like JavaScript because Java is not only a strongly typed language, but also is a lot less dynamic than JavaScript.

## Creating a test suite

Good developers create tests for all their projects, and for Android there is an standard place where those tests live. Although you don&#8217;t really have to do this, it is recommended that you create a tests/ folder in the root of the Android project under test, at the same level as the src/ folder:

```
MyProject/
    AndroidManifest.xml
    src/
    ...
    tests/
        AndroidManifest.xml
        src/
        ...
```

<!--more-->

Now that we know where we want our tests to live we can go ahead and create a test suite using the android tool:

```
/path/to/android-sdk/tools/android create test-project \
-n MyProjectTests \
-p /path/to/MyProject/tests \
-m ../
```

This commands create a new test project in a **tests/** folder inside of our application under test. This is how it works:

  * **-n** A name for your test project. Usually the same name as the application under test + Tests at the end.
  * **-p** Path to the folder where you want to create the test project. It is recommended to do it in a folder called tests inside your main app
  * **-m** Path to the main application under test, relative to the test project. If you follow the convention of always placing your tests in a tests folder inside your main app, this will always be ../

After running this command we can make sure everything works fine by building our tests:

```
cd /path/to/MyProject/tests
ant debug
```

After building the tests you will need to start an emulator and install your tests package on it before you can run them:

```
/path/to/android-sdk/tools/emulator -avd EmulatorName &
cd /path/to/MyProject/tests
/path/to/android-sdk/platform-tools/adb -s emulator-5554 \
install /path/to/MyProject/tests/bin/MyProjectTests-debug.apk
ant test
```

And you should get an output similar to:

```
test:
     [echo] Running tests ...
     [exec]
     [exec] Test results for InstrumentationTestRunner=
     [exec] Time: 0.001
     [exec]
     [exec] OK (0 tests)
     [exec]
     [exec]

BUILD SUCCESSFUL
```

So far we only created a test suite and ran it, we haven&#8217;t actually created any tests. If you have done unit testing in other programming languages you might have also noticed that doing it for Android requires a few more steps that can make it feel a little cumbersome. There are some options to make this process a little easier but I wont cover them in this post.

## Writing tests

Lets start by modifying our generated test file and adding a simple assertion to it. If you look at /path/to/MyProject/tests/src/com/example/myproject/MyProjectTest.java you will find something like this:

```java
package com.example.myproject;

import android.test.ActivityInstrumentationTestCase2;

public class MyProjectTest extends ActivityInstrumentationTestCase2<MyProject> {

    public MyProjectTest() {
        super("com.example.myproject", MyProject.class);
    }

}
```

You can see that our **MyProjectTest** class extends from **ActivityInstrumentationTestCase2**, this means that this test file is intended to test an activity. Since I don&#8217;t want to go over all the types of tests that you can write for Android I will replace it with a generic test case and write a simple assertion:

```java
package com.example.myproject;

import android.test.AndroidTestCase;
import junit.framework.Assert;

public class MyProjectTest extends AndroidTestCase {
    public void testSomething() {
        Assert.assertTrue(false);
    }
}
```

Notice that we are extending AndroidTestCase to write a more generic test. We also import JUnit&#8217;s assertion library so we can use it in our tests. Another important thing to mention is that the name of my test function is **testSomething**. All tests must start with **test** for them to be run when the test suite is ran.

Since I am ussing Assert.assertTrue against false when we run this test using the steps I explained above we will get a different output:

```
test:
     [echo] Running tests ...
     [exec]
     [exec] com.example.myproject.MyProjectTest:.
     [exec] Failure in testSomething:
     [exec] junit.framework.AssertionFailedError
     [exec]     at com.example.myproject.MyProjectTest.testSomething(MyProjectTest.java:8)
     [exec]     at java.lang.reflect.Method.invokeNative(Native Method)
     [exec]     at android.test.AndroidTestRunner.runTest(AndroidTestRunner.java:190)
     [exec]     at android.test.AndroidTestRunner.runTest(AndroidTestRunner.java:175)
     [exec]     at android.test.InstrumentationTestRunner.onStart(InstrumentationTestRunner.java:555)
     [exec]     at android.app.Instrumentation$InstrumentationThread.run(Instrumentation.java:1661)
     [exec]
     [exec] Test results for InstrumentationTestRunner=..F
     [exec] Time: 0.041
     [exec]
     [exec] FAILURES!!!
     [exec] Tests run: 2,  Failures: 1,  Errors: 0
     [exec]
     [exec]

BUILD SUCCESSFUL
```

From here writing tests for your classes is just a matter of importing them in your test files, executing the methods you want to test and asserting that they do what you expected.
