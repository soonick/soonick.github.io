---
id: 748
title: Setting environment variables
date: 2012-07-26T02:29:59+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=748
permalink: /2012/07/setting-environment-variables/
categories:
  - PHP
tags:
  - apache
  - php
  - programming
  - virtual host
---
It is often necessary to differentiate different environments by setting an environment variable with a different value on each of your different systems (development, qa, production). This is very easy to achieve if you are using Apache and PHP. You just need to modify your virtual host definition (See: [Creating local virtual hosts with apache](http://ncona.com/2011/06/creating-local-virtual-hosts-with-apache/ "Creating local virtual hosts in apache")) to include a SetEnv directive:

```xml
<VirtualHost *:80>
    ServerName ncona.dev
    ServerAlias www.ncona.dev
    SetEnv APPLICATION_ENV development
    DocumentRoot /home/adrian/www/ncona.dev
    <Directory /home/adrian/www/ncona.dev>
        Options FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>
```

Now you have access to the environment variable from php:

```php
getenv('APPLICATION_ENV');
```
