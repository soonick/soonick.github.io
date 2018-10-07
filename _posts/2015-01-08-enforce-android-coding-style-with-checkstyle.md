---
id: 2502
title: Enforce android coding style with checkstyle
date: 2015-01-08T16:57:49+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2502
permalink: /2015/01/enforce-android-coding-style-with-checkstyle/
categories:
  - Automation
  - Mobile development
tags:
  - android
  - automation
  - gradle
  - java
  - mobile
  - productivity
---
If you appreciate elegant code that is easier to read and consistent from file to file you probably want to start using checkstyle on you java projects.

If your project is a simple java project that uses gradle you can start using checkstyle by adding this to your build.gradle file:

```
apply plugin: 'checkstyle'
```

and creating this file under config/checkstyle/checkstyle.xml (I stole it from [Marco&#8217;s example](https://github.com/marcoRS/volley-examples)):

<!--more-->

```xml
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE module PUBLIC "-//Puppy Crawl//DTD Check Configuration 1.3//EN"
   "http://www.puppycrawl.com/dtds/configuration_1_3.dtd">
<module name="Checker">
    <property name="severity" value="error" />

    <module name="TreeWalker">
        <property name="tabWidth" value="4" />
        <module name="ConstantName" />
        <module name="LocalFinalVariableName" />
        <module name="LocalVariableName" />
        <module name="MethodName" />
        <module name="PackageName" />
        <module name="ParameterName" />
        <module name="TypeName" />
        <module name="AvoidStarImport" />
        <module name="IllegalImport" />
        <module name="RedundantImport" />
        <module name="UnusedImports" />
        <module name="LineLength">
            <property name="severity" value="ignore" />
            <metadata name="net.sf.eclipsecs.core.lastEnabledSeverity" value="inherit" />
        </module>
        <module name="MethodLength" />
        <module name="ParameterNumber" />
        <module name="EmptyForIteratorPad" />
        <module name="MethodParamPad" />
        <module name="NoWhitespaceAfter">
            <property name="tokens" value="BNOT,DEC,DOT,INC,LNOT,UNARY_MINUS,UNARY_PLUS" />
        </module>
        <module name="NoWhitespaceBefore" />
        <module name="OperatorWrap" />
        <module name="ParenPad" />
        <module name="TypecastParenPad" />
        <module name="WhitespaceAfter" />
        <module name="WhitespaceAround">
           <property name="allowEmptyMethods" value="true" />
        </module>
        <module name="ModifierOrder" />
        <module name="RedundantModifier" />
        <module name="AvoidNestedBlocks" />
        <module name="EmptyBlock" />
        <module name="LeftCurly" />
        <module name="NeedBraces" />
        <module name="RightCurly" />
        <module name="EmptyStatement" />
        <module name="EqualsHashCode" />
        <module name="IllegalInstantiation" />
        <module name="InnerAssignment" />
        <module name="MagicNumber" />
        <module name="MissingSwitchDefault" />
        <module name="RedundantThrows">
            <property name="suppressLoadErrors" value="true" />
        </module>
        <module name="SimplifyBooleanExpression" />
        <module name="SimplifyBooleanReturn" />
        <module name="DesignForExtension">
            <property name="severity" value="ignore" />
            <metadata name="net.sf.eclipsecs.core.lastEnabledSeverity" value="inherit" />
        </module>
        <module name="FinalClass" />
        <module name="HideUtilityClassConstructor" />
        <module name="InterfaceIsType" />
        <module name="ArrayTypeStyle" />
        <module name="FinalParameters">
            <property name="severity" value="ignore" />
            <metadata name="net.sf.eclipsecs.core.lastEnabledSeverity" value="inherit" />
        </module>
        <module name="TodoComment">
            <property name="severity" value="ignore" />
            <metadata name="net.sf.eclipsecs.core.lastEnabledSeverity" value="inherit" />
        </module>
        <module name="UpperEll" />
        <module name="MethodLength">
            <property name="max" value="40" />
        </module>
        <module name="LineLength">
            <property name="max" value="100" />
        </module>
        <module name="InnerTypeLast" />
    </module>
    <module name="NewlineAtEndOfFile">
        <property name="severity" value="ignore" />
        <metadata name="net.sf.eclipsecs.core.lastEnabledSeverity" value="inherit" />
    </module>
    <module name="Translation" />
    <module name="FileTabCharacter">
        <property name="severity" value="ignore" />
        <metadata name="net.sf.eclipsecs.core.lastEnabledSeverity" value="inherit" />
    </module>
    <module name="RegexpSingleline">
        <property name="severity" value="ignore" />
        <property name="format" value="\s+$" />
        <property name="message" value="Line has trailing spaces." />
        <metadata name="net.sf.eclipsecs.core.lastEnabledSeverity" value="inherit" />
    </module>
</module>
```

At this point checkstyle will be run whenever the check task is run.

If you want to use checkstyle with Android you have to work a little more. The checkstyle gradle plugin relies on the java plugin, which is not compatible with the android plugin. The reason this affects you is because by default it will try to compile your code using the default java compiler, which will fail on your Android project. What I did to walk around this issue is disable the compileJava task. These are the important parts of my build.gradle:

```groovy
sourceSets {
  main {
    java.srcDir file('src/main/java/src')
  }
  unitTest {
    java.srcDir file('tests/unit/src')
  }
  automation {
    java.srcDir file('src/androidTest/java/src')
  }
}

// ------------ Checkstyle ---------------
apply plugin: 'checkstyle'
checkstyle {
  ignoreFailures = false
  showViolations = true
}

task health(dependsOn: [
  'checkstyleMain',
  'checkstyleUnitTest',
  'checkstyleAutomation'
])

compileJava.enabled = false
compileUnitTestJava.enabled = false
compileAutomationJava.enabled = false
```

I define some sourceSets that the checkstyle plugin will be able to use automatically. It will try to comiple each of the sourceSets using the java compiler so I have to disable the compile tasks for each of the sourceSets. Now I can run **gradle health** and it will run checkstyle on my source code, unit tests and automation tests.
