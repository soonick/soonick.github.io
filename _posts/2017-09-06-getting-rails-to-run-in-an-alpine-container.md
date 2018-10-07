---
id: 4236
title: Getting Rails to run in an Alpine container
date: 2017-09-06T13:24:08+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4236
permalink: /2017/09/getting-rails-to-run-in-an-alpine-container/
categories:
  - Linux
tags:
  - automation
  - docker
  - productivity
  - rails
  - ruby
---
I&#8217;m trying to get a little Rails application ready for production, and just for fun I&#8217;m trying to make the image a little slimmer than it currently is (860 MB).

There is a official docker image of ruby with alpine (ruby:alpine), but because of the libraries that rails uses (with native bindings), it is a little more challenging than just referencing that image on the top of the Dockerfile.

## Solving the issues

I added **FROM ruby:2.4.1-alpine** at the top of my Dockerfile and tried to create the image. The first problem I faced was with [myql2](https://github.com/brianmario/mysql2). For the mysql2 gem to work on Alpine it is necessary to have a compiler (build-base) and MySQL development libraries (mariadb-dev). I added this to my Dockerfile:

<!--more-->

```docker
RUN apk add --update \
  build-base \
  mariadb-dev \
  && rm -rf /var/cache/apk/*
```

The next error was about sqlite3, which I use for my tests. To fix it we need to install **sqlite-dev**:

```docker
RUN apk add --update \
  build-base \
  mariadb-dev \
  sqlite-dev \
  && rm -rf /var/cache/apk/*
```

This was enough for Docker to be able to build the image, but when I tried to run it I got an error related to [therubyracer](https://github.com/cowboyd/therubyracer), a V8 JavaScript interpreter used by Rails to compile your JS assets (among other things). To solve this issue I removed therubyracer from my Gemfile:

```
# Removed this line
gem 'therubyracer', platforms: :ruby
```

And installed node on the image. Node is able to compile my JS assets but doesn&#8217;t do everything therubyracer does. My app didn&#8217;t need any of the extra functionality, so this was enough:

```docker
RUN apk add --update \
  build-base \
  mariadb-dev \
  sqlite-dev \
  nodejs \
  && rm -rf /var/cache/apk/*
```

Next was a Railtie complaining about tzinfo-data not being present. This issue was easily fixed by installing tzdata:

```docker
RUN apk add --update \
  build-base \
  mariadb-dev \
  sqlite-dev \
  nodejs \
  tzdata \
  && rm -rf /var/cache/apk/*
```

## The final result

After this I was able to run my Rails application successfully. The size of the new image is 580 MB (67% the size of the original one). I was actually expecting a bigger gain, but given that it was not really that hard, I&#8217;ll call it a gain. My final Dockerfile looks like this:

```docker
FROM ruby:2.4.1-alpine

RUN apk add --update \
  build-base \
  mariadb-dev \
  sqlite-dev \
  nodejs \
  tzdata \
  && rm -rf /var/cache/apk/*

RUN gem install bundler

# First copy the bundle files and install gems to aid caching of this layer
WORKDIR /myapp
COPY Gemfile* /myapp/
RUN bundle install

WORKDIR /myapp
COPY . /myapp

CMD /bin/sh -c "rm -f /myapp/tmp/pids/server.pid && ./bin/rails server"
```
