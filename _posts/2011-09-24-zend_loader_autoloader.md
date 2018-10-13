---
id: 378
title: Zend_Loader_Autoloader
date: 2011-09-24T00:51:55+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=378
permalink: /2011/09/zend_loader_autoloader/
categories:
  - PHP
tags:
  - php
  - zend framework
---
This class allows lazy loading of classes upon request. This will in place prevent you from having to manually include the files that you will need in your application.

To use the autoloader you have to first include the file and then create an instance of it. This will usually be done in your bootstrapping class.

```php
require_once 'Zend/Loader/Autoloader.php';
$autoloader = Zend_Loader_Autoloader::getInstance();
```

Once your autoloader is ready you can use any class you need without having to manually include the file it belongs to. For example, if after calling autoloader you had this line of code:

```php
$frontController = Zend_Controller_Front::getInstance();
```

Zend framework will replace underscores (\_) with directory separators (/) and look for the file Zend/Controller/Front in your include path(get\_include_path()), if the file is found it will be loaded, if it is not found an error will be issued.

<!--more-->
