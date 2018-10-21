---
id: 708
title: Contributing to OpenHatch project
date: 2012-06-21T14:54:59+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=708
permalink: /2012/06/contributing-to-openhatch-project/
tags:
  - git
  - github
  - open_source
  - projects
  - python
---
## What is OpenHatch?

OpenHatch.org is a website where you can find ways to contribute to open source projects, mentor people who want to contribute to a project, or give a little more visibility to your open source project so people can help you.

In my opinion the most interesting features are the classification of some bugs as bitesize, which are good bugs for people who want to help but don&#8217;t have much experience. This is an awesome place to start. The other interesting feature is the ability to offer yourself as a mentor to fix a bug. If you are an expert on a subject but you don&#8217;t have time to fix an specific bug you can list yourself as a mentor and help other people get a bug fixed.

<!--more-->

## Why did I choose to contribute to OpenHatch?

Since I have been learning Python, I was looking for a project where I could get some hands on action with my new abilities :). I went to OpenHatch.org to look for projects using python that needed help. The one that got my attention at first was Pitivi, a video editor written in python. So I went to their website, read the documentation, got my local environment ready for development, but when I started using it I found out that I wasn&#8217;t able to do almost anything. I looked at the code to trace my problem, but everything in the code seemed good, my local installation crashed when a call to an external library was made. Because I have been having a few problems with my graphics driver lately I decided to blame it on it and look for another project.

My second option was the OpenHatch project itself that also uses python as it&#8217;s back-end language.

## Submitting my first fix

I started by making the site run locally for me. It was very easy to make this happen by following the instructions on their wiki: <a href="https://openhatch.org/wiki/Getting_started_with_the_OpenHatch_code" title="OpenHatch wiki" target="_blank">https://openhatch.org/wiki/Getting_started_with_the_OpenHatch_code</a>. My next step was to get some data so my local site didn&#8217;t look that empty. Luckily they had very clear instructions on how to do it: <a href="https://openhatch.org/wiki/Importing_a_data_snapshot" title="Importing data - OpenHatch" target="_blank">https://openhatch.org/wiki/Importing_a_data_snapshot</a>.

Now that I was all set it was time to get started doing something, so I decided to take a look at the bug tracker: <a href="http://openhatch.org/bugs/" title="OpenHatch bug tracker" target="_blank">http://openhatch.org/bugs/</a> and applied the &#8220;Show Bitesized&#8221; filter to start with something small. I started looking through the unassigned tickets and very early I found one bug that I could reproduce: <a href="http://openhatch.org/bugs/issue726" title="OpenHatch tar mission bug" target="_blank">http://openhatch.org/bugs/issue726</a>. I decided to work on that one so I assigned it to me and changed the status to &#8220;in-progress&#8221;. It was a very easy bug so I soon had the fix.

I started reading at the documentation for instructions of how to integrate my fix to the main repository, but while I was on it I decided to quickly ask on the IRC channel what was the recommended approach. They were really helpfull with their suggestions and they recommended to use a Github pull request if I was familiar with them. The exact steps they asked me to follow are:

  * Create a new branch on my forked repository
  * Add a commit (or a list of commits) with my change on the branch I created
  * Create a pull request from that commit to their main branch
  * Update the issue on their bug tracker, changing the status to &#8220;need-review&#8221; and adding a comment with a link to the pull request

so, that I did. Soon my small code fix was added to the master branch on the main repository and integrated into the site.

## Conclusion

Overall it was a very cool experience. I was really amazed at the response speed in the IRC channel, they answered my questions really fast and with really helpful comments. The OpenHatch team has already helped me pick a bug of my interest and I look forward to fixing it.
