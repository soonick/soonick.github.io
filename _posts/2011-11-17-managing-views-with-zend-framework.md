---
id: 448
title: Managing views with Zend Framework
date: 2011-11-17T02:16:28+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=448
permalink: /2011/11/managing-views-with-zend-framework/
tags:
  - php
  - zend_framework
---
## Zend Layout

Zend_Layout is the Zend Framework implementation of the composite view design pattern. It allows us to display default content for specific parts of a page (Menu, header, etc), and be able to display specific content for the current action.

In this article we assume the use of Zend_Application, we can check [Using Zend_Application for bootstraping](http://ncona.com/2011/10/using-zend_application-for-bootstrapping/) if necessary.

To start using Zend_Layout you have to add a line to the **application.ini** specifying the path of your layouts folder and another line to create a view resource. It should look something like this:

<!--more-->

```ini
[production]

; Error reporting
phpSettings.display_startup_errors = 0
phpSettings.display_errors = 0

; Paths
includePaths.library = APPLICATION_PATH "/../library"
bootstrap.path = APPLICATION_PATH "/Bootstrap.php"
resources.frontController.controllerDirectory = APPLICATION_PATH "/controllers"

; ------------- Layouts path
resources.layout.layoutPath = APPLICATION_PATH "/views/layouts"

; ------------- Empty view resource
resources.view[] =

[development : production]

; Error reporting
phpSettings.display_startup_errors = 1
phpSettings.display_errors = 1

[test : development]
```

We will also want to modify our Bootstrap class to initialize our view:

```php
<?php
class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
    protected function _initViewResource()
    {
        // Initialize view
        $this->bootstrap('view');
        $view = $this->getResource('view');

        // Set the doctype to XHTML1
        $this->view->doctype('XHTML1_STRICT');
    }
}
```

This is all the configuration we need for our layout to work. By default Zend will look for a file named layout.phtml in our layouts path, so we will need to create it:

```php
<?php
    // This will print the correct doctype string for the type we chose in
    // our bootstrap class
    echo $this->doctype().PHP_EOL;

    // This stylesheet will be added on the headLink() call below
    $this->headLink()->appendStylesheet('/styles/main.css');
?>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<?php
    // These view helpers will print the correct tags for meta data, title,
    // links (css) and scripts respectively
    echo $this->headTitle().PHP_EOL;
    echo $this->headMeta().PHP_EOL;
    echo $this->headLink().PHP_EOL;
    echo $this->headScript().PHP_EOL;
?>
</head>
<body>

<?php
    // Will render application/views/scripts/header.phtml
    echo $this->render("header.phtml");
?>

<div id="container">
<?php
    // Will render the content of the current action.
    // The content of the application/views/scripts/index/index.phtml for your
    // default action
    echo $this->layout()->content
?>
</div>
<?php
    // Will render application/views/scripts/footer.phtml
    echo $this->render("footer.phtml");
?>
</body>
</html>
```

This layout includes content from two static files header.phtml and footer.phtml as well as the content for your current action. We will keep our header and footer simple for now:

```html
<!-- header.phtml -->
<div>
    I am the header
</div>
```

```html
<!-- footer.phtml -->
<div>
    I am the footer
</div>
```

This is how our default controller could add content to the header of the layout:

```php
<?php
    $this->headTitle('Title for this action');
    $this->headMeta()->appendName('keywords', 'keywords, for, this, action');
    $this->headMeta()->appendName('description', 'Description of the action');
    $this->headLink()->appendStylesheet('/styles/controller_sheet.css');
    $this->headScript()->appendFile('/js/controller_script.js');
?>
<h1>My title</h1>
```

At this step we can run our application and we will get this page:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>Title for this action</title>
<meta name="keywords" content="keywords, for, this, action" />
<meta name="description" content="Description of the action" />
<link href="/styles/controller_sheet.css" media="screen" rel="stylesheet" type="text/css" />
<link href="/styles/main.css" media="screen" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/js/controller_script.js"></script>
</head>
<body>

<!-- header.phtml -->
<div>

    I am the header
</div>

<div id="container">
<h1>My title</h1>
</div>
<!-- footer.phtml -->
<div>
    I am the footer
</div>
</body>
</html>
```

## Switching layouts

There will be some occasions where we will want to use a layout different from the main one. When this case arrives we can use setLayout() to choose a different one. Here is an example of how a controller can choose a different layout.

application/views/layouts/different_layout.phtml

```php
<?php
    echo $this->doctype().PHP_EOL;
?>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<body>
<?php
    echo $this->layout()->content
?>
</body>
</html>
```

application/views/scripts/example/index.phtml

```php
<?php
    $this->layout()->setLayout('different_layout');
?>
I'm an example
```

This will give as a result:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<body>
I'm an example

</body>
</html>
```

## Creating custom view helpers

Writing our own view helpers is a simple task, but we have to follow some rules so they can play along nicely with Zend Framework:

&#8211; We must extend Zend\_View\_Helper_Abstract when creating our helpers
  
&#8211; The name of the class must start with the prefix specified on our configuration
  
&#8211; The name of the class must end with the helper name, using MixedCaps
  
&#8211; The class must have a public method that matches the helper name, using mixedCaps. This method is the one that will be called when your application calls your helper
  
&#8211; The class should not echo or print or otherwise generate output, instead, it should return values
  
&#8211; The returned values should be escaped appropriately
  
&#8211; The class must be in a file named after the helper class in the format: MixedCaps.php

We will apply all this rules when creating our example view helper, but we need to first tell application.ini where our helpers will live:

```ini
[production]

; Error reporting
phpSettings.display_startup_errors = 0
phpSettings.display_errors = 0

; Paths
includePaths.library = APPLICATION_PATH "/../library"
bootstrap.path = APPLICATION_PATH "/Bootstrap.php"
resources.frontController.controllerDirectory = APPLICATION_PATH "/controllers"

; Layouts path
resources.layout.layoutPath = APPLICATION_PATH "/views/layouts"

; -------- View helpers path
; -------- My_Application is the prefix we will use in our helpers
resources.view.helperPath.My_Application = APPLICATION_PATH "/views/helpers"

; Empty view resource
resources.view[] =

[development : production]

; Error reporting
phpSettings.display_startup_errors = 1
phpSettings.display_errors = 1

[test : development]
```

Following the rules mentioned above we will create a file named HelloWorld.php inside application/views/helpers/:

```php
<?php
// Class extends Zend_View_Helper_Abstract
// Class name starts with prefix specified in application.ini
// Class name ends with name of the helpers
class My_Application_HelloWorld extends Zend_View_Helper_Abstract
{
    // Method with name of the helper in mixedCase
    public function helloWorld()
    {
        // Don't echo
        // Return escaped content
        return htmlentities('Hello World!');
    }
}
```

Finally we can use our new view helper in any view file as we do with build in helpers:

```php
<h1>My page</h1>
<?php
    echo $this->helloWorld();
    echo $this->helloWorld();
?>
```
