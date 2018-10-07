---
id: 14
title: Firefox extensions development
date: 2011-05-21T00:47:24+00:00
author: adrian.ancona
layout: post
guid: http://ncona.dev/?p=14
permalink: /2011/05/firefox-extensions-development/
categories:
  - Javascript
tags:
  - firefox extension
  - javascript
  - projects
  - tntfixer
  - xul
---
For strange reasons I have been needing to use Test and Target in my current job. Test and Target is a tool that allows to easily perform content testing for  websites. The thing is that it&#8217;s interface has some issues that make working with it a little dangerous. Because of  that I decided to create a Firefox extension that will decrease the dangers of the interface. I will try to explain through a series of posts the procedure I will follow to create this extension.

<!--more-->

# Environment Set-up

The recommended way to start developing a Firefox extension is by creating a new profile that will only be used for that purpose. The reason is that the settings that we are going to use for the development profile are going to affect the performance of Firefox making it slower and probably unstable.

To create a new profile you can run this command from a Linux terminal:

```
/usr/bin/firefox -no-remote -P dev
```

On windows you can open your start menu, hit run and enter this command

```
"%ProgramFiles%\Mozilla Firefox\firefox.exe" -no-remote -P dev
```

The first time you run this command a window to choose a profile will pop up. Click &#8220;Create profile&#8221; and create a profile with the name &#8220;dev&#8221;. The next time you execute the command Firefox will start using that profile.

Now that you have Firefox open using your dev profile, we are going to set some settings that will allow Firefox to report more explicit errors and other useful options for development. Type &#8220;about:config&#8221; on the address bar to get to the preferences configuration page. Not all preferences are defined by
  
default, and are therefore not listed in about:config. You will need to create new boolean entries for the ones that are not in the list yet.

These are the options you need to add or modify:

```js
javascript.options.showInConsole = true
nglayout.debug.disable_xul_cache = true
browser.dom.window.dump.enabled = true
javascript.options.strict = true
devtools.chrome.enabled = true
extensions.logging.enabled = true
nglayout.debug.disable_xul_fastload = true
dom.report_all_js_exceptions = tru
```

## Creating the extension

Now Firefox is set and we will start the actual development.

I didn&#8217;t use much imagination for the name of the project so I am going to call it &#8220;tntfixer&#8221;. I will create a folder with the same name of the the project, you should do the same with the name of your project. For this example this is the location of my project&#8217;s folder

```
/home/adrian/Dev/tntfixer
```

Firefox extensions need to follow an standard folder structure. For a minimal extension you will need to create a folder named &#8220;chrome&#8221; and a folder named &#8220;content&#8221; inside of it. Now create the following text files:

```
/home/adrian/Dev/tntfixer/chrome/content/tntfixer.xul
/home/adrian/Dev/tntfixer/chrome.manifest
/home/adrian/Dev/tntfixer/install.rdf
```

Now we need to fill the files with the correct content. We will start with the install.rdf file, this file lets Firefox extension manager obtain information about the extension and show it to the user. This is the content of my file.

```xml
<?xml version="1.0"?>
<RDF xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:em="http://www.mozilla.org/2004/em-rdf#">
    <Description about="urn:mozilla:install-manifest">
        <em:id>tntfixer@tntfixer.net</em:id>
        <em:version>1.0</em:version>
        <em:type>2</em:type>

        <em:targetApplication>
            <Description>
               <em:id>{ec8030f7-c20a-464f-9b0e-13a3a9e97384}</em:id>
               <em:minVersion>3.5</em:minVersion>
               <em:maxVersion>4.0.*</em:maxVersion>
            </Description>
        </em:targetApplication>

        <em:name>TnT Fixer</em:name>
        <em:description>Fixes dangers TnT interface</em:description>
        <em:creator>Adrian Ancona Novelo</em:creator>
        <em:homepageURL>http://www.example.com/</em:homepageURL>
    </Description>     
</RDF>
```

As you can see it is an XML file. This structure is necessary for Firefox to understand it. I will explain the parts that you would need to change for your extension.

  * **&lt;em:id&gt;** is an unique identifier for your extension. It needs to have the same format as an e-mail address but it doesn&#8217;t have to be one. The e-mail address I used for this extension doesn&#8217;t actually exist.

  * **&lt;em:version&gt;** This is the current version of your extension

  * **&lt;em:type&gt;** This indicates the type of add-on. It can be a theme, an extension or a plug-in. Number 2 means extension.

  * **&lt;em:targetApplication&gt;** Contains information about the application this extension is targeted to. The content of the **&lt;em:id&gt;** tag means Firefox and must not be changed. **&lt;em:minVersion&gt;** and **&lt;em:maxVersion&gt;** indicate the versions of Firefox this extension will support.

  * **&lt;em:name&gt;** Is the name of the extension that will be shown to the user

  * **&lt;em:description&gt;** Is the description of the extension that will be shown to the user

  * **&lt;em:creater&gt;** The name of the creator

  * **&lt;em:homepageURL&gt;** Should be the the page of your extension

The next file I am going to explain is the chrome.manifest. This file associates application resources with their location relative to the extension directory. This is the content of mine:

```
content	tntfixer chrome/content/
overlay chrome://browser/content/browser.xul chrome://tntfixer/content/tntfixer.xul
```

The first line creates a content resource and points it to the relative path of your content folder.

The second line tells Firefox to mix its default overlay with your extension&#8217;s overlay.

The only UI element I will use for the first version of my extension is an icon that I will place in the status bar. Here is where tntfixer.xul comes to play. Here is its content:

```xml
<?xml version="1.0"?>
<overlay id="tntfixer"
        xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
    <statusbar id="status-bar">
        <statusbarpanel id="tntFixerPanel">
            <label>tntfixer</label>
        </statusbarpanel>
    </statusbar>
</overlay>
```

This is also a XML file. The overlay element is mandatory and should always point to there.is.only.xul. The element statusbar with id status-bar means that we are adding an element to the browser status bar. The statusbarpanel is a panel we are adding to the status bar, you should add an id to that panel to be able to reference it from you extension. Inside statusbarpanel I created a label that in the future will help interact with my extension. For now it will only be there.

## Adding the extension to firefox

Now to the final step. Getting your extension into Firefox. To do this first we have to find our extensions folder for our dev profile. The location of the folder for my computer is:

```
/home/adrian/.mozilla/firefox/qepr45ed.dev/extensions
```

The important part here is the qepr45ed.dev, the dev indicates that it is the folder for the dev profile. Once inside that folder we need to create a file named after the id of our extension. In this case: tntfixer@tntfixer.net, the content of that file must be the path to your extension folder, in this case:

```
/home/adrian/Dev/tntfixer/
```

Now we just need to restart Firefox and we will be able to see our label on the browser status bar.
