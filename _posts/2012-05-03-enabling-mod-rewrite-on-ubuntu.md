---
id: 633
title: Enabling mod-rewrite on Ubuntu
date: 2012-05-03T03:12:27+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=633
permalink: /2012/05/enabling-mod-rewrite-on-ubuntu/
tags:
  - apache
  - linux
  - virtual_host
---
I recently reinstalled the operating system on my computer and thus had to re-install all my applications and development environments.

While I was configuring my web environments I was getting some weird errors when I was trying to access one of my local sites. The error wasn&#8217;t really descriptive of the problem, but looking at the error logs I found this:

```
/home/adrian/www/site.dev/.htaccess Invalid command 'RewriteEngine' perhaps misspelled ...
```

At first it was a little confusing, because I know that RewriteEngine is a valid command, but then I remembered that it is included by the mod-rewrite module that doesn&#8217;t come by default with apache. Installing it on Ubuntu is very easy, you just need to input this command on a terminal:

```
sudo a2enmod rewrite
```

And you will need to restart apache for the changes to take effect:

```
sudo /etc/init.d/apache2 restart
```

Now RewriteEngine is a recognized command for your .htaccess files.

<!--more-->
