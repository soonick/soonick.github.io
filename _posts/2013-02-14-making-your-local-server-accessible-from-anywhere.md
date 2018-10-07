---
id: 1152
title: Making your local server accessible from anywhere
date: 2013-02-14T05:34:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1152
permalink: /2013/02/making-your-local-server-accessible-from-anywhere/
categories:
  - Linux
tags:
  - apache
  - networking
  - ssh
---
In reality you probably don&#8217;t want to host you websites on your local computer unless you have a very good computer, a very good internet connection and you are an expert system administrator, but this is very useful to learn how the internet works.

In this case I am doing this because I want to be able to develop on my computer no matter where I am. So I want to be able to SSH to my machine, modify my files and view my changes from a web browser. Here are the things that need to be done:

  * Setup a local HTTP server
  * Allow inbound traffic on port 80
  * Setup a free DNS service
  * Setup an SSH server
  * Forward requests to port 22 on your router to your computer

<!--more-->

## Set up a local HTTP server

I already wrote an article explaining how to do this: [Creating local virtual hosts with Apache](http://ncona.com/2011/06/creating-local-virtual-hosts-with-apache/)

## Allow inbound traffic on port 80

To make your HTTP server available from the Internet you have to configure your router to send all incoming traffic on port 80 to your computer. The way to do this varies depending you router and ISP, but the steps are very similar most of the time:

  * Go to your router configuration page on a web browser. A lot of times it is http://192.168.1.254/ or http://192.168.1.1/
  * Go to firewall or DMZ setting
  * There will probably be a section that says something similar to: &#8220;Allow device application traffic to pass through firewal&#8221; Then:</p> 
      * Choose your computer
      * Forward external TCP traffic on port 80 (If you are asked for a range choose 80 to 80) to port 80
      * Save

To test that everything went well you can search for &#8220;my ip&#8221; on Google and it will give you your public IP address. You can give this IP address to anyone and they will see you local server.

## Set up free DNS service

Since most internet providers give their customers a dynamic IP address it is not efficient to access your computer that using that number, since it may change at any time. Luckily there are some free services that allow to overcome this issue.

I found https://www.changeip.com/ did the job for me. You just have to click on &#8220;Free DNS&#8221; and they will let you choose a free subdomain. Then you just have to register and they will automatically detect your public IP. Now anyone can access your local server using that subdomain.

## Set up an SSH server

An SSH server makes your computer available via a terminal to other computers using an SSH client. You can install an SSH server on Ubuntu with this command:

```
sudo apt-get install openssh-server
```

Once the server is installed you can test it by trying to connect to it.

```
ssh yourname@127.0.0.1
```

When prompted for a password enter your login password.

## Forward requests to port 22 on your router to your computer

You can follow the same procedure you used for port 80, just change it port 22. Now you can ssh to your machine using the subdomain you choose for your server.
