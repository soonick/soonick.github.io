---
id: 829
title: "Making an object's protected and private members public using reflection"
date: 2012-09-22T14:55:31+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=829
permalink: /2012/09/making-an-objects-protected-and-private-members-public-using-reflection/
tags:
  - design_patterns
  - php
  - programming
---
This is a very special scenario and you may never want to really do this, but I found myself in the necessity of changing the visibility of an object&#8217;s methods an attributes at runtime so I could access them directly.

To do this I had to use reflection and magic methods in a magic way. Since we can&#8217;t just plug methods to an object in PHP, I had to create a class with already defined magic methods that would allow me to access the protected and private members of an object using reflection.

This is the class I created with an explanation of what it does:

<!--more-->

```php
<?php

class PublicObject
{
    /**
     * Object in which we'll call methods, get and set attributes
     * @var object
     */
    protected $_object;

    /**
     * Exposed properties of the object
     * @var array
     */
    protected $_properties;

    /**
     * Exposed methods of the object
     * @var array
     */
    protected $_methods;

    /**
     * Make non-public members of the given object accessible
     *
     * @param object $object.- Object which members we'll make accessible
     */
    public function __construct($object)
    {
        // Save the object so we can later call methods and access attributes
        $this->_object = $object;

        // Get a reflected version of the object
        $reflected = new ReflectionObject($this->_object);

        // Get all private and protected properties of the object
        $this->_properties = array();
        $properties = $reflected->getProperties(
            ReflectionProperty::IS_PROTECTED | ReflectionProperty::IS_PRIVATE
        );

        // Loop all the properties, make them accessible and save them for
        // later reference
        foreach ($properties as $property) {
            $property->setAccessible(true);
            $this->_properties[$property->getName()] = $property;
        }

        // Get all private and protected methods of the object
        $this->_methods = array();
        $methods = $reflected->getMethods(
            ReflectionProperty::IS_PROTECTED | ReflectionProperty::IS_PRIVATE
        );

        // Loop all the methods, make them accessible and save them for
        // later reference
        foreach ($methods as $method) {
            $method->setAccessible(true);
            $this->_methods[$method->getName()] = $method;
        }
    }

    /**
     * Returns a property of $this->_object
     *
     * @param string $name
     *
     * @return mixed
     */
    public function __get($name)
    {
        // If the property is exposed (with reflection) then we use getValue()
        // to access it, else we access it directly
        if (isset($this->_properties[$name])) {
            return $this->_properties[$name]->getValue($this->_object);
        } else {
            return $this->_object->$name;
        }
    }

    /**
     * Sets a property of this->_object
     *
     * @param  string  $name
     * @param  mixed  $value
     */
    public function __set($name, $value)
    {
        // If the property is exposed (with reflection) then we use setValue()
        // to access it, else we access it directly
        if (isset($this->_properties[$name])) {
            $this->_properties[$name]->setValue($this->_object, $value);
        } else {
            $this->_object->$name = $value;
        }
    }

    /**
     * Calls a method of this->_object
     *
     * @param string $name
     * @param array $args
     *
     * @return  mixed
     */
    public function __call($name, $args)
    {
        // If the method is exposed (with reflection) then we use invokeArgs()
        // to call it, else we use call_user_func_array
        if (isset($this->_methods[$name])) {
            return $this->_methods[$name]->invokeArgs($this->_object, $args);
        } else {
            return call_user_func_array(array($this->_object, $name), $args);
        }
    }
}
```

And this is an example of how to use it:

```php
include 'PublicObject.php';

class PrivateClass
{
    private $_value;

    private function _getValue()
    {
        return $this->_value;
    }
}

$a = new PrivateClass();
$a = new PublicObject($a);
$a->_value = 6;

// This will print 6
echo $a->_getValue();
```
