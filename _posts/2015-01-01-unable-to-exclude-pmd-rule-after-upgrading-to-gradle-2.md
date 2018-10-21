---
id: 2498
title: Unable to exclude PMD rule after upgrading to gradle 2
date: 2015-01-01T02:02:04+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2498
permalink: /2015/01/unable-to-exclude-pmd-rule-after-upgrading-to-gradle-2/
tags:
  - mobile
  - android
  - automation
  - gradle
  - productivity
---
After upgrading to gradle 2.2.1 I started having some weird issues with my PMD plugin. I kept getting this error:

```
[adrian@localhost project]$ gradle pmdMain
:pmdMain
* file: ./src/main/java/src/com/ncona/project/File.java
    src:  File.java:45:45
    rule: UselessParentheses
    msg:  Useless parentheses.
    code: getCurrentTime() + (1000 * 60 * 60 * 2),
...
```

<!--more-->

I wasn&#8217;t specifically including this rule in my ruleset file but I tried excluding it to see what happened. I added this to my ruleset.xml file:

```xml
<rule ref="rulesets/java/unnecessary.xml">
  <exclude name="UselessParentheses" />
</rule>
```

This didn&#8217;t have any effect. I didn&#8217;t know what else to do, so I tried to find an answer in Google. It turns out a [feature](https://github.com/gradle/gradle/blob/master/subprojects/code-quality/src/main/groovy/org/gradle/api/plugins/quality/PmdPlugin.groovy) was added to the plugin where it automatically adds some rules for you. Luckily [someone found the issue before](http://sourceforge.net/p/pmd/bugs/1225/) me and got a work around:

```groovy
pmd {
  ruleSets = [] // This overwrites the rules that are being added
  ruleSetFiles = files('config/pmd/rulesets.xml')
}
```

This fixed the issue.
