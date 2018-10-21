---
id: 1952
title: Creating a Robolectric project from scratch with ant
date: 2014-02-20T04:06:30+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1952
permalink: /2014/02/creating-a-robolectric-project-from-scratch-with-ant/
tags:
  - android
  - ant
  - automation
  - java
  - mobile
  - productivity
  - testing
---
I&#8217;m still trying to figure out this Android unit testing madness and this time I was finally able to create a Robolectric project without any IDE. Now that I know the steps it doesn&#8217;t seem so hard, but it was a long process trying to gather all the information necessary to make this work.

The first thing we need is to create a folder inside our android project. I&#8217;ll call mine **tests**. This is going to be the folder where we will include everything related to our Robolectric tests. The next step is to create a build.xml file so we can build our project with ant:

<!--more-->

```xml
<!-- You can use any project name you want -->
<project name="MyTests" basedir="." default="main">
    <property name="src.dir" value="src" />
    <property name="bin.dir" value="bin" />
    <property name="libs.dir" value="libs" />
    <property name="classes.dir" value="${bin.dir}/classes" />
    <property name="jar.dir" value="${bin.dir}/jar" />
    <property environment="env" />

    <!-- I stole this from the build file that Android generates. This will help
   ant find the Android SDK if your ANDROID_HOME variable is set -->
    <condition property="sdk.dir" value="${env.ANDROID_HOME}">
        <isset property="env.ANDROID_HOME" />
    </condition>

    <!-- Your classpath needs to include the Android SDK, your libs folder and
   the classes folder for the project under test -->
    <path id="classpath">
        <fileset dir="${libs.dir}" includes="**/*.jar" />
        <fileset dir="${sdk.dir}" includes="**/*.jar" />
        <pathelement path="../bin/classes" />
    </path>

    <!-- This is the tests jar -->
    <path id="application" location="${jar.dir}/${ant.project.name}.jar" />

    <target name="clean">
        <delete dir="${bin.dir}" />
    </target>

    <!-- We will compile our tests the same way we would compile any other java project -->
    <target name="compile">
        <mkdir dir="${classes.dir}" />
        <!-- includeantruntime is included to silence a warning that ant displays if this
       is not set -->
        <javac includeantruntime="false" srcdir="${src.dir}"
               destdir="${classes.dir}" classpathref="classpath" />
        <!-- This is a little hack necessary so we can tell Robolectric where the
       AndroidManifest.xml file for our project lives. Robolectric will read this
       information from a file named org.robolectric.Config.properties that we
       need to have in our classes folder before we package our tests -->
        <copy file="conf/org.robolectric.Config.properties"
               tofile="${classes.dir}/org.robolectric.Config.properties" />
    </target>

    <!-- Create a jar file from all our .class files -->
    <target name="jar" depends="compile">
        <mkdir dir="${jar.dir}" />
        <jar destfile="${jar.dir}/${ant.project.name}.jar" basedir="${classes.dir}" />
    </target>

    <!-- This will run the tests -->
    <target name="test" depends="jar">
        <junit>
            <!-- This will show the test errors in the console -->
            <formatter type="plain" usefile="false" />
            <!-- We include the classpath necessary to compile our tests plus the
           generated jar file -->
            <classpath>
                <path refid="classpath" />
                <path refid="application" />
            </classpath>
            <!-- Select which files will be ran (All the files ending with Test.java) -->
            <batchtest fork="yes">
                <fileset dir="${src.dir}">
                    <include name="**/*Test.java" />
                </fileset>
            </batchtest>
        </junit>
    </target>
</project>
```

You will also need to create this file **conf/org.robolectric.Config.properties** so Robolectric knows where your manifest file is:

```
manifest=../AndroidManifest.xml
```

Then you will need to download the libs you will need for your tests. The ones I currently have in my folder are:

  * hamcrest-core-1.3.jar
  * junit-4.11.jar
  * mockito-all-1.9.5.jar
  * robolectric-2.2-jar-with-dependencies.jar

Now you can write your tests and run them using:

```
ant test
```
