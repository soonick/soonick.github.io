---
id: 189
title: Zend Framework Hello World
date: 2011-05-30T21:01:55+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=189
permalink: /2011/05/zend-framework-hello-world/
categories:
  - PHP
tags:
  - php
  - zend framework
---
I am going to explain how to make a very simple hello world application using Zend Framework. While doing this I am going to try to explain how Zend Framework manages MVC.

## Folder structure

Zend Framework uses the Front Controller pattern on its implementation of MVC. This means that all calls to your website are managed by one file and this files routes to a correct controller based on the URL of the call.

For this example we are going to create a folder for our application: /home/adrian/www/hello. Inside that folder we need to create three folders: application, library and public.

<!--more-->

application: This folder usually contains three folders: controllers, models and views. These folders contain your application&#8217;s controllers, models and views respectively.

library: This folder contains all the external components that your application needs to function. One of these external components is the Zend Framework itself.

public: This is the public folder our web server should point to. This folder will contain our index file as well as all our images, CSS files and JavaScript files.

This is how our folder structure looks like:

```
hello
|--- application
|    |--- controllers
|    |--- models
|    |--- views
|--- library
|    |--- Zend
|--- public
```

We can download the Zend Framework from http://framework.zend.com/. For this example we are going to download the full package but the minimal package should also work. Decompress it and put the files inside library/Zend. Now we should have a file named Loader.php on our Zend folder along other files and folders.

We also need to create a virtual server pointing to our public directory so it is the only one that can be accessed from the outside. Make sure that modrewrite is installed, because we are going to use it in our .htacess file.

## The files

The first file that we are going to create is .htaccess, this file lets us configure apache in many ways, this time we are going to use it to direct all calls to index.php.

```
# We are going to use rewrite rules
RewriteEngine on

# If the requested file does not exist, redirect the request to index.php
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule .* index.php
```

This is a very simple .htacess file, it tries to get the requested file, and if it doesn&#8217;t exist then directs the request to index.php. Lets look at what index.php does:

```
<?php

// Zend Framework expects the library directory to be in the path, so we add it
$rootDir = dirname(dirname(__FILE__));
set_include_path($rootDir.'/library'.PATH_SEPARATOR.get_include_path());

// Zend Loader loads classes dynamically. Underscores are converted to directory
// separators and then includes the file
require_once 'Zend/Loader.php';

// This call looks for Zend/Controller/Front.php
Zend_Loader::loadClass('Zend_Controller_Front');

// The front controller implements the singleton design pattern so there is only
// one instance of the front controller at a time
$frontController = Zend_Controller_Front::getInstance();

// Tell the front controller where to look for controllers
$frontController->setControllerDirectory('../application/controllers');

// Sends the request to the correct controller based on the requested URL
$frontController->dispatch();
```

The comments cover almost everything our index file does. I just want to explain in more detail which controller is called based on the requested URL.

The front controller by default directs a request based on the construction of the URL, something like this:

```
http://myexample.dev/CONTROLLER/ACTION
```

CONTROLLER and ACTION determine the controller that is going to be executed and the action within that controller. If any or all of them is not provided, &#8220;index&#8221; is used.

With that being said, if someone requested http://myexample.dev our front controller would look for a file named IndexController.php on our controllers directory. Notice that Index starts with a capital letter, this is necessary for the file to be found. Inside IndexController.php we should have a class named IndexController that extends Zend\_Controller\_Action, and a method called indexAction that is going to be executed when no action is provided. Notice that the first letter of index here is lower case.

Here are other examples:

```
<strong>Requested URL:</strong> http://myexample.dev/page
<strong>Controller file:</strong> PageController.php
<strong>Class name:</strong> PageController
<strong>Method name:</strong> indexAction

<strong>Requested URL:</strong> http://myexample.dev/catalog/secion
<strong>Controller file:</strong> CatalogController.php
<strong>Class name:</strong> CatalogController
<strong>Method name:</strong> sectionAction
```

Now we can proceed to create our default controller and action. We need to create a file named IndexController.php on our application/controllers directory:

```
<!--?php class IndexController extends Zend_Controller_Action { 	public function indexAction() 	{ 		$this---><?php

class IndexController extends Zend_Controller_Action
{
    public function indexAction()
    {
        $this->view->assign('title', 'Hello World!');
    }
}
```

All our controllers should extend Zend\_Action\_Controller by doing this we can use hooks to execute function before actions are executed. Extending Zend\_Controller\_Action also allows us to pass values to the view using the assign function. In the example above we pass the value &#8216;Hello World!&#8217; to the &#8216;title&#8217; attribute of the view.

View scripts are assumed to be inside views/scripts folder. Inside that folder another folder with the name of the controller should be created, and inside that one all the actions for that controller. The extension .phtml is expected by default for the views. For our indexAction we have to create: application/views/scripts/index/index.phtml. Index is the name of the default controller and index is also the name of the default action. This is its content for our example:

```
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhmtl">
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><?php echo $this->escape($this->title); ?></title>
</head>
<body>
    <h1><?php echo $this->escape($this->title); ?></h1>
</body>
</html>
```

In the view we can use $this to access all the variables assigned on the controller. In the example above we use $this->title to access the value we assigned on our controller. We also use the escape helper function to make sure that our string is safe from XSS code.

That is all we need for out hello world application on Zend Framework. This is how our directory structure looks at the end:

```
hello
|--- application
|    |--- controllers
|    |    |--- IndexController.php 
|    |--- models
|    |--- views
|         |--- scripts
|              |--- index
|                   |--- index.phtml
|--- library
|    |--- Zend
|         |--- (All Zend Framework files)
|--- public
     |--- .htaccess
     |--- index.php
```
