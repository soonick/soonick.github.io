---
id: 491
title: Configuring a quick and ugly local email server on Ubuntu
date: 2012-01-19T01:30:52+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=491
permalink: /2012/01/configuring-a-quick-and-ugly-local-email-server-on-ubuntu/
tags:
  - apache
  - e-mail
  - linux
---
Configuring an e-mail server for local testing on ubuntu is a really fast an easy task. You just need to install and configure sendmail with these commands:

```
sudo apt-get install sendmail
sudo sendmailconfig
```

The first command gets and installs sendmail from ubuntu repositories. The second command will run a configuration script that will ask you some questions about your configuration.

After you do this you have to add a fully qualified domain name to your hosts file or your server will not work.

Your hosts file should have something like this:

```
127.0.0.1 yourdomain.dev
```

You can really write the domain name you want but it needs to be fully qualified, that means it should contain a top level domain, in my example **dev**.

<!--more-->
