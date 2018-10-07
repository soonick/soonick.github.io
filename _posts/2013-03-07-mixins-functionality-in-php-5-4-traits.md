---
id: 790
title: 'Mixins functionality in PHP 5.4 &#8211; Traits'
date: 2013-03-07T03:54:49+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=790
permalink: /2013/03/mixins-functionality-in-php-5-4-traits/
categories:
  - PHP
tags:
  - design patterns
  - php
  - programming
  - traits
---
PHP 5.4 introduced a technique called traits. This technique aims to provide code re-usability functionality similar to mixins in other programming languages. The most common use case is to reuse methods among different classes.

Here is an example of the syntax;

```php
trait someMath
{
    function add($a, $b)
    {
        return $a + $b;
    }

    function multiply($a, $b)
    {
        return $a * $b;
    }
}

class Calculator
{
    use someMath;
}

$cal = new Calculator();
echo $cal->add(4, 6); // echoes 10
```

As you can see traits syntax is very similar to the syntax to create a class. We just need to change the keyword class for **trait**. Then we can apply the trait inside a class using the **use** keyword.

<!--more-->

## Precedence

Method collisions are resolved in this order of precedence:

  * Defined on the class
  * Defined on trait
  * Defined on parent class

The topmost in the list is the method that will be used when called from an instance. Lets see an example:

```php
trait someMath
{
    function add($a, $b)
    {
        return $a + $b;
    }

    function multiply($a, $b)
    {
        return $a * $b;
    }
}

class Calculator
{
    function subtract($a, $b)
    {
        return $a - $b;
    }

    function multiply($a, $b)
    {
        return $a * $b * 100;
    }
}

class BrokenCalculator extends Calculator
{
    use someMath;

    function add($a, $b)
    {
        return 9;
    }
}

$cal = new BrokenCalculator();
echo $cal->add(4, 6); // echoes 9
echo $cal->multiply(2, 2); // echoes 4
echo $cal->subtract(5, 3); // echoes 2
```

You can do a lot more cool things with traits, but there is no use on duplicating what is already well documented. You can see more use cases here: [PHP Manual: Traits](http://php.net/manual/en/language.oop5.traits.php)
