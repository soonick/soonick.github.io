---
title: Introduction to Apache Ant
author: adrian.ancona
layout: post
date: 2020-03-10
permalink: /2020/03/introduction-to-apache-ant/
tags:
  - ant
  - automation
  - java
  - productivity
---

I just started working with Java and I have realized I don't know much about how the build system works. In this article I'm going to explore Java's build system. `Ant` is analogous to `Make`, `Gradle` or `Gulp`. It's main goal is to automate the process of running tasks. More specifically, it is often used to compile code, run tests, etc.

## Installation

`Ant` is a Java application, so a Java Runtime Environment is necessary. The installation will vary depending on your environment, so you might want to check [the official documentation](https://ant.apache.org/manual/install.html#installing). If you use ubuntu, you can use `apt-get`:

```sh
sudo apt-get install ant
```

To verify the installation was successful:

```
ant -version
```

<!--more-->

## The build file

If you have used `make`, you know that it uses a `Makefile`. In the case of `ant`, we need a `build.xml` file. As the extension shows, this is an XML file.

A `build.xml` file contains a single project and a set of targets (tasks) for that project. Let's look at a very simple example:

```xml
<project name="ProjectName" default="task-name">
  <description>
    Simple example of build.xml file
  </description>

  <target name="task-name">
    <mkdir dir="folder"/>
  </target>
</project>
```

Here we are defining a `project` called `ProjectName`. We also define a single `target` called `task-name` and set this task as the `default` task. The target does just one simple thing. It creates directory named `folder`. 

To learn a little ant terminology; An XML tag is called `task`. We use the `target` task to create a target.

To test the file, create a directory and add the `build.xml` file to that directory. `cd` into the directory from a terminal and run:

```
ant
```

Since `task-name` is the default task, that's the task that will be executed when the command is used like that. A directory called `folder` will be created. 

## Documenting the build file

In the example above, we added a `description` tag to the project as a way to document what our build file is doing. Targets can also be documented so people using or modying the file understand what each target is supposed to do. Let's add a description to `task-name`:

```xml
<project name="ProjectName" default="task-name">
  <description>
    Simple example of build.xml file
  </description>

  <target name="task-name" description="This task just makes a folder">
    <mkdir dir="folder"/>
  </target>
</project>
```

Users of the project can get information about the project and targets without needing to open `build.xml`:

```sh
ant -projecthelp
```

The output looks something like this:

```sh
$ ant -projecthelp
Buildfile: /ant-example/build.xml

    Simple example of build.xml file

Main targets:

 task-name  This task just makes a folder
Default target: task-name
```

## Properties

Ant allows the creation of properties that can be defined in one place and used in multiple places. Properties are useful to prevent repetition of commonly used values. A property can be defined:

```xml
<property name="file-name" value="hello.txt"/>
```

Once defined a property can be used in the build file:

```xml
<touch file="${file-name}" />
```

Most properties in a build file are usually paths. For this reason, there is a `location` attribute specifically designed for dealing with paths. It converts the value to an absolute path starting at the projects `basedir`:

```xml
<property name="folder" location="some/folder" />
```

### Built-in properties

Ant provides some [built-in properties](https://ant.apache.org/manual/properties.html) that can be used the same way as user defined properties. Some of the most common ones are:

- `basedir` - Absolute path of the folder where the project lives
- `ant.file` - Absolute path to the `build.xml` file
- `ant.project.name` - Name of the project
- `java.version` - Version of the JRE (Java Runtime Environment)

### Property file

Sometimes developers need to override some properties when doing development in their machines. They could open `build.xml` and modify it, but they might accidentally commit their changes and push them to source control. A better way to achieve this is to tell ant to read properties from a local file. This file can be ignored by source control, preventing accidentally committing changes.

The properties file must follow the same format as the [Java properties format](https://en.wikipedia.org/wiki/.properties), which looks something like this:

```
key=abcde12345
myname=taquito
```

The file needs to be loaded from `build.xml`:

```xml
<property file="foo.properties"/>
```

If the file doesn't exist, nothing will happen.

### Environment variables

Another commonly needed task is reading values from environment variables. To do this we need to first put all the environment variables in a single property:

```xml
<property environment="env"/>
```

Then we can access environment variables from inside this property:

```xml
<echo message="${env.MY_ENV_VARIABLE}" />
```

## Target dependencies

Complex systems usually perform various steps as part of their build. Some of the steps might have dependencies in other steps. And example could be compiling your code, before packing it in a jar.

We can express dependencies of a target with the `depends` keyword:

```xml
<target name="assets">
  <!-- copy assets to correct location -->
</target>

<target name="build">
  <!-- build steps here -->
</target>

<target name="package" depends="build,assets">
  <!-- build steps here -->
</target>
```

The `package` target depends on `build` and `assets`, so every time `package` is ran, it will first run its dependencies.

## Simple example

With the knowledge we have, let's look at a simple example. The project will have this structure:

```
/project
|--build.xml
|--Hello.java
|--/images
|  |--image.jpg
|
|--/config
   |--settings.yml
```

The `build` task will follow these steps:

- Create `build` folder
- Copy `images` folder to `build` folder
- Copy `config` folder to `build` folder
- Compile `hello.java` and put the result in the `build` folder

We will also create a `run` target that will depend on `build`. This target will start the program:
- Run `build` target
- Execute program

Lastly, we'll have a `package` step that will do a clean build (Delete build folder before doing a build) and will create a jar file with the result:
- Delete build folder
- Run `build` target
- Create jar

I'm not going to show what the program does, because that is not really relevant to understanding how `ant` works. Assume it's a program that uses the images and settings.

This is the build file:

```xml
<project name="Hello" default="build">
  <description>
    Build file for awesome Hello application
  </description>

  <property name="build-dir" location="build" />

  <target name="clean" description="Delete build folder">
    <delete dir="${build-dir}"/>
  </target>

  <target name="copy-assets" description="Copy static assets to build folder">
    <copy todir="${build-dir}/images">
      <fileset dir="images" />
    </copy>
    <copy todir="${build-dir}/config">
      <fileset dir="config" />
    </copy>
  </target>

  <property name="classes-dir" location="${build-dir}/classes" />
  <target name="build" description="Build application" depends="copy-assets">
    <mkdir dir="${classes-dir}" />
    <javac srcdir="${basedir}" destdir="${classes-dir}" includeantruntime="false" />
  </target>

  <target name="run" description="Run application" depends="build">
    <java classname="Hello">
      <classpath path="${classes-dir}" />
    </java>
  </target>

  <target name="package" description="Create jar for application" depends="clean,build">
    <jar destfile="${build-dir}/hello.jar">
      <fileset dir="${build-dir}/classes" />
      <zipfileset dir="${build-dir}/config" prefix="config" />
      <zipfileset dir="${build-dir}/images" prefix="images" />
      <manifest>
        <attribute name="Main-Class" value="Hello"/>
      </manifest>
    </jar>
  </target>
</project>
```

I'll explain the targets one by one. The `clean` target is the simplest:

```xml
<target name="clean" description="Delete build folder">
  <delete dir="${build-dir}"/>
</target>
```

The only thing this target does is delete the build directory so other builds can start clean.

The `copy-assets` target takes care of copying images and configurations to the build folder, so they can be accessed by the application once it's compiled:

```xml
<target name="copy-assets" description="Copy static assets to build folder">
  <copy todir="${build-dir}/images">
    <fileset dir="images" />
  </copy>
  <copy todir="${build-dir}/config">
    <fileset dir="config" />
  </copy>
</target>
```

Next is the `build` target:

```xml
<property name="classes-dir" location="${build-dir}/classes" />
<target name="build" description="Build application" depends="copy-assets">
  <mkdir dir="${classes-dir}" />
  <javac srcdir="${basedir}" destdir="${classes-dir}" includeantruntime="false" />
</target>
```

This target depends on `copy-assets`, which means it will run `copy-assets` before it runs. Then it creates a directory where classes files will be put. Lastly, it uses `javac` to compile all files into the `classes` directory. The `includeantruntime` attribute is recommended but not necessary. I just added it to silence a warning ant was throwing.

After building the application, we might want to run it:

```xml
<target name="run" description="Run application" depends="build">
  <java classname="Hello">
    <classpath path="${classes-dir}" />
  </java>
</target>
```

This target depends on `build`, because we can't run an application that we haven't built. The `java` task is used to specify the class we want to run. For this to work it's necessary to also provide a classpath.

Finally, the `package` target creates a single file that can be deployed as the whole application:

```xml
<target name="package" description="Create jar for application" depends="clean,build">
  <jar destfile="${build-dir}/hello.jar">
    <fileset dir="${build-dir}/classes" />
    <zipfileset dir="${build-dir}/config" prefix="config" />
    <zipfileset dir="${build-dir}/images" prefix="images" />
    <manifest>
      <attribute name="Main-Class" value="Hello"/>
    </manifest>
  </jar>
</target>
```

Before creating an artifact, we want to make sure a clean build is done. For that reason, we depend on `clean` and `build`. Those targets will be executed in the order they apper in the attribute. The `jar` task helps us create the artifact.

We start by specifying where the jar will be put. All files in the `classes` folder are copied to the root of the `jar` file. The `config` and `images` folders are copied to folders with the same name inside the `jar`. Finally, we create a manifest where we defined the main class.

With the build file ready, we can easily run the application with ant:

```sh
ant run
```

or create a jar:

```sh
ant package
```

The jar can be run:

```sh
java -jar build/hello.jar
```

## Conclusion

This article covered the most fundamental things about `ant` and build files. There are a lot of ant plugins that are commonly used and might make build files seems more complicated, but the format will remain the same. Remember the basics when creating or reading a `build.xml` file and you should be able to deal with more complicated stuff.
