---
id: 416
title: Test driven development with Zend Framework
date: 2011-11-09T16:50:52+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=416
permalink: /2011/11/test-driven-development-with-zend-framework/
tags:
  - php
  - testing
  - zend_framework
---
Test Driven Development (TDD) is a software development process that consist in writing unit tests for functionality that is going to be needed and once the test fails writing the code to make it pass. This process is repeated for every new feature or bug.

The most used tool for running unit tests for PHP applications is PHPUnit and is the one we are going to use. We are not going to go through the process of installation in this article.

## Organizing tests

We will start by creating a folder for our tests. We probably already have a **tests** folder in our application root. If we didn&#8217;t have it we would have to create it. Inside that folder we are going to create two folders called **models** and **controllers**.

Our main suite will allow us to run all our tests with only one command. To create this suite we will create a file **TestsSuites.php** in our tests folder. This file will allow us to run all our application tests.

<!--more-->

We also want to be able to run all our models and controllers tests independently so we will create a test suite for each folder. Models\_TestsSuite.php will go in our tests/models folder and Controllers\_TestsSuite.php will go in our tests/controllers folder.

We will leave these files in there for now, but we will go back to them when we learn how to test models and controllers.

## Testing models

Lets create a file called **DummyTest.php** into our tests/models folder and add this content to it:

```php
<?php

require_once '../../application/models/Dummy.php';

class Models_DummyTest extends PHPUnit_Framework_TestCase
{
    // An instance of the class to test
    private $instance;

    public function setUp()
    {
        // Create the instance
        $this->instance = new Dummy();
    }

    public function testadd()
    {
        $this->assertSame(3, $this->instance->add(1, 2),
                'Two parameters are added');
    }
}
```

We have created our first test class and we can run it by going to our tests/models folder from a terminal and typing this command:

```
phpunit DummyTest.php
```

The next thing we will notice is that the test throws an error. Now we are doing TDD.

To make the test pass we would have to create a class named **Dummy.php** in our application/models folder with an **add** method. Something like this:

```php
<?php

class Dummy
{
    public function add($var1, $var2)
    {
        return $var1 + $var2;
    }
}
```

We can try to run the test again and it should pass now. We should create a new test class for every model we want to create, one or more tests for each method, and as many assertions as necessary.

Now we will create a tests suite for all our models using our previously created Models_TestsSuite.php file:

```php
<?php

// Each of the tests classes files
require_once 'DummyTest.php';

class Models_TestsSuite extends PHPUnit_Framework_TestSuite
{
    public static function suite()
    {
        $suite = new Models_TestsSuite('All Models');

        // Each of the tests classes names
        $suite->addTestSuite('Models_DummyTest');

        return $suite;
    }
}
```

And we can run the models suite with the following command:

```
phpunit Models_TestsSuite.php
```

## Testing controllers

Testing controllers is a little trickier than testing models. This is because for testing controllers we need to set up the Zend environment in order for the controller to go through all it&#8217;s life cycle before it starts to run the tests.

We are going to assume Zend_Application is being used for this application and that it is already set up correctly. You can take a look at [Zend Framework Hello world](http://ncona.com/2011/05/zend-framework-hello-world/) and [Bootstrapping using Zend_Application](http://ncona.com/2011/10/using-zend_application-for-bootstrapping/) for details on how to start a Zend application.

We are going to start by creating a bootstrap class for our controllers&#8217; tests. We are going to create a file in our tests/controllers folder named BaseControllerTestCase.php:

```php
<?php

define('APPLICATION_ENV', 'test');
define('DOCUMENTROOT_PATH', realpath(dirname(__FILE__).'/../..'));
define('APPLICATION_PATH', DOCUMENTROOT_PATH.'/application');
define('LIB_PATH', DOCUMENTROOT_PATH.'/library');

set_include_path(
    get_include_path().PATH_SEPARATOR.LIB_PATH
);

require_once '/Zend/Test/PHPUnit/ControllerTestCase.php';
require_once '/Zend/Application.php';

abstract class BaseControllerTestCase extends Zend_Test_PHPUnit_ControllerTestCase
{
    protected $application;

    public function setUp()
    {
        $this->bootstrap = array($this, 'appBootstrap');
        return parent::setUp();
    }

    public function appBootstrap()
    {
        date_default_timezone_set('UTC');
        $this->application = new Zend_Application(
            APPLICATION_ENV, APPLICATION_PATH.'/configs/application.ini'
        );

        $this->application->bootstrap();
        $bootstrap = $this->application->getBootstrap();
        $front = $bootstrap->getResource('FrontController');
        $front->setParam('bootstrap', $bootstrap);
    }
}
```

This class is going to serve as a base for all our controller tests. That means that every new controller we want to test will need to extend this class.

Lets create now a test file for our index controller. Lets call it IndexControllerTest.php:

```php
<?php

require_once 'BaseControllerTestCase.php';

class IndexControllerTest extends BaseControllerTestCase
{
    function testDispatchWorksCorrectly()
    {
        $this->dispatch('/');
        $this->assertFalse($this->response->isException(),
                'Dispatching index does not throw an exception');
        $this->assertNotRedirect('This action is not a redirec');
        $this->assertController('index', 'Dispatch index controller');
        $this->assertAction('index', 'Dispatch index action');
    }

    function testContentIsCorrect()
    {
        $this->dispatch('/');
        $this->assertQueryContentContains('h1', 'Hello World!',
                'There is one h1 tag that contains "Hello World!"');
    }
}
```

A lot of the assertions used on this example are not part of PHPUnit, but they are extensions added by Zend Framework that can be very useful for advanced testing cases. The controller I am testing in this previous file is the index model created on my previous [Zend Hello World](http://ncona.com/2011/05/zend-framework-hello-world/) example.

Now lets create a test suite for our controllers. tests/controllers/Controllers_TestSuite.php will look like this:

```php
<?php

require_once 'IndexControllerTest.php';

class Controllers_TestsSuite extends PHPUnit_Framework_TestSuite
{
    public static function suite()
    {
        $suite = new Controllers_TestsSuite('All Controllers');

        $suite->addTestSuite('IndexControllerTest');

        return $suite;
    }
}
```

## The main suite

Finally we want to create our main suite that will allow us to run all tests with just one command. Our tests/TestSuite.php will look like this:

```php
<?php

require_once 'controllers/Controllers_TestSuite.php';
require_once 'controllers/Models_TestSuite.php';

class TestsSuite extends PHPUnit_Framework_TestSuite
{
    public static function suite()
    {
        $suite = new TestsSuite('All Tests');

        $suite->addTestSuite('Controllers_TestsSuite');
        $suite->addTestSuite('Models_TestsSuite');

        return $suite;
    }
}
```

At the end you can just go to your test folder from a terminal and run this command:

```
phpunit TestsSuite.php
```
