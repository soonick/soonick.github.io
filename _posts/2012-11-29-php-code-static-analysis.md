---
id: 913
title: PHP Code Static Analysis
date: 2012-11-29T04:42:12+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=913
permalink: /2012/11/php-code-static-analysis/
categories:
  - Automation
tags:
  - automation
  - php
  - programming
  - testing
---
Static analysis is the practice of analyzing code without actually executing it. The analysis can do a wide variety of checks with different tools. I will focus my attention on the most common tools available for PHP code analysis.

For installing some of the tools in this article you will need to have these packages installed on your system:

```
sudo apt-get install php-pear
sudo apt-get install php5-xsl
sudo apt-get install php5-dev
sudo apt-get install default-jdk
sudo apt-get install ant
```

## PHP Code Sniffer

PHP Code Sniffer is a tool that helps us make sure our coding style standards are being followed. To install you just need to:

```
sudo pear install PHP_CodeSniffer
```

<!--more-->

In it&#8217;s most simple use you can just specify the file or folder you want to sniff:

```
phpcs somefile.php
```

In real life you will want to specify which coding standard to follow. PHPCS comes with some popular standards build in. You can verify which ones are installed with this command:

```
phpcs -i
```

And you can specify which standard to use:

```
phpcs --standard=Zend controllers/
```

Something worth mentioning about PHPCS is that it can also be used to sniff CSS files.

## PHP Mess Detector

PHPMD Aims to analyze PHP code and find things like:

  * Possible bugs
  * Suboptimal code
  * Overcomplicated expressions
  * Unused parameters, methods, properties

You can now install PHPMD via pear:

```
sudo pear channel-discover pear.phpmd.org
sudo pear channel-discover pear.pdepend.org
sudo pear install --alldeps phpmd/PHP_PMD
```

Now we can run PHPMD against our code. Here is the expected format:

```
phpmd [filename|directory] [report format] [ruleset file]
```

And here is a real example:

```
adrian@my-xubuntu:~/Dev/myapp$ phpmd controllers/ text codesize,unusedcode,naming

/home/adrian/Dev/myapp/controllers/IndexController.php:47   Avoid variables with short names like $db. Configured minimum length is
```

## PHPUnit

PHPUnit is the most widely used tool for unit testing PHP code. You can install it via pear:

```
sudo pear channel-discover pear.phpunit.de
sudo pear channel-discover pear.symfony.com
sudo pear install --alldeps phpunit/PHPUnit
```

For running unit tests you need to create a test suite. I talk a little about the subject in [Test driven development with Zend Framework](http://ncona.com/2011/11/test-driven-development-with-zend-framework/).

To run the test suite you just need to do:

```
phpunit TestSuite.php
```

## PHP copy-paste detector

PHPCPD is a tool that help us find duplicated code in our codebase. It is extremely helpful on keeping our code DRY. To install it:

```
sudo pear config-set auto_discover 1
sudo pear install pear.phpunit.de/phpcpd
```

Using it is very simple, you just need to specify the project folder to analyze:

```
phpcpd application/
```

## PHP Documentor

Creating code documentation is something most programmers hate, but we wish all other programmers did. It has happened to us sometimes that we are new to a code base and we find that there is no documentation for any of the code. This makes the task of understanding what the code does very time consuming. For this reason it is a good idea to enforce the creation of documentation blocks among our code base.

To install PHPDoc:

```
sudo pear channel-discover pear.phpdoc.org
sudo pear install phpdoc/phpDocumentor-alpha
```

And you can use it like this:

```
phpdoc -d application -t docs
```

## Putting it all together

Running all these commands against our PHP project every time we commit something to our repository would be something very inefficient and error prone. For that reason we want to use ant to run all our metrics with a single command.

Ant uses an XML file, by default named build.xml to create rules that will be executed by it. This is the build.xml file for one of my Zend projects:

```xml
<project basedir="." name="myapp">
    <target name="build" depends="phpcs,phpmd,phpcpd,phpdoc"/>

    <target name="phpcs" description="Run PHP Code Sniffer">
        <exec executable="phpcs" failonerror="true">
            <arg value="--standard=Zend"/>
            <arg value="application"/>
            <arg value="public/css"/>
        </exec>
    </target>

    <target name="phpmd" description="Run PHP Mess Detector">
        <exec executable="phpmd" failonerror="true">
            <arg value="application"/>
            <arg value="text"/>
            <arg value="codesize,unusedcode,naming"/>
        </exec>
    </target>

    <target name="phpcpd" description="Run PHP copy-paste detector">
        <exec executable="phpcpd" failonerror="true">
            <arg value="application"/>
        </exec>
    </target>

    <target name="phpdoc" description="Run PHPDoc">
        <exec executable="phpdoc" failonerror="true">
            <arg value="-d"/>
            <arg value="application"/>
            <arg value="-t"/>
            <arg value="docs"/>
            <arg value="-i"/>
            <arg value="application/views/,application/layouts/"/>
            <arg value="--force"/>
            <arg value="--template"/>
            <arg value="checkstyle"/>
        </exec>
    </target>
</project>
```

Now you can just run this command to execute all the static analysis:

```
ant build
```

Finally you may want to plug this ant job to a CI system so it is executed every time a commit or a deploy is made. I will try to go over that subject in a future post.
