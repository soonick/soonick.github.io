---
id: 350
title: "Dealing with Apache's limit on back-references when rewriting URLs"
date: 2011-08-27T00:55:16+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=350
permalink: /2011/08/dealing-with-apaches-limit-on-back-references-when-rewriting-urls/
categories:
  - PHP
tags:
  - apache
  - linux
  - php
---
For the ones of you who didn&#8217;t know (I didn&#8217;t know either), Apache has a limit on the number of back references you can use when rewriting a URL.

For the people who don&#8217;t know I will explain what is a back reference when talking about apache rewrites.

When you do a rewrite of a URL using apache mod_rewrite you translate a URL into an actual resource that apache can find.

For my examples I will use the domain http://ncona.com. If I wanted that the URL http://ncona.com/file loaded the file other_file.html located in my web root I would use a rule like this one:

```
RewriteRule ^file$ /other_file.php
```

That is a static rewrite but you can also use back reference to make dynamic URLs:

```
RewriteRule ^product/([0-9]+)$ /product_details.php?id=$1
```

<!--more-->

This rewrite uses a back reference. Whatever text is between parenthesis in the left is going to replace the $1 in the right. It is $1 because it is the first back reference, If you had a second one you would use $2. So for this example if someone requested http://ncona.com/product/45 that request would be translated to http://ncona.com/product_details.php?id=45.

As you can see this technique is generally used to make URLs more readable.

## The limit

The limit that Apache enforces for back references is **9**. This limit is hard in that it can not be modified through configuration files. Luckily there are very simple ways to walk around this problem.

Lets see what happens if we try to use more than 9 back references:

```
# I added line breaks to make it more readable but they are not allowed in an Apache configuration file
RewriteRule
^something/([a-z]+)/([a-z]+)/([a-z]+)/([a-z]+)/([a-z]+)/([a-z]+)/([a-z]+)/([a-z]+)/([a-z]+)/([a-z]+)$
/some_script.php?a=$1&b=$2&c=$3&d=4&e=5&f=6&g=7&h=8&i=9&j=10
```

If someone requested http://ncona.com/something/one/two/three/four/five/six/seven/eight/nine/ten this is what it would be translated to:

```
http://ncona.com/some_script.php?a=one&b=two&c=three&d=four&e=five&f=six&g=seven&h=eight&i=nine&j=one0
```

You can see that the **j** variable in the query string has the value one0. This is because Apache understands $10 as the first back reference found and then a 0 after that, it only uses one digit for the back reference.

## The walk around in PHP

The way I found to walk around this problem is by using a mixture of mod_rewrites and the programming language I was using.

Using the previous example, I would modify the rewrite rule like this:

```
RewriteRule ^something/([.]+)$ /some_script.php?query=$1 
```

This rule would match every request that starts with http://ncona.com/something/ and send it to the script some_script.php in my document root.

Now you can get the parameters from the query string with simple PHP code:

```php
<?php
$parameters = explode('/', $_GET['query']);
```

Now you have all the passed parameters in the $parameters variable and you can use them in your code however you prefer.

It is worth mentioning that this is like any other GET request and can be very easily tampered with, so be sure to verify that the parameters are safe before you use them
