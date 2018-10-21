---
id: 206
title: Creating local virtual hosts with apache
date: 2011-06-08T00:54:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=206
permalink: /2011/06/creating-local-virtual-hosts-with-apache/
tags:
  - apache
  - linux
  - virtual_host
---
If you are a web developer, virtual hosts is probably something you already use, if not, you should.

Virtual hosts allow you to have multiple domains configured in your computer so you can have different web sites in different locations on your hard drive and keep your environment better organized when developing. Virtual servers are also used by shared web hosting companies to host multiple web sites in the same machine, the difference is that they deal with a bunch more stuff that I am not going to deal with in here. This guide should only be used to create virtual servers for local development.

I am currently using Ubuntu 11.04 (Natty Narwhal) but I am pretty sure the instructions are the same for other versions of Ubuntu. Other Linux distributions not based on Debian have a slightly different folder structure, but you should be able to adapt this guide easily.

<!--more-->

## Creating the configuration file

I am going to create a virtual host for ncona.dev. I generally use .dev on my development domains to distinguish them from real ones.

First thing we need to do is locate the apache folder. On Ubuntu it is:

```
/etc/apache
```

Inside that folder there is a folder that contains all our virtual hosts configurations, its name is **sites-available**. It is not mandatory to have your virtual hosts configurations each on a separate file, you could have them all in one file or all in httpd.conf, but this organization is comfortable for me.

If you see the content of sites-available you will probably see two files **default** and **default-ssl**. These are the default hosts configured on an Ubuntu machine when apache is installed. If you take a look at it you can see that it configures a virtual host with its root on **/var/www**.

I am going to create a new file on sites-available named ncona.dev. I like to name my configuration files as my domains, but you could name them however you want. There are a lot of options that can be configured on a virtual host, but I am just going to use the most important ones:

```xml
<VirtualHost *:80>
    ServerName ncona.dev
    ServerAlias www.ncona.dev
    DocumentRoot /home/adrian/www/ncona.dev
    <Directory /home/adrian/www/ncona.dev>
        Options FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>
```

The configuration file starts with a **VirtualHost** directive. Here you specify the IP address and port that this virtual host will listen to. I used `*:80`, this means that this host will respond to all calls to my web server on the 80 port. This is useful because I can access my server with my currently assigned IP address or with the loop-back address(127.0.0.1). You can also use the * wild card on the port number to listen to all ports or use an specific IP address.

**ServerName** is the name this virtual host targets, that means that if it receives a request for **ncona.dev** on any IP on the 80 port it will respond. **ServerAlias** allows you to specify other names for your virtual server, I usually add the same domain with www before it. **DocumentRoot** specifies the folder on which the files for this web host will be placed.

The **Directory** section allows us to configure certain rules that only apply to the specified directory. I usually add some common rules to my virtual hosts that I am going to explain.

**Options FollowSymLinks**. The **Options** keyword tells apache that I am going to list options that I want to apply to this directory. The only option I am using is **FollowSymLinks**, as its name implies it tells apache to follow symbolic links if they are found on the specified folder. **Indexes** and **MultiViews** are commonly used options that I don&#8217;t recommend, you should read about them before using them because they may have behaviors that you don&#8217;t really want.

**AllowOverride All** tells the server to read .htaccess files when found.

The next two lines are for access control. A lot of things can be done with combinations of this directive. The configurations I am using in this example allows unrestricted access, this is fine for local development.

## Activating the virtual host

The **sites-available** directory is the convention folder where apache saves its configurations files. But the really important folder is **sites-enabled**(this can be changed on httpd.conf), because here apache finds the virtual hosts that are currently enabled.

To enable our virtual host we are going to create a symbolic link to our new configuration file. You can do this by typing this command on a Linux terminal:

```
sudo ln -s /etc/apache2/sites-available/ncona.dev /etc/apache2/sites-enabled/ncona.dev
```

## Configuring hosts file

When developing locally you will probably don&#8217;t want to go through all the hassle of creating and configuring a DNS server. In this case you can just configure your **/etc/hosts** file so it knows to look in your computer when ncona.dev is typed on a browser. Here is the Content of my hosts file after adding ncona.dev:

```
127.0.0.1 localhost

127.0.0.1 ncona.dev www.ncona.dev

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

In line 3 I am telling my computer that every time ncona.dev or www.ncona.dev is requested it should look on 127.0.0.1. You could change the IP address to your current IP address or an IP address in other machine if the server is not in your current computer.

Now you should be able to type ncona.dev on your browser and you will see the content of your index file on /var/home/adrian/www/ncona.dev/. If this doesn&#8217;t work try restarting apache.
