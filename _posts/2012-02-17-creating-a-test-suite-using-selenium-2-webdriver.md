---
id: 543
title: Creating a test suite using Selenium 2 / Webdriver
date: 2012-02-17T01:37:53+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=543
permalink: /2012/02/creating-a-test-suite-using-selenium-2-webdriver/
tags:
  - automation
  - java
  - testing
---
After writing my post: [Running Selenium 2.0 / Webdriver tests](http://ncona.com/2012/02/running-selenium-2-webdriver-tests/ "Running Selenium 2.0 / Webdriver tests"), I was thinking how could I make a test suite so I could run all my functional tests with just one command. In this post I am going to explain how I used Java classes to do this.

This post is highly based on [Running Selenium 2.0 / Webdriver tests](http://ncona.com/2012/02/running-selenium-2-webdriver-tests/ "Running Selenium 2.0 / Webdriver tests"), so if you feel you don&#8217;t understand what I am saying, please read that post first.

<!--more-->

## Test Suite

The first thing I figured is that we need a main class that will call all the other classes tests, so I created a main test suite file called NconaTestSuite.java with this content:

```java
package com.ncona;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Wait;
import org.openqa.selenium.support.ui.WebDriverWait;

public class NconaTestSuite
{
    public static void main(String[] args)
    {
        // Objects that are going to be passed to all test classes
        WebDriver driver = new FirefoxDriver();
        Wait<WebDriver>wait = new WebDriverWait(driver, 30);

        boolean result;
        try
        {
            // Here we add all the test classes we want to run
            MiscTestClass mtc1 = new MiscTestClass();
            MiscTestClassTwo mtc2 = new MiscTestClassTwo();
            MiscTestClassThree mtc3 = new MiscTestClassThree();

            // We call the run method (that method runs all
            // the tests of the class) for each of the classes
            // above. If any test fails result will be false.
            result = (
                mtc1.run(driver, wait)
                && mtc2.run(driver, wait)
                && mtc3.run(driver, wait)
            )
        }
        catch (Exception e)
        {
            e.printStackTrace();
            result = false;
        }
        finally
        {
            driver.close();
        }

        System.out.println("Test " + (result ? "passed." : "failed."));
        if (!result)
        {
            System.exit(1);
        }
    }
}
```

## Test Class

Our test classes need to have a run method that will run all the tests it contains. Here is an example of how it could look:

```java
package com.ncona;

import java.util.List;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.Wait;
import org.openqa.selenium.support.ui.WebDriverWait;

public class MiscTestClass
{
    static WebDriver driver;
    static Wait<WebDriver> wait;

    public static boolean run(WebDriver driverArg, Wait<WebDriver> waitArg)
    {
        driver = driverArg;
        wait = waitArg;

        setUp();

        // Run all the methods and return false if any fails
        return (
            miscMethod()
            && miscMethod2()
        );
    }

    private static boolean miscMethod()
    {
        // Put your tests code here

        return result
    }

    private static boolean miscMethod2()
    {
        // Put your tests code here

        return result
    }
}
```

## Build file

The build.xml file used for this test suite almost the same as the one in my previous post. We just need to change the target to use the name of our new test suite file:

```xml
<project basedir="." name="Test Automation">
    <property name="src.dir" value="${basedir}/java/src"/>
    <property name="classes.dir" value="${basedir}/java/classes/main"/>
    <property name="lib.dir" value="${basedir}/lib"/>
    <property name="build.dir" value="${basedir}/build"/>
    <property name="testautomation.jar" value="${build.dir}/testautomation.jar"/>

    <path id="testautomation.classpath">
        <file file="${testautomation.jar}"/>
        <fileset dir="${lib.dir}">
            <include name="*.jar" />
        </fileset>
    </path>

    <target name="build" description="sets up the environment for test execution">
        <mkdir dir="${classes.dir}"/>
        <mkdir dir="${build.dir}"/>
        <javac debug="true"
              srcdir="${src.dir}"
              destdir="${classes.dir}"
              includeAntRuntime="false"
              classpathref="testautomation.classpath"/>
        <jar basedir="${classes.dir}" jarfile="${testautomation.jar}"/>
    </target>

    <target name="run-example" description="run command-line example">
        <!---- This is the line I modified. Classname is now com.ncona.${example} ---->
        <java classname="com.ncona.${example}"
               failonerror="true"
               classpathref="testautomation.classpath"/>
    </target>
</project>
```

## Run the suite

First we need to build the project:

```
ant build
```

Finally to run it we would use this command:

```
ant run-example -Dexample=NconaTestSuite
```
