---
id: 956
title: Writting Django applications for your project
date: 2013-03-21T03:31:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=956
permalink: /2013/03/writting-django-applications-for-your-project/
categories:
  - Python
tags:
  - django
  - programming
  - python
---
For this post I am assuming you have already a [Django environment setup](http://ncona.com/2012/11/setting-up-a-django-work-environment/).

## Django apps

Once you have your environment set up, you will want to create apps for your project. Here is what Django documentations has to say about apps:

> What&#8217;s the difference between a project and an app? An app is a Web application that does something &#8212; e.g., a Weblog system, a database of public records or a simple poll app. A project is a collection of configuration and apps for a particular Web site. A project can contain multiple apps. An app can be in multiple projects.

We can use manage.py to help us create our apps. Just go to your project folder and type this command in a terminal:

```
python manage.py startapp crud
```

I chose crud as the name of my app because I am just going to show a simple CRUD(Create, Read, Update, Delete) interface to a DB table.

<!--more-->

The command will create a **crud** folder under our current directory containing four files: \_\_init\_\_.py, models.py, tests.py and views.py. So far our application doesn&#8217;t do anything, we just created the structure so we can work with it. But before that we need tell our project that we want it to include the application we just created. Open settings.py in the project folder and add the name of the app to the INSTALLED_APPS tuple:

```python
INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'crud', # I added this line
)
```

You won&#8217;t see any difference in the way your project behaves yet, but now we can start building our app from the structure we got.

## Creating models

The next step for building our application is defining our models. We will do this in our model.py file. If we open that file we will see this content:

```python
from django.db import models

# Create your models here.
```

We will edit this file to create our model. For this example I will create a person model with three attributes: name, phone and age.

```python
from django.db import models

class Person(models.Model):
    name = models.CharField(max_length=200)
    phone = models.CharField(max_length=15)
    age = models.IntegerField()
```

One thing that caught my attention comming from a Zend_Framework background is that there is only one file that contains all your models. All your models must extend models.Model and contain a number of attributes, each representing a field on the database. You can see that I am using models.CharField and models.IntegerField, you can see the list of [build-in field types in the documentation](https://docs.djangoproject.com/en/dev/ref/models/fields/#field-types).

The fields you define for your model are the names you will use to define an attribute of the object in your code, but also the name of the fields in the database. It is also worth mentioning that by default Django will create one auto incrementing field in the database for each model you create.

Now that we have our model we want to make it work with a database. For this we will need to edit settings.py again. This time we will modify the DATABASES dictionary:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'djangotest',
        'USER': 'soonick',
        'PASSWORD': 'test',
        'HOST': '',
        'PORT': '',
    }
}
```

I set up my database to be a MySQL database with the information I provided. I didn&#8217;t specify the host because it will use localhost as default and it will also use the default port for MySQL databases. I used djangotest as the name of my database, you need to create that database on your server with your favorite client. Also, make sure you have the python-mysql connector installed on your system:

```
sudo apt-get install python-mysqldb
```

Django provides a tool that helps us in the creation of our database. You can run this command:

```
python manage.py sql crud
```

And you will get this in return:

```sql
BEGIN;
CREATE TABLE `crud_person` (
    `id` INTEGER AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` VARCHAR(200) NOT NULL,
    `phone` VARCHAR(15) NOT NULL,
    `age` INTEGER NOT NULL
)
;
COMMIT;
```

This is valid MySQL code that you can just copy and run in your database client, but django provides another command that will create the tables for you:

```
python manage.py syncdb
```

This command will create all the tables that don&#8217;t already exist in your database, for all the applications on the current project. If you pay attention to the output you will notice that some tables that we didn&#8217;t specify were created, those tables belong to the other native applications that are part of INSTALLED_APPS on settings.py.

## Automatic admin interface

One of the things that made Django win a lot of popularity is it&#8217;s automatic admin interface. This interface lets you make simple CRUD operations on your models. It is important to keep in mind that this funtionality is intended for administrators of the application and not final users.

To activate this functionality we need to open settings.py, look for the INSTALLED_APPS tuple and add this value to it:

```python
'django.contrib.admin'
```

After we add this value we need to sync the database one more time:

```sh
python manage.py syncdb
```

Now that the admin interface is set up we need to give it a url on our urls.py file. If you open urls.py you will see these lines (among others):

```python
# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()
```

We need to uncomment the two lines so they look like this:

```python
from django.contrib import admin
admin.autodiscover()
```

We will also see this line:

```python
# Uncomment the next line to enable the admin:
# url(r'^admin/', include(admin.site.urls)),
```

That we need to uncomment too:

```python
url(r'^admin/', include(admin.site.urls)),
```

The first parameter of the url function (r&#8217;^admin/&#8217;) is a regular expression that tells django that all requests starting with **admin/** will be handled by the admin interface.

Now we need to tell Django which models we want to see on the admin interface. We need to register each model we want to see on the interface. Since we only have one model we will register it. Open crud/models.py and modify it to look like this:

```python
from django.db import models
from django.contrib import admin

class Person(models.Model):
    name = models.CharField(max_length=200)
    phone = models.CharField(max_length=15)
    age = models.IntegerField()

admin.site.register(Person)
```

Now that everything is set you need to **restart apache** and go to the /admin/ url on your site. For my configuration it is: http://djangotest.dev/admin/ . Once there you will see a a login prompt asking for your username and password. If you know them go ahead and type them, if you are like me and you don&#8217;t know them then you can use a manage.py to generate a new user for you:

```
python manage.py createsuperuser
```

You will be prompted for your user, email and password. Once inside you can easily make any CRUD operations on your registered models. While you are playing with it you may notice that the interface has some details that may not fit how you want things to work. Luckily this interface is highly configurable so you can later modify it to fit your needs. However I will not address how to configure the admin interface in this post.

## Urls, views and templates

Since we are creating a CRUD application we will be basically duplicating what the admin interface already does for us. This is obviously a bad idea and I am just doing it for the sake of understanding how Django works.

Talking in Django terms, when you are writing the public facing part of your application, they say you are writing the **views**. A view is nothing but a function on the views.py file inside your application&#8217;s folder.

We can create the main page of our site by adding this to views.py:

```python
from django.http import HttpResponse

def index(request):
    return HttpResponse("Hello world!")
```

To be able to view this page we need to add a URL template, and for that we need to create a URLConf file. This file should be named urls.py and live inside your application directory. The URL patterns on this file are regular expressions that will match what the user requested on the browser. Here is how our urls.py will look for our view to work:

```python
from django.conf.urls import patterns, url

from crud import views

urlpatterns = patterns('',
    url(r'^$', views.index, name='index')
)
```

You can see that the regular expresion we used is **^$**, which matches an empty string. This means that if someone requests just your domain, since there is nothing to match after the domain name, the index view will be served.

We need to take one more step before we can see our page in our server. We need to also add a URL pattern to the root URLConf. You will find a urls.py file on you project folder. We already have a route that we created for the admin site, we are going to add one more for the public site leaving it looking like this:

```python
from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^admin/', include(admin.site.urls)),
    url(r'^', include('crud.urls')),
)
```

Since the first rule takes priority, every URL starting with admin/ will be hanled by the admin module and everything else will be handled by our crud application. Now we need to restart our apache server or our build-in server and go to our domain and you will see the message &#8220;Hello world!&#8221;.

There is another part of the equation of making Django work the way it was intended. I come from a PHP and Zend Framework background so what in Django is called views for me sounds like a controller in Zend. It should be used to interface with the models and then send information to what in Django is called a **template**. By default Django will look for folders named templates inside your applications folder, so we need to create te folder and add a file named index.html inside. Add this to the file:

```python
<h1>{{message}}</h1>
```

Now, lets change our view a little to use our new template:

```python
from django.http import HttpResponse
from django.template import loader, Context

def index(request):
    t = loader.get_template('index.html')
    c = Context({'message': 'Hello world!'})
    return HttpResponse(t.render(c))
```

You can see how we used the loader to load our template and how we use the context to pass information to it.

## Writting our app

With all the knowledge we have now we should be able to create our crud application. Let&#8217;s start with a page to insert a new person to the DB. We will use the url **insert/** so we need to add the following line to the urls.py file on our application:

```python
url(r'^insert/$', views.insert, name='insert')
```

Now lets create a form to submit the new person data. We will do this in a template called insert.html that will live in our templates folder:

```html
<form method="post">
    {{ "{% csrf_token" }} %}
    <label>Name: </label>
    <input name="name">
    <br>
    <label>Phone: </label>
    <input name="phone">
    <br>
    <label>Age: </label>
    <input name="age">
    <br>
    <input type="submit" value="Submit">
</form>
```

This is just a simple HTML form. The most interesting part is **{{ "{% csrf_token" }}%}** which is mandatory when using forms in Django. This tag creates a hidden input field with a unique id that helps prevent cross site request forgery.

We need to add an insert function to our views.py file:

```python
from django.http import HttpResponse
from django.template import loader, Context, RequestContext
from crud.models import Person

def insert(request):
    # If this is a post request we insert the person
    if request.method == 'POST':
        p = Person(
            name=request.POST['name'],
            phone=request.POST['phone'],
            age=request.POST['age']
        )
        p.save()

    t = loader.get_template('insert.html')
    c = RequestContext(request)
    return HttpResponse(t.render(c))
```

In this function we are checking if the request is a POST and if it is we create a new person with the information in the POST request and then save it. We use a template as we had used before, but this time instead of using **Context** we use **RequestContext**. If you don&#8217;t use RequestContext you will get an error saying that you must use it for POST requests.

The interface is not friendly at all, but this takes care of the insertion of a Person.

Now lets modify our index page to show a listing of all Persons in the database. The first step is to make sure we have the route in place. The urls.py file for our application should look something like this:

```python
from django.conf.urls import patterns, url

from crud import views

urlpatterns = patterns('',
    url(r'^$', views.index, name='index'),
    url(r'^insert/$', views.insert, name='insert')
)
```

Now we want to add an index function to our views.py file:

```python
def index(request):
    people = Person.objects.all()
    t = loader.get_template('index.html')
    c = Context({'people': people})
    return HttpResponse(t.render(c))
```

Here we are getting all the objects in our Person model and then passing them to our model through the context. Finally we want to configure our model to show this. This will be the content of our index.html template:

```html
{{ "{% if people" }} %}
    <table>
        <tr>
            <th>Name</th>
            <th>Phone</th>
            <th>Age</th>
        </tr>
    {{ "{% for person in people" }} %}
        <tr>
            <td>{{person.name}}</td>
            <td>{{person.phone}}</td>
            <td>{{person.age}}</td>
        </tr>
    {{ "{% endfor" }} %}
    </table>
{{ "{% else" }} %}
    <p>No people in the database</p>
{{ "{% endif" }} %}
```

Now lets take care of the deletes. Add this route to urls.py:

```python
url(r'^delete/(?P<person_id>\d+)$', views.delete, name='delete')
```

You probably noticed that this route is a little different than the routes we have used previously. This route will match any URL that begins with **delete/** and is followed by numbers. For example: **delete/3**, **delete/4334**. This also tells Django that we want to access whichever number was found in the URL using a variable named person_id.

Our view function will receive person_id as an argument and will use it to delete a Person that matches that id, then we redirect our user to the index page:

```python
# We need to add this at the top of our views file so we can use HttpResponseRedirect
from django.http import HttpResponseRedirect

def delete(request, person_id):
    p = Person.objects.get(pk=person_id)
    p.delete()
    return HttpResponseRedirect('/')
```

Now we just need to add a delete link to our Person&#8217;s listing:

```html
{{ "{% if people" }} %}
    <table>
        <tr>
            <th>Name</th>
            <th>Phone</th>
            <th>Age</th>
            <th>Actions</th>
        </tr>
    {{ "{% for person in people" }} %}
        <tr>
            <td>{{person.name}}</td>
            <td>{{person.phone}}</td>
            <td>{{person.age}}</td>
            <td><a href="/delete/{{person.id}}">Delete</a></td>
        </tr>
    {{ "{% endfor" }} %}
    </table>
{{ "{% else" }} %}
    <p>No people in the database</p>
{{ "{% endif" }} %}
```

When the delete link is clicked the Person will be deleted and the user will be redirected to the main page.

For the **edit** action we will use what we learned in the previous steps. First lets define the route in urls.py. At the end our file will look like this:

```python
from django.conf.urls import patterns, url

from crud import views

urlpatterns = patterns('',
    url(r'^$', views.index, name='index'),
    url(r'^insert/$', views.insert, name='insert'),
    url(r'^delete/(?P<person_id>\d+)$', views.delete, name='delete'),
    url(r'^edit/(?P<person_id>\d+)$', views.edit, name='edit')
)
```

Our edit route works the same way as our delete route. Now we need to create our view function:

```python
def edit(request, person_id):
    p = Person.objects.get(pk=person_id)
    if request.method == 'POST':
        p.name = request.POST['name']
        p.phone = request.POST['phone']
        p.age = request.POST['age']
        p.save()
    t = loader.get_template('insert.html')
    c = RequestContext(request, {
        'person': p
    })
    return HttpResponse(t.render(c))
```

This function is very similar to the insert method, but this time we first look for a specific person. We also pass the person we found to the context so it is available to the view. You may have noticed that we are reusing **insert.html**, but for this to work we will need to modify the template a little. Here is the final version:

```html
<form method="post">
    {{ "{% csrf_token" }} %}
    <label>Name: </label>
    <input name="name" value="{{person.name}}">
    <br>
    <label>Phone: </label>
    <input name="phone" value="{{person.phone}}">
    <br>
    <label>Age: </label>
    <input name="age" value="{{person.age}}">
    <br>
    <input type="hidden" name="id" value="{{person.id}}">
    <input type="submit" value="Submit">
</form>
```

We added value attributes to our text fields and created a new hidden field for the id. Since in the insert we don&#8217;t pass a person to the context this doesn&#8217;t affect how the insert looks.

Finally we can create the link that will take us to the edit page in our index.html template:

```html
{{ "{% if people" }} %}
    <table>
        <tr>
            <th>Name</th>
            <th>Phone</th>
            <th>Age</th>
            <th>Actions</th>
        </tr>
    {{ "{% for person in people" }} %}
        <tr>
            <td>{{person.name}}</td>
            <td>{{person.phone}}</td>
            <td>{{person.age}}</td>
            <td><a href="/delete/{{person.id}}">Delete</a></td>
            <td><a href="/edit/{{person.id}}">Edit</a></td>
        </tr>
    {{ "{% endfor" }} %}
    </table>
{{ "{% else" }} %}
    <p>No people in the database</p>
{{ "{% endif" }} %}
```
