---
id: 3122
title: Introduction to PIP
date: 2015-08-19T19:01:48+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3122
permalink: /2015/08/introduction-to-pip/
tags:
  - programming
  - python
---
PIP(PIP Installs Packages) is Python&#8217;s recommended tool for package managing. Most modern operating systems come with Python and PIP installed. You can check if Python and PIP are installed using the which command:

```
which pip
which python
```

If PIP is not installed you can [follow the documentation to install it](https://pip.pypa.io/en/stable/installing.html).

<!--more-->

## Basic usage

By default PIP will look for packages in [Python&#8217;s Package Index](https://pypi.python.org/pypi/). You can search for packages from the command line:

```
pip search flask
```

Installing them is also straight forward:

```
sudo pip install flask
```

Depending on your configuration you might not need to use sudo. Try not using it first and if it doesn&#8217;t work then add sudo.

You can see detailed information about what was installed by using pip show:

```
pip show --files flask
```

If you are curious about what packages are currently installed on your system you can use pip list:

```
pip list
```

Finally, if flask bores you, you can uninstall it:

```
sudo pip uninstall flask
```

## Requirements file

If you have a project with multiple dependencies it would be inefficient to run pip install for each of the dependencies. For this reason PIP allows you to specify dependencies in a file called requirements.txt. In this file you can specify a list of dependencies as you would pass them to pip install. Here is an example of a very simple requirements.txt file:

```
# This is a comment
flask
flask-redistore
```

To install the dependencies from the file:

```
pip install -r requirements.txt
```

There are two things you should keep in mind to make the use of requirements.txt safer:
  
1 &#8211; All dependencies specify a specific version number.
  
2 &#8211; Use &#8211;no-deps when running pip install. This way you are sure that you explicitly specified all your dependencies.

## Freeze

You can have a requirements.txt file automatically generated for you by using pip freeze:

```
pip freeze > requirements.txt
```

This will generate a file called requirements.txt with all the packages and versions currently installed on your system. This is a safe way to reproduce the current environment but might include packages you don&#8217;t really need for your application.

## Constraints

A constraints file allows you to specify a version of a package you want to install, but it does not install it. This is useful when for some reason you need to fork a package and you want to use your fork every time you depend on the package. To read the constraints file just do:

```
pip install -c constraints.txt
```

PIP has some advanced functionality that allow you to solve dependency conflicts that you might find in the wild. Hopefully you will never need the advanced functionality, but if you do, be relieved that the solution might be in the documentation.
