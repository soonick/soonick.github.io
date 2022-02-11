---
id: 387
title: Using Zend_Application for bootstrapping
date: 2011-10-13T01:37:40+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=387
permalink: /2011/10/using-zend_application-for-bootstrapping/
tags:
  - php
  - zend_framework
---
Zend_Application is a class that provides an easy to use bootstrapping facility for your application. It also takes care of setting up the PHP environment and introduces autoloading by default.

Zend_Application requires a config file to work, so the first thing we need to do is create it. We will create the configuration file application/configs/application.ini with this content:

```ini
[production]

; Error reporting
phpSettings.display_startup_errors = 0
phpSettings.display_errors = 0

; Paths
includePaths.library = APPLICATION_PATH "/../library"
bootstrap.path = APPLICATION_PATH "/Bootstrap.php"
resources.frontController.controllerDirectory = APPLICATION_PATH "/controllers"

[development : production]

; Error reporting
phpSettings.display_startup_errors = 1
phpSettings.display_errors = 1
```

<!--more-->


An explanation of what each of these option do can be found at the [Zend documentation](http://framework.zend.com/manual/en/zend.application.core-functionality.html).

We will also need to create a file named Bootstrap.php in our application folder. This file needs to have a Bootstrap class that extends Zend\_Application\_Bootstrap_Bootstrap:

```php
<?php

class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
}
```

Although this class is empty, Zend\_application\_Bootstrap\_Bootstrap will run and dispatch the front controller by default. If we wanted to add more custom configuration specific to our application we would do it by adding resource methods. Resource methods are any protected methods beginning with \_init that belong to this class. By default when your application is bootstrapped all resource methods will be run unless specifically telling it to do something different.

Lastly we need to modify our index.php file in our public directory to look like this:

```php
<?php

// Define path to application directory
defined('APPLICATION_PATH')
        || define('APPLICATION_PATH', realpath(dirname(__FILE__)
        .'/../application'));

// Define application environment
defined('APPLICATION_ENV')
        || define('APPLICATION_ENV', (getenv('APPLICATION_ENV')
        ? getenv('APPLICATION_ENV') : 'production'));

// Add library directory to include path
set_include_path(
    implode(
        PATH_SEPARATOR,
        array (
            dirname(dirname(__FILE__)).'/library',
            get_include_path(),
        )
    )
);

// Create application, bootstrap, and run
require_once 'Zend/Application.php';
$application = new Zend_Application(
    APPLICATION_ENV,
    APPLICATION_PATH.'/configs/application.ini'
);
$application->bootstrap()->run();
```

To this point our application will run and dispatch our front controller properly. Now we are going to add resource methods to our bootstrap class to add custom functionality.

We are going to add two resource methods to our Bootstrap class, one for connecting to the database and another for initializing the registry with some information (This is just an example to explain how resource methods work. There is no real reason to create different methods if you don&#8217;t think you will need to call them separately sometime):

```php
<?php

class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
    protected function _initDatabase()
    {
        // We are hardcoding the parameters in here just to show how to bootstrap
        // in the real world you would use a config file to hold the db parameters
        $db = Zend_Db::factory(
            'Pdo_Mysql',
            array (
                'host'     => '127.0.0.1',
                'username' => 'user',
                'password' => 'pass',
                'dbname'   => 'db'
            )
        );
        Zend_Registry::set('db', $db);
    }

    protected function _initRegistry()
    {
        Zend_Registry::set('key', 'value');
        Zend_Registry::set('key2', 'value2');
    }
}
```

In our main file example above we used

```php
$application->bootstrap()->run();
```

To bootstrap and run our application. This will run all our resource methods one after the other in the order they are found. If you wanted to run just one resource method you could do this:

```php
$application->bootstrap('database')->run();
```

To only call the \_initDatabase method and not \_initRegistry.

If you want to call more than one method you can also send an array this way:

```php
$application->bootstrap(array ('database', 'registry'))->run();
```
