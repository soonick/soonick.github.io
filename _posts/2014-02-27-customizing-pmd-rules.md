---
id: 1962
title: Customizing PMD rules
date: 2014-02-27T04:34:52+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1962
permalink: /2014/02/customizing-pmd-rules/
tags:
  - automation
  - java
  - productivity
---
PMD allows you to perform code static analysis for your project, but sometimes the default doesn&#8217;t fit the way you decided to write code. The good thing is that you can customize the rules you want to use to fit your preferences.

To customize the rules you will need to create an xml file with this structure:

```xml
<?xml version="1.0"?>
<ruleset name="Custom ruleset"
   xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0 http://pmd.sourceforge.net/ruleset_2_0_0.xsd">
    <description>Rules for my project</description>
</ruleset>
```

<!--more-->

Then you can add rules you want to use:

```xml
<rule ref="rulesets/java/clone.xml" />
```

Similar rules come packed together some times, but if for some reason there is a rule you don&#8217;t want to use you can exclude it:

```xml
<rule ref="rulesets/java/comments.xml">
    <exclude name="CommentSize" />
</rule>
```

There are some rules that allow you to customize some values. For my project I wanted to allow more methods per class than the default (10). So I had to do this:

```xml
<rule ref="rulesets/java/codesize.xml" />
<rule ref="rulesets/java/codesize.xml/TooManyMethods">
    <properties>
        <property name="maxmethods" value="20" />
    </properties>
</rule>
```

The PMD configuration file for my project looks something like this:

```xml
<?xml version="1.0"?>
<ruleset name="Custom ruleset"
    xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0 http://pmd.sourceforge.net/ruleset_2_0_0.xsd">

    <description>My project rules</description>

    <rule ref="rulesets/java/android.xml" />
    <rule ref="rulesets/java/basic.xml" />
    <rule ref="rulesets/java/braces.xml" />
    <rule ref="rulesets/java/clone.xml" />
    <rule ref="rulesets/java/codesize.xml" />
    <rule ref="rulesets/java/codesize.xml/TooManyMethods">
        <properties>
            <property name="maxmethods" value="20" />
        </properties>
    </rule>
    <rule ref="rulesets/java/comments.xml">
        <exclude name="CommentSize" />
    </rule>
    <rule ref="rulesets/java/controversial.xml">
        <exclude name="OnlyOneReturn" />
        <exclude name="AvoidLiteralsInIfCondition" />
        <exclude name="DataflowAnomalyAnalysis" />
    </rule>
    <rule ref="rulesets/java/design.xml" />
    <rule ref="rulesets/java/empty.xml" />
    <rule ref="rulesets/java/finalizers.xml" />
    <rule ref="rulesets/java/imports.xml" />
    <rule ref="rulesets/java/j2ee.xml" />
    <rule ref="rulesets/java/junit.xml" />
    <rule ref="rulesets/java/naming.xml">
        <exclude name="LongVariable" />
        <exclude name="ShortVariable" />
    </rule>
    <rule ref="rulesets/java/optimizations.xml" />
    <rule ref="rulesets/java/strictexception.xml" />
    <rule ref="rulesets/java/strings.xml" />
    <rule ref="rulesets/java/sunsecure.xml" />
    <rule ref="rulesets/java/typeresolution.xml" />
    <rule ref="rulesets/java/unnecessary.xml">
        <exclude name="UselessParentheses" />
    </rule>
    <rule ref="rulesets/java/unusedcode.xml" />
</ruleset>
```

To run PMD using the custom rules you defined you can use:

```
pmdRun.sh pmd -d src/ -f text -R pmd_rules.xml
```
