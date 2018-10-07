---
id: 1890
title: Java code static analysis with Pmd
date: 2014-02-06T04:08:19+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1890
permalink: /2014/02/java-code-static-analysis-with-pmd/
categories:
  - Automation
tags:
  - android
  - automation
  - java
  - productivity
---
Pmd is a tool for running code static analysis for multiple languages. The first thing you need to use it is download it from [Pmd&#8217;s website](http://pmd.sourceforge.net/ "Pmds website"). Clicking the download button will download a zip file. Uncompress that zip and you will have all you need.

## Running code static analysis

Once you have pmd on your computer you can analyse your code using this command:

```
<path to pmd>/bin/run.sh pmd -d <src folder> -l java -f <reporting format> -R <rules>
```

<!--more-->

Reporting format can be one or more(separated by commas) of these: csv, html, text, textcolor, xml.

Rules can be found in the [Pmd rulesets index](http://pmd.sourceforge.net/pmd-5.0.5/rules/index.html "Pmd rulesets index"), but you can find the correct way to call it in your <path to pmd>/docs/rules/rules/java folder. For example, there is a file called finalizers there, so you can use a rule called java-finalizers.

Here is how I use it:

```
<path to pmd>/bin/run.sh pmd -d src/ -l java -f text -R java-android,java-basic,java-braces,java-clone,java-codesize,java-comments,java-controversial,java-design,java-empty,java-finalizers,java-imports,java-j2ee,java-junit,java-naming,java-optimizations,java-strictexception,java-strings,java-sunsecure,java-typeresolution,java-unnecessary,java-unusedcode
```
        

## Copy paste detector

Pmd also comes with a copy paste detector that can help you prevent duplication of code. You can use it like this:

```
<path to pmd>/bin/run.sh cpd --minimum-tokens 50 --files src/ --language java
```

Minimum tokens is the number of lines that need to be repeated for Pmd to give you a warning.
