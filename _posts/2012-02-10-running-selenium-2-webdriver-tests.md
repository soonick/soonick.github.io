---
id: 474
title: Running Selenium 2.0 / Webdriver tests
date: 2012-02-10T02:48:52+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=474
permalink: /2012/02/running-selenium-2-webdriver-tests/
tags:
  - automation
  - java
  - testing
---
Selenium is probably the most popular web functional testing automation tool out there. Functional testing means testing your application as if you were a user (clicking links, entering information in fields, etc&#8230;). And thanks to selenium this can be automated.

Recently selenium released a new version (2) that is basically a merge with another project called WebDriver. This merge provides developers and testers with a very neat Object Oriented interface to interact with browsers easily from Java.

In this post I am going to explain my first successful experience with Selenium 2 / Webdriver (I had some unsuccessful experiences in the past). I couldn&#8217;t have made this post without the great help of [http://www.qaautomation.net/?p=263](http://www.qaautomation.net/?p=263 "A simple selenium 2 example"), so thanks a lot to qaautomation.net for their awesome post.

<!--more-->

## Getting the necessary stuff

There are some things you need to download in order to compile and run your functional tests with selenium 2

JDK. You can get this from oracle or if you have apt-get you can simply do:

```
apt-get install default-jdk
```

Ant. You can get this from apache or with apt-get:

```
apt-get install ant
```

Selenium 2 (Selenium Server). You can get the jar file from selenium downloads page. Current version is 2.19.0 but download the latest available by the time you read this.

## Creating the Java project

To be able to build and run our test we need to create a Java project. For doing this we need first a folder for our project, I will use this one: /home/adrian/myproject/. And now we need to create this folder structure inside that folder:

```
- build
- java
    - classes
    - src
- lib
```

Later we will need a file to automate our build. The name of that file needs to be build.xml and it should live in the root of your project (/home/adrian/myproject/build.xml):

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
        <java classname="net.qaautomation.examples.${example}"
               failonerror="true"
               classpathref="testautomation.classpath"/>
    </target>
</project>
```

Now move the .jar file you downloaded from selenium site to your projects lib folder (/home/adrian/myproject/lib/)

## Creating the test

I am going to use the same example from qaautomation.net&#8217;s post. We need to create a file named GoogleSearch.java in our src folder (/home/adrian/myproject/java/src/) with this content:

```java
package net.qaautomation.examples;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.Wait;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * Search Google example.
 *
 * @author Rahul
 */
public class GoogleSearch {
    static WebDriver driver;
    static Wait<WebDriver> wait;

    public static void main(String[] args) {
        driver = new FirefoxDriver();
        wait = new WebDriverWait(driver, 30);
        driver.get("http://www.google.com/");

        boolean result;
        try {
            result = firstPageContainsQAANet();
        } catch(Exception e) {
            e.printStackTrace();
            result = false;
        } finally {
            driver.close();
        }

        System.out.println("Test " + (result? "passed." : "failed."));
        if (!result) {
            System.exit(1);
        }
    }

    private static boolean firstPageContainsQAANet() {
        //type search query
        driver.findElement(By.name("q")).sendKeys("qa automation\n");

        // click search
        driver.findElement(By.name("btnG")).click();

        // Wait for search to complete
        wait.until(new ExpectedCondition<Boolean>() {
            public Boolean apply(WebDriver webDriver) {
                System.out.println("Searching ...");
                return webDriver.findElement(By.id("resultStats")) != null;
            }
        });

        // Look for QAAutomation.net in the results
        return driver.findElement(By.tagName("body")).getText().contains("qaautomation.net");
    }
}
```

## Running the test

Thanks to ant, running and building the project and running the test is very simple. First we need to build:

```
ant build
```

Now we can use a rule (run-example) from our build.xml file to run the tests:

```
ant run-example -Dexample=GoogleSearch
```

The test should open firefox, do a google search and then close firefox again. Now you can create other selenium tests and add them to your src folder.
