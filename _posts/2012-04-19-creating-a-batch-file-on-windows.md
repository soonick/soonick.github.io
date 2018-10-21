---
id: 623
title: Creating a batch file on windows
date: 2012-04-19T04:30:17+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=623
permalink: /2012/04/creating-a-batch-file-on-windows/
tags:
  - automation
  - programming
---
It is well known that creating a batch file in Linux is an easy and enjoyable task, but right now I find myself in the necessity of automating some tasks on windows so I will need to learn how to do this on windows.

In windows batch files generally have a .bat extension, so I will start by creating a file: **examplebatch.bat** and trying a very simple command:

```
dir
```

Now if I navigate to the folder where my batch file is (let&#8217;s say C:\Adrian\Batch) I can execute the batch file and the dir command will be executed:

```
C:\Adrian\Batch>examplebatch.bat

C:\Adrian\Batch>dir
Volume in drive C is OSDisk
Volume Serial Number is C252-78D4

Directory of C:\Adrian\Batch
04/18/2012  08:42 PM    <DIR>          .
04/18/2012  08:42 PM    <DIR>          ..
04/18/2012  08:43 PM                 3 examplebatch.bat
               1 File(s)              3 bytes
               2 Dir(s)  186,052,022,272 bytes free
```

<!--more-->

Easy so far. One useful thing to do is to add the folder where you are going to store all your batch files to your path (I won&#8217;t explain how to do this). This way you can just issue the command **examplebatch** and your examplebatch.bat script will be executed even if you are not currently in your batch folder.

There are a few interesting directives that I think will be useful when I am writing more advanced scripts. The **@echo off** directive tells the interpreter not to echo the commands executed from the batch. For example, if we modified examplebatch.bat to have this content:

```
@echo off

dir
```

And we called it from our Batch folder we would see an output like this:

```
C:\Adrian\Batch>examplebatch.bat
Volume in drive C is OSDisk
Volume Serial Number is C252-78D4

Directory of C:\Adrian\Batch
04/18/2012  08:42 PM    <DIR>          .
04/18/2012  08:42 PM    <DIR>          ..
04/18/2012  08:43 PM                 3 examplebatch.bat
               1 File(s)              3 bytes
               2 Dir(s)  186,052,022,272 bytes free
```

Note that this time we don&#8217;t see the **dir** command in the output.

Being a developer I am used to adding comments to my programs wherever I see necessity. Adding comments on batch files is possible. The downside is that the syntax feels a little weird. For every comment you have to start your line with the work **REM**:

```
@echo off

REM This is a comment

dir
```

Another useful functionality is showing information to the user.To print something into the terminal can use the **echo** command:

```
@echo off

REM This batch file just executed dir

echo I execute the dir command

dir
```

There is a lot more to say about creating batch files on windows, but I am going to leave it on this for today and I will try to show a more advanced example in another article.
