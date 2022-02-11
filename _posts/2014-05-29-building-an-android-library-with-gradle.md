---
id: 2144
title: Building an Android library with gradle
date: 2014-05-29T04:49:16+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2144
permalink: /2014/05/building-an-android-library-with-gradle/
tags:
  - android
  - automation
  - mobile
  - productivity
---
Android has moved away from ant and adopted gradle as its build system. I&#8217;m not very familiar with gradle but there is a feature of the new build system that makes it really appealing to migrate to it. The new gradle build system compiles libraries into an .aar (Android ARchive) which includes it&#8217;s resources and assets in a way that can be consumed by the apps that use your library.

This means you no longer need to copy the source code of the library into your project and compile both projects together, now you can just drop the .aar into your libs folder and it will work.

To use gradle with Android you need at least gradle version 1.10. I got the latest version at the time (1.12) and things worked fine for me.

<!--more-->

## From scratch

The Android gradle puglin uses convention over configuration so if you are starting a new project you might as well use the convention. This is the default folder structure:

```
your-lib/
 |---build.gradle
 |---src/
      |---main/
           |---AndroidManifest.xml
           |---res/
           |---java/
                 |---src/ (Your library code lives here)
```

The build.gradle file for a simple project would look like this:

```groovy
buildscript {
  repositories {
    mavenCentral()
  }

  dependencies {
    classpath 'com.android.tools.build:gradle:0.10.0'
  }
}

apply plugin: 'android-library'

android {
  compileSdkVersion 19
  buildToolsVersion '19.0.1'
}
```

Once you have your code there you can run:

```
gradle build
```

And everything should run fine. When the build is done you will find your .aar file under builds/libs/

## Migrating from ant

If you already have your library running with ant you can migrate it to gradle without the need to change your folder structure right away.

I currently have a library using ant with this folder structure:

```
my-lib/
 |---AndroidManifest.xml
 |---build.xml
 |---libs/
 |---res/
 |---src/ (Library code lives here)
```

to migrate to gradle I only had to add this build.gradle file:

```groovy
buildscript {
  repositories {
    mavenCentral()
  }

  dependencies {
    classpath 'com.android.tools.build:gradle:0.10.0'
  }
}

apply plugin: 'android-library'

android {
  compileSdkVersion 19
  buildToolsVersion '19.0.2'

  sourceSets {
    main {
      manifest.srcFile 'AndroidManifest.xml'
      java.srcDirs = ['src']
      res.srcDirs = ['res']
    }
  }
}
```

I also had some unit test for my project so I had to add this to my build.gradle file:

```groovy
repositories {
  mavenCentral()
}

// extend the runtime
configurations {
  unitTestCompile.extendsFrom runtime
  unitTestRuntime.extendsFrom unitTestCompile
}

// add to dependancies
dependencies {
  unitTestCompile files("$project.buildDir/classes/debug")
  unitTestCompile fileTree(dir: 'tests/unit/libs/', include: '*.jar')
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

To run your test you only need to do:

```
gradle unitTest
```

Another thing that I like to have as part of my build is linting. The android gradle plugin automatically makes the lint tool available for you but I wanted to customize it a little. To do this I had to modify the android section of my build.gradle file:

```groovy
android {
  // Some stuff here

  lintOptions {
    abortOnError true
    checkAllWarnings true
    warningsAsErrors true
    textReport true
    textOutput 'stdout'
    xmlReport false
    htmlReport true
  }
}
```

Pmd was pretty easy to add:

```groovy
apply plugin: 'pmd'

pmd {
  ruleSetFiles = files('pmd_rules.xml')
}
```

There are two caveats here:

  * I had to change my references in my rule file from rulesets/java/android.xml to rulesets/android.xml
  * At the time of this writting the rules for empty, comments and unnecessary are not available

Everything else should work fine.
