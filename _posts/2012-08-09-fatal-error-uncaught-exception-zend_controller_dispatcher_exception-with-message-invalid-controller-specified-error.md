---
id: 759
title: "Fatal error: Uncaught exception 'Zend_Controller_Dispatcher_Exception' with message 'Invalid controller specified (error)'"
date: 2012-08-09T00:04:25+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=759
permalink: /2012/08/fatal-error-uncaught-exception-zend_controller_dispatcher_exception-with-message-invalid-controller-specified-error/
tags:
  - bootstrapping
  - php
  - programming
  - zend_framework
---
By default Zend Framework has a front controller plugin that tries to send all exceptions and errors to a controller named ErrorController. If that controller is not found you will get this error.

The Zend Documentation explains how to make a simple error handler:

```php
class ErrorController extends Zend_Controller_Action
{
    public function errorAction()
    {
        $errors = $this->_getParam('error_handler');
        $exception = $errors->exception;
        $log = new Zend_Log(
            new Zend_Log_Writer_Stream(
                '/tmp/applicationException.log'
            )
        );
        $log->debug($exception->getMessage() . "\n" .
                $exception->getTraceAsString());
    }
}
```

<!--more-->

This simple error handler will log all your errors into **/tmp/applicationException.log**. You can look at the Zend Framework documentation to learn how to handle different error scenarios based on the content of the $errors variable.

You will also need to create the respective view file for this controller. The default location for it will be:  **project/views/scripts/error/error.phtml**
