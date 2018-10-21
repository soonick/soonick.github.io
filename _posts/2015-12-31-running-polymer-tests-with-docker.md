---
id: 3385
title: Running Polymer tests with Docker
date: 2015-12-31T00:43:16+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3385
permalink: /2015/12/running-polymer-tests-with-docker/
tags:
  - docker
  - javascript
  - polymer
  - programming
  - testing
---
On a previous post I wrote about [how to write tests for polymer components](http://ncona.com/2015/12/testing-polymer-components-using-web-component-tester/). Now, I want to hook those tests into my automated test suite that runs for all commits in a repo. The problem is that we are kind of in a low budget so we don&#8217;t have a selenium grid we can connect to. What we do have is a machine where we have Jenkins installed. Because we run many different jobs in this machine, we usually use docker to keep our environment isolated.

The problem now is that we can&#8217;t run polymer tests in a headless browser like phantomjs, because it is not supported. We have to run our tests in a real browser like Chrome or Firefox. These browsers need a GUI to work which docker doesn&#8217;t provide, so we have to do a few things to work around this issue.

## xvfb

Xvfb stands for X virtual framebuffer. It is a display server that implements the X11 protocol, but does everything in memory, so it doesn&#8217;t really need a screen to work. This is exactly what we need. To use it we just need to create a Dockerfile that uses xvfb to run the tests:

<!--more-->

```docker
FROM ubuntu

# General sanity
RUN apt-get update;

# Install chrome to run the tests
RUN apt-get install -y curl
RUN curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google.list
RUN apt-get update
RUN apt-get install -y google-chrome-stable

# Install xvfb so we can run tests headless
RUN apt-get install -y xvfb;

# Install git, needed by bower
RUN apt-get install git -y

# Install java, needed by selenium
RUN apt-get install default-jre -y

# Some cleanup
RUN apt-get clean

# Install Node
WORKDIR /usr/src
ENV NODE_VERSION 5.0.0
RUN wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz
RUN tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1
RUN rm "node-v$NODE_VERSION-linux-x64.tar.gz"

# Copy project files
COPY ncona-accordion.html /usr/src
COPY wct.conf.json /usr/src
COPY package.json /usr/src
COPY bower.json /usr/src
COPY test/ test/

# Install dependencies
RUN npm install
RUN ./node_modules/bower/bin/bower install --config.interactive=false --allow-root

# Run tests using xvfb
RUN xvfb-run  ./node_modules/web-component-tester/bin/wct
```

As easy as that, you can have now run polymer tests on a real chrome browser under docker.
