---
id: 951
title: Setting up a Django work environment
date: 2012-11-21T15:37:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=951
permalink: /2012/11/setting-up-a-django-work-environment/
tags:
  - apache
  - programming
  - python
---
In my journey to learn python, the next step is to learn Django. Django is a web framework powered by python, so to use it we need to make sure we have python installed:

```
adrian@my-xubuntu:~$ python -V
Python 2.7.3
```

Now we can go ahead and install the Django package

```
sudo apt-get install python-django
```

That installation makes Django automatically available to python, so you can do something like this:

```
adrian@my-xubuntu:~$ python
Python 2.7.3 (default, Sep 26 2012, 21:51:14)
[GCC 4.7.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import django
>>> django.VERSION
(1, 4, 1, 'final', 0)
```

<!--more-->

In case you are curious you can find the Django installation on /usr/share/pyshared/django/.

## Creating a new Django project

Now that we know Django is installed we need to create a Django project. I usually place all my web projects on **/home/adrian/www/**, so I will do the same for this one:

```
cd /home/adrian/www/
sudo django-admin startproject djangotest
```

This creates a folder named **djangotest** with the most basic structure for a Django project. These are the files created by django-admin:

**manage.py**: A command-line utility that lets you interact with this Django project in various ways.
  
**mysite/**: The actual Python package for your project. Its name is the Python package name you&#8217;ll need to use to import anything inside it (e.g. import mysite.settings).
  
**mysite/\_\_init\_\_.py**: An empty file that tells Python that this directory should be considered a Python package.
  
**mysite/settings.py**: Settings/configuration for this Django project.
  
**mysite/urls.py**: The URL declarations for this Django project; a &#8220;table of contents&#8221; of your Django-powered site.
  
**mysite/wsgi.py**: An entry-point for WSGI-compatible webservers to serve your project.

To make sure everything is working correctly so far:

```
cd /home/adrian/www/djangotest/
python manage.py runserver
Validating models...

0 errors found
Django version 1.4.1, using settings 'djangotest.settings'
Development server is running at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

You should be able to go to **http://127.0.0.1:8000/** and see a page saying that you have configured your first Django page correctly.

## Hooking to Apache

Now the only thing left is hooking Django to apache to have a production-like set-up. Since I usually work with a lot of web projects at the same time I create a virtual host for each project:

```
cd /etc/apache2/sites-available/
sudo touch djangotest
```

This is the content for my djangotest virtual host:

```xml
<VirtualHost *:80>
    ServerName djangotest.dev
    ServerAlias www.djangotest.dev
    DocumentRoot /home/adrian/www/djangotest

    WSGIScriptAlias / /home/adrian/www/djangotest/djangotest/wsgi.py

    <Directory /home/adrian/www/djangotest>
        <Files wsgi.py>
            Order deny,allow
            Allow from all
        </Files>
    </Directory>
</VirtualHost>
```

To finalize we need to add one line at the end of /etc/apache/apache2.conf:

```
WSGIPythonPath /home/adrian/Dev/djangotest
```

Now we can go to http://djangotest.dev and we will see the same Django welcome page we saw on the previous step.

## Running multiple sites in the same server

You may have noticed from last step that we added a line to our apache2.conf file:

```
WSGIPythonPath /home/adrian/Dev/djangotest
```

This line is pointing directly to our project folder, so an obvious question arises: What if I want to have more than one project in the same machine?. To make this possible we need to configure mod_wsgi to run in daemon mode.

First we need to remove the line we added to apache2.conf. Then we will add two lines to our virtual host:

```
WSGIDaemonProcess djangotest.dev python-path=/home/adrian/Dev/djangotest processes=2 threads=15 display-name=%{GROUP}
WSGIProcessGroup djangotest.dev
```

The whole virtual host file will look like this:

```xml
<VirtualHost *:80>
    ServerName djangotest.dev
    ServerAlias www.djangotest.dev
    DocumentRoot /home/adrian/Dev/djangotest

    WSGIScriptAlias / /home/adrian/Dev/djangotest/djangotest/wsgi.py
    WSGIDaemonProcess djangotest.dev python-path=/home/adrian/Dev/djangotest processes=2 threads=15 display-name=%{GROUP}
    WSGIProcessGroup djangotest.dev

    # This line is necessary so Django can load static content (css, js, etc)
    # for it's build in libraries
    Alias /static/ /usr/share/pyshared/django/contrib/admin/static/

    <Directory /home/adrian/Dev/djangotest>
        <Files wsgi.py>
            Order deny,allow
            Allow from all
        </Files>
    </Directory>
</VirtualHost>
```

Now you can configure as many Django projects as you want in your server.
