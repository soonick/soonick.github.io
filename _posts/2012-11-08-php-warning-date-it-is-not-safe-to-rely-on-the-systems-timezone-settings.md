---
id: 917
title: "PHP Warning:  date(): It is not safe to rely on the system's timezone settings"
date: 2012-11-08T00:51:47+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=917
permalink: /2012/11/php-warning-date-it-is-not-safe-to-rely-on-the-systems-timezone-settings/
categories:
  - PHP
tags:
  - apache
  - error messages
  - linux
  - php
---
When you get this error the only thing you need to do is add a line similar to this one to your php.ini file:

```
date.timezone = "America/Mexico_City"
```

You can get a list of the supported timezones on this URL: <http://php.net/manual/en/timezones.php>. The error should go away after you restart apache.

For Linux systems there are some times two php.ini files, one for apache and one for CLI. Make sure you add the line to both files.
