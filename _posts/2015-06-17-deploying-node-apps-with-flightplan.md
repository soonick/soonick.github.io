---
id: 2977
title: Deploying node apps with Flightplan
date: 2015-06-17T23:31:19+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2977
permalink: /2015/06/deploying-node-apps-with-flightplan/
categories:
  - Javascript
  - Linux
tags:
  - automation
  - javascript
  - linux
  - node
  - productivity
---
I just built a little node app that I want to make publicly available. I got a little dedicated server where I am going to host my app. The problem now is getting my app into the server. In the past I had done this task using FTP, but now I know better. There are tools out there that allow us to deploy our app to our server(or list of servers) with a single command, and flightplan makes this task very easy for node apps.

## Installation

We need flightplan in our development machine so we can run deploys from there. We can install it from npn:

```
npm install -g flightplan
```

This globally installs the command line tool that allows us to run the fly command. We also need to install flightplan as a dev dependency of our node project:

```
npm install --save-dev flightplan
```

<!--more-->

## The flight plan

Flightplan will by default look for a file named flightplan.js were we define the flights we want to execute and the targets where we want to execute them. I only have one environment so my flightplan will only have one target. The deployment process will be like this:

&#8211; Run a build(will create a dist folder)
  
&#8211; Copy contents of dist folder to the production host in a timestamped folder
  
&#8211; Create symlink to newly created folder
  
&#8211; Stop production server if already running
  
&#8211; Start production server

The reason we create a timestamped folder and then a symlink is because this way we don&#8217;t have to stop the server while we copy the files. Our server will only be down for the time it takes to stop the already running server and start the new one. In a more advanced setup we would want to avoid downtime at all. This is possible if we have more than one server and a load balancer that splits the traffic between them. When doing a deploy we would take a server out of rotation in the load balancer, update the files in that server, restart it and add it back to the load balancer. Then repeat the same process for all remaining servers.

Lets see how flightplan.js for this looks:

```js
var plan = require('flightplan');

var user = 'deploy';
var tmpDir = 'app-' + new Date().getTime();

// Currently only production, but we could have more environments.
// To deploy run:
// fly production
plan.target('production', [
  {
    host: '114.11.49.164',
    username: user,
    agent: process.env.SSH_AUTH_SOCK
  }
]);

// These commands are run in the computer where the fly
// command was issued
plan.local(function(local) {
  local.log('Run build');
  local.exec('./node_modules/grunt-cli/bin/grunt build');

  local.log('Copy files to remote hosts');
  var files = local.find('dist/ -type f', {silent: true});
  local.transfer(files, '~/' + tmpDir);
});

// These commands are run on the production server
plan.remote(function(remote) {
  remote.log('Start application');
  remote.sudo('ln -snf ~/' + tmpDir + ' ~/app', {user: user});
  remote.exec('forever stop ~/app/dist/app/app.js', {failsafe: true});
  remote.exec('forever start ~/app/dist/app/app.js');
});
```

Here I assume that there is a user named **deploy** with access 114.11.49.164 with an SSH key in the current computer. This way, the user will be able to log in to the server without being prompted for a password. This is a very simple example, but you should check flightplan documentation if you need something more advanced.
