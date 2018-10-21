---
id: 799
title: JavaScript Static Code Analysis Using JSLint
date: 2013-01-24T05:40:25+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=799
permalink: /2013/01/javascript-static-code-analysis-using-jslint/
tags:
  - ant
  - automation
  - java
  - javascript
  - jslint
  - productivity
  - programming
---
JSLint is a Code Static Analysis tool created by Douglas Crockford. JSLint is written in JavaScript so it can easily be run from a browser but since I want to be able to check all my JS files automatically in a CI environment I will use Rhino, a JS engine written in Java that can be run from the command line. To install Rhino in Ubuntu just do:

```
sudo apt-get install rhino
```

Once installed you can take it out for a ride:

```
adrian@me:~$ rhino
Rhino 1.7 release 3 2012 05 18
js> var a = 4;
js> a;
4
js> a + 7;
11
js> quit();
adrian@me:~$
```

<!--more-->

As you can see you can run JS code normally but it is important to keep in mind that in the context of Rhino the DOM and functions like alert don&#8217;t exist.

The advantage of having Rhino is that since JSLint is JavaScript code we can just execute it from rhino with no need of a browser, which makes it easier to script. Rhino also provides some functions to load JS files from the file system and to read text files. To do more advanced file system operations Rhino can interface with Java and use some of it&#8217;s functions.

I created a script that will run JSLint on all JS files in a folder recursively so I can do code static analysis in a whole project with just one command:

```js
/**
 * This scripts runs JSLint against all the JS files in the specified folder. It
 * is expected to be run using rhino and passing the path to JSLint as first
 * argument and the folder to lint as the second argument
 *
 * rhino thisScript /path/to/jslint.js folder/to/lint
 */
(function(arguments) {
    // Load JSLint
    load(arguments[0]);
    importPackage(java.io);

    /**
     * Scan a file using JSLint
     *
     * @param String filePath.- Path of the file to scan
     *
     * @return Boolean success.- True if there were no errors in the scanned
     *                 file, false otherwise.
     */
    function scanFile(filePath) {
        var success = true;

        JSLINT(readFile(filePath), {predef: ['$']});
        for (error in JSLINT.errors) {
            if (null !== JSLINT.errors[error]) {
                success = false;
                print(JSLINT.errors[error].reason);
                print(JSLINT.errors[error].evidence);
                print('----------------------------------------');
            }
        }

        return success;
    }

    /**
     * Scans JS files in a given directory using scanFile
     *
     * @param String path
     *
     * @return Boolean success.- True if there were no errors, false otherwise
     */
    function scanDirectory(path) {
        var success = true;
        var scanPath = new File(path);

        // If the path is a directory then scan all the files recursively, else
        // scan just the given file
        if (scanPath.isDirectory()) {
            var absolutePath = scanPath.getAbsolutePath();
            var contents = scanPath.list();
            for (var i = 0; i < contents.length; i++) {
                // Skip hidden files
                if (0 === contents[i].indexOf('.')) {
                    continue;
                }
                if (!scanDirectory(absolutePath + '/' + contents[i])) {
                    success = false;
                }
            }
        } else {
            // If this is a JS file scan it
            if (path.indexOf('.js') === (path.length - 3)) {
                if (!scanFile(path)) {
                    success = false;
                }
            }
        }

        return success;
    }

    // exitCode will be 0 if all files passed the analysis
    var exitCode = scanDirectory(arguments[1]) ? 0 : 1;
    quit(exitCode);
}(arguments));
```

The comments explain most of what the script does, but there are some other things that I think are important to explain. You can have rhino run a JS file by calling:

```
rhino scriptToExecute.js
```

If you add more arguments after the script file you want to execute those arguments will be available in the global arguments array in the script that is being executed. That means that if we called:

```
rhino executeMe.js 10 hello 5
```

The global variable arguments for executeMe.js will be an array with 10, &#8216;hello&#8217; and 5 on it.

The **load** function will load a JS file and execute it&#8217;s code. In this case we are loading JSLint and making it available for this script.

The function **importPackage** is a rhino function that serves the same purpose of Java&#8217;s import declaration. In this case we are using it to load **java.io** in order to have access to the File object and it&#8217;s methods that allow us to get information about the file system. We are specifically using the methods **getAbsolutePath**, **list** and **isDirectory** to recursively search for JS files.

**readFile** is a rhino function that will read a file and return it&#8217;s content as a string. We are using it to pass the source code to be parsed by JSLint.

Having JSLint parse a file is straight forward, we just need to call the JSLINT function and pass the JS code we want to lint. Optionally you can pass some additional options as a second argument. In this case I am using the **predef** options to tell JSLint that the **$** function is defined somewhere else and shouldn&#8217;t see it&#8217;s use as an error.

## Plugging it to ant

Once we have the script above we can easily plug it to ant and hopefully to a CI process by creating a build.xml file (that I explain how to create in this post: [PHP Code Static Analysis](http://ncona.com/2012/11/php-code-static-analysis/)) and just adding this target:

```xml
<target name="jslint" description="Run JSLint">
    <exec executable="rhino" failonerror="true">
        <arg value="/path/to/the/script/above.js"/>
        <arg value="/path/to/jslint.js"/>
        <arg value="/path/to/folder/to/lint"/>
    </exec>
</target>
```
