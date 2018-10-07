---
id: 300
title: Parsing configuration files with Zend_Config_Ini
date: 2011-09-16T18:24:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=300
permalink: /2011/09/parsing-configuration-files-with-zend_config_ini/
categories:
  - PHP
tags:
  - php
  - zend framework
---
In most of the Internet applications there is a need to have a configuration file to store static information that the application needs to work. An very common example of this information is credentials to connect to a database.

There are a lot of ways you can store this information and make it accessible to the application. Zend framework includes four classes for parsing four different kind of configuration files: Zend\_Config\_Ini, Zend\_Config\_Json, Zend\_Config\_Xml and Zend\_Config\_Yaml. In this article we will focus on Zend\_Config\_Ini for parsing files in the INI format.

<!--more-->

## The INI format

The INI format allows us to have represent hierarchy using the dot (.) and sections between brackets ([]). This is an example of INI file:

```ini
[section 1]
property1 = val1
property2 = val2

; This is a comment
[section 2]
property3 = val3
index1.property4 = "value four"
```

There are some things to notice from the INI format:
  
&#8211; Semicolons (;) start comments
  
&#8211; Lines don&#8217;t need to be ended with semicolon (;). Since the semicolon starts a comment it doesn&#8217;t affect the line, but it shouldn&#8217;t be used unless it is a comment
  
&#8211; Strings don&#8217;t need to be wrapped in quotes (&#8220;) unless they contain special characters
  
&#8211; You can create hierarchy by using the dot (.) operator (index1.property4)
  
&#8211; You can divide your file into sections using brackets ([])

## Zend\_Config\_Ini

The way you parse an INI file with Zend\_Config\_Ini is by calling it&#8217;s constructor. This is the structure of the constructor:

```php
public function Zend_Config_Ini($filename, $section, $options = false)
```

Where

**$filename** &#8211; Path to file to load
  
**$section** &#8211; The section of the INI file to load (the name between brackets ([]). Setting this parameter to NULL will load all sections. An array of section names can be passed to load multiple sections
  
**$options** &#8211; Configuration array. It supports two options:
	  
**allowModifications** &#8211; If true the returned object can be modified
	  
**nestSeparator** &#8211; Sets character to be used to separate hierarchies. By default it is the dot (.)

Zend\_Config\_Ini uses parse\_ini\_file() to parse the files, so you may want to read the documentation of that function if you find any weird behavior.

Zend\_Config\_Ini allows a section to inherit from another section using a colon (:):

```ini
[section2 : section1]
```

In the previous example section2 inherits from section1. We will see the usefulness of this in our next example.

## Example

One of the most common uses of a configuration file is to load database credentials. This also allows us to make a good use of sections by having two different sections, one for development and another for production. Lets use this INI file as our base:

```ini
[general]
database.user   = user
database.name   = name

[production : general]
database.host   = dbhost.com
database.user   = differentuser
database.pass   = verysecret

[development : general]
database.host   = devdbhost.com
database.pass   = secret
```

In this example both production and development inherit the database name and user from general, but production overwrites the user with one of its own.

If we were going to run our application in the development environment we would do something like this:

```php
$config = new Zend_Config_Ini('/path/to/config.ini', 'development');
```

Then we could access our configuration data from the $config object like this:

```php
$config->database->host; // devdbhost
$config->database->user; // user
$config->database->pass; // secret
$config->database->name; // name
```

We can see that parsing an INI file with Zend\_Config\_Ini is very easy.

## Iterating a configuration file

Zend_Config extends the iterator interface, which allows us to treat the parsed configuration object as an array. This can be useful if you want to have an infinite number of something but you don&#8217;t know how many. For example

```ini
[general]
things.thing1 = onething
things.thing2 = anotherthing
things.thing3 = onemore
```

After parsing this configuration file you could print all three things using a foreach loop:

```php
foreach ($config->things as $t)
{
    echo $t.'<br>';
}
```
