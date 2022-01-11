---
id: 258
title: Publish an extension to firefox directory
date: 2011-07-06T01:58:51+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=258
permalink: /2011/07/publish-an-extension-to-firefox-directory/
tags:
  - firefox_extension
  - javascript
  - projects
---
Once you have created an extension, you will probably want to make it easily available to the public.

For my tntfixer extension that I explained in some previous posts I had a folder structure similar to this one:

```
/tntfixer
|----chrome.manifest
|----install.rdf
|----README
|----/chrome
|    |----/content
|    |    |----tntfixer.js
|    |    |----tntfixer.xul
|    |
|    |----/skin
|    |    |----overlay.css
|    |    |----/images
|    |    |    |----status-bar-icon-active.png
|    |    |    |----status-bar-icon-inactive.png
```

<!--more-->

All the extension files are contained in a folder named tntfixer. Making this folder structure installable to Firefox is very easy. We just need to add all the folders and files inside /tntfixer to a zip file. It is important to add only the content of the folder and not the complete folder, this means that inside our tntfixer.zip file we would have chrome.manifest, install.rdf, README and /chrome with all its content.

To make this file installable to Firefox we just need to change the .zip extension to .xpi (pronounced zippy). Now you can drag the file to your browser and you will be prompt to install the extension. Now you can distribute this file from your site, or whatever method you decide.

An excellent way to distribute your extension is using Mozilla Add-ons directory. This will not only make your extension available for download to thousands of people, but will automatically notify the users of your extension when you upload a new version, and will allow them to easily update it.

You need to have an account to be able to upload your extension. To create your account visit Firefox developers page:

```
https://addons.mozilla.org/en-US/developers/
```

You should see a &#8220;Register&#8221; or &#8220;Log-in&#8221; link. Follow the instructions to create your account and return to Firefox developers page. You should see a link saying something like &#8220;Submit an Add-on&#8221;.

The first step is accepting the terms and conditions. They basically say that your extension is free software and that uploading it in the directory doesn&#8217;t give ownership to Mozilla. You also say that your extension doesn&#8217;t contain malware and other stuff that is not that bad :P. You can go ahead and read it, is not that long.

In the next step you will be asked to select your .xpi file and also which platforms does your extension work in. I left mine with the default selection, but go ahead and select what you think is correct.

The next step will ask you to fill some information about your extension: name, description and category.

Next you will be given the option to upload an icon and a screen-shot. The screen-shot is necessary to complete the process.

Then you will have to select a license, I chose GPL, but there are some important difference between licenses that you may want to investigate.

Finally you have to choose a review option. All Mozilla extensions are reviewed so they don&#8217;t contain malware or any obvious bug that would hang the browser. The two options are Full Review, and Preliminary review. You should choose Full Review if you want your extension to be available to anyone that browses Firefox directory.

After that you will receive your extension direct link that you can start using right away to give to your friends or people you know.

That&#8217;s it, you only need to wait and hope your extension passes the review.

[This is the link to my extension.](https://addons.mozilla.org/en-US/firefox/addon/tnt-fixer/)
