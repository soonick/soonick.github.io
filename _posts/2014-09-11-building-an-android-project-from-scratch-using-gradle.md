---
id: 2173
title: Building an Android project from scratch using gradle
date: 2014-09-11T01:47:09+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2173
permalink: /2014/09/building-an-android-project-from-scratch-using-gradle/
tags:
  - android
  - automation
  - gradle
  - java
  - mobile
  - productivity
  - testing
---
Since Android moved to Gradle I tought it would be a good idea to renew my post on building an Android app from scratch to use Gradle instead of ant.

The first thing we need to do is to create the folder structure for our project:

```
Project/
  |---build.gradle
  |---src/
       |---main/
            |---AndroidManifest.xml
            |---res
            |---java
                  |---src (Code goes here)
```

<!--more-->

The simplest build.gradle will look like this:

```groovy
buildscript {
  repositories {
    mavenCentral()
  }

  dependencies {
    classpath 'com.android.tools.build:gradle:0.11.1'
  }
}

apply plugin: 'android'

android {
  compileSdkVersion 19
  buildToolsVersion "19.1.0"
}
```

If you create a manifest file and some code you should be able to build your project using this command:

```
gradle build
```

That should be enough to get you started and be able to build an app.

Another thing that is pretty easy to add when using gradle is PMD for code static analysis:

```
// ---------------- Pmd ------------------

apply plugin: 'pmd'

pmd {
  ruleSetFiles = files('pmd_rules.xml')
}
```

The next step is to add tests. I write my tests using Robolectric and place them under Project/tests/unit. The android plugin doesn&#8217;t support Robolectric tests by default so I had to add some stuff to my build.gradle file:

```groovy
// ----------- Unit tests ---------------
repositories {
  mavenCentral()
}

// extend the runtime
configurations {
  unitTestCompile.extendsFrom runtime
  unitTestRuntime.extendsFrom unitTestCompile
}

// add to dependencies
dependencies {
  unitTestCompile files("$project.buildDir/intermediates/classes/debug")
  unitTestCompile files("$project.buildDir/intermediates/res/debug")
  unitTestCompile 'org.robolectric:robolectric:2.3'
  unitTestCompile 'junit:junit:4.11'
  unitTestCompile 'org.mockito:mockito-core:1.9.5'
  unitTestCompile 'com.google.android:android:4.0.1.2'
}

// add a new unitTest sourceSet
sourceSets {
  unitTest {
    java.srcDir file('tests/unit/src')
  }
}

// add the unitTest task
task unitTest(type:Test, dependsOn: assemble) {
  description = "run unit tests"
  testClassesDir = project.sourceSets.unitTest.output.classesDir
  classpath = project.sourceSets.unitTest.runtimeClasspath
}

// bind to check
check.dependsOn unitTest
```

Now I can run my tests using this command:

```
gradle unitTest
```

The last step of my build is UI Automation. I like Espresso so I had to add it to my dependencies:

```groovy
dependencies {
    androidTestCompile 'com.jakewharton.espresso:espresso:1.1-r3'
}
```

Then I just placed my tests under src/androidTest/java/src/ and ran them using this command:

```
gradle connectedAndroidTest
```

At the end my build.gradle file looks something like this:

```groovy
buildscript {
  repositories {
    mavenCentral()
  }

  dependencies {
    classpath 'com.android.tools.build:gradle:0.12.1'
  }
}

apply plugin: 'com.android.application'

android {
  compileSdkVersion 19
  buildToolsVersion "19.1.0"

  defaultConfig {
    testInstrumentationRunner "com.google.android.apps.common.testing.testrunner.GoogleInstrumentationTestRunner"
  }

  lintOptions {
    abortOnError false
  }

  packagingOptions {
    exclude 'LICENSE.txt'
  }
}

dependencies {
  compile 'com.google.android.gms:play-services:4.4.52'
  androidTestCompile 'com.jakewharton.espresso:espresso:1.1-r3'
}

// ----------- Unit tests ---------------
repositories {
  mavenCentral()
}

// extend the runtime
configurations {
  unitTestCompile.extendsFrom runtime
  unitTestRuntime.extendsFrom unitTestCompile
}

// add to dependencies
dependencies {
  unitTestCompile files("$project.buildDir/intermediates/classes/debug")
  unitTestCompile files("$project.buildDir/intermediates/res/debug")
  unitTestCompile 'org.robolectric:robolectric:2.3'
  unitTestCompile 'junit:junit:4.11'
  unitTestCompile 'org.mockito:mockito-core:1.9.5'
  unitTestCompile 'com.google.android:android:4.0.1.2'
}

// add a new unitTest sourceSet
sourceSets {
  unitTest {
    java.srcDir file('tests/unit/src')
  }
}

// add the unitTest task
task unitTest(type:Test, dependsOn: assemble) {
  description = "run unit tests"
  testClassesDir = project.sourceSets.unitTest.output.classesDir
  classpath = project.sourceSets.unitTest.runtimeClasspath
}

// bind to check
check.dependsOn unitTest

// ---------------- Pmd ------------------

apply plugin: 'pmd'

pmd {
  ruleSetFiles = files('pmd_rules.xml')
}
```
