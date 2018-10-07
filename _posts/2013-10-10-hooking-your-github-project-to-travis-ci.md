---
id: 1787
title: Hooking your github project to Travis-CI
date: 2013-10-10T03:51:33+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1787
permalink: /2013/10/hooking-your-github-project-to-travis-ci/
categories:
  - Automation
tags:
  - Git
  - github
  - node
  - open source
  - php
  - productivity
  - projects
---
I have a little open source project that I am trying to slowly improve. One of the steps I&#8217;m taking to do this is to add some tests and code static analysis. If something is running correctly I don&#8217;t want regressions so I need to plug it to CI so it runs for every commit. A lot of people are using [Travis](https://travis-ci.org/ "Travis CI") so I decided to give it a try. The first steps can be found at [Travis&#8217; getting started page](http://about.travis-ci.org/docs/user/getting-started/ "Travis getting started").

My project is a PHP project but it needs node to run grunt tasks so I was worried about not being able to specify two programming languages in the yml file. Luckily Travis includes a version of node on all VMs no matter what type of project you are using, so I could freely use npm and grunt:

```yml
language: php
php:
  - "5.4"
before_script: "npm install"
script: "./node_modules/grunt-cli/bin/grunt"
```

I also found that if you have a very specific requirement you can even use apt-get to download dependencies and then you will be able to use it as part of your task.
