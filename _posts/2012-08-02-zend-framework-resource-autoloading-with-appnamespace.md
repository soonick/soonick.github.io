---
id: 763
title: Zend Framework resource autoloading with appnamespace
date: 2012-08-02T01:19:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=763
permalink: /2012/08/zend-framework-resource-autoloading-with-appnamespace/
categories:
  - PHP
tags:
  - bootstrapping
  - php
  - programming
  - zend framework
---
A few days ago I was having problems getting my models autoloaded by Zend Framewok, after a little research I found the solution.

For this project I am using Zend\_Application and Zend\_Application\_Bootstrap\_Bootstrap for bootstraping my application. Enabling autoloading is as simple as adding this line to application.ini:

```
appnamespace = "Application"
```

or you could add a $_appNamespace property to your bootstrap class:

```php
class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
    protected $_appNamespace = 'Application';
}
```

<!--more-->

After enabling this namespace some mappings will be created that will allow Zend Framework to autoload your classes correctly. This is a list of the folders the class names prefix and where Zend Framework wil attempt to find that class

| If your class starts with | Zend Framework expects to find it in |
|---------------------------|--------------------------------------|
| Application_Form | application/forms/ |
| Application_Model | application/models/ |
| Application_Model_DbTable | application/models/DbTable |
| Application_Model_Mapper | application/models/mappers/ |
| Application_Plugin | application/plugins/ |
| Application_Service | application/services/ |
| Zend_View_Helper | application/views/helpers/ |
| Application_View_Filter | application/views/filters/ |
