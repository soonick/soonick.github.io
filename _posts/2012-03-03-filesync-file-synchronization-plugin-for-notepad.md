---
id: 556
title: 'FileSync: File Synchronization plugin for notepad++'
date: 2012-03-03T03:32:50+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=556
permalink: /2012/03/filesync-file-synchronization-plugin-for-notepad/
categories:
  - C/C++
tags:
  - C/C++
  - programming
  - projects
---
I want to start by thanking Mike Foster ([http://mfoster.com/npp/SessionMgr.html](http://mfoster.com/npp/SessionMgr.html "Session Manager - Mike Foster")) because with out his well written notepad++ plug-in and his instructions to compile it I wouldn&#8217;t have been able to develop this plug-in. I thank also François-R Boyer for helping me when I was stuck([http://sourceforge.net/projects/notepad-plus/forums/forum/482781/topic/4977590](http://sourceforge.net/projects/notepad-plus/forums/forum/482781/topic/4977590 "Source forge - NPPM_GETFULLPATHFROMBUFFERID"))

## What the plug-in does

This is a really simple plug-in that copies a file to another location at the moment you save it. The reason I needed this extension is because I need to deploy my PHP applications using maven to download dependencies so the folder where my version controlled application lives is different than the folder where my executable application lives. Having this extension allows me to work always on my version controlled folder and having the changes immediately applied on the executable application folder.

<!--more-->

The plug-in is currently in a very basic state but I intend to improve it when I have some time. After installing the plug-in (you can find installation instructions at the project page on github) you can configure it by going to Plugins->File Sync->Configure&#8230;

You will then see two text fields with the labels &#8220;Source folder&#8221; and &#8220;Destination folder&#8221;. Source folder is the folder where your version controlled code would live and Destination folder is the folder where your executable code would live. So every time you edit and save any file inside your source folder the file will also be modified on your destination folder.

## Example

Lets say my source folder is: C:\code\ and my destination folder is: C:\my\app\folder\

If I edited the file C:\code\file.txt then the same file will be copied to C:\my\app\folder\file.txt
  
If I edited the file C:\code\folder\anotherfolder\otherfile.txt the same file will be copied to C:\my\app\folder\folder\anotherfolder\otherfile.txt

There are a lot of things that need improvement but I have used the plug-in for a while and it works moderately well.