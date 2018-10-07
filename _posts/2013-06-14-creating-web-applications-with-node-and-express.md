---
id: 1384
title: Creating web applications with Node and Express
date: 2013-06-14T04:33:26+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1384
permalink: /2013/06/creating-web-applications-with-node-and-express/
categories:
  - Javascript
---
Express is a web framework which allows you to easily make web applications on node. I already wrote about [writing a simple server with node](http://ncona.com/2013/04/writing-a-simple-node-js-server/ "Writing a simple server with node"), but this time I will focus more on the application structure.

Lets start by creating a folder for our app called **app/** and put a file inside named **package.json**. This is a special file used to define node projects. You can find more information about it on [node JSON documentation](https://npmjs.org/doc/json.html "Node JSON documentation"), in this example I&#8217;ll use just the basics:

```json
{
  "name": "app",
  "description": "A simple sample app",
  "version": "0.0.1",
  "dependencies": {
    "express": "3.x"
  }
}
```

An important thing to mention is that this has to be a JSON file, so all the json attributes and values must be wrapped by double quotes (&#8220;). Most of the fields are just information about the project, but the dependencies attribute defines which packages my projects depends on. These packages will by default be downloaded from [npmjs.com](https://npmjs.org/ "Node Package Modules"). We specified that we want the latest revision of version 3 of Express for our project.

<!--more-->

Once we have this file in place we want to get our dependencies (express). Go to your app/ folder and:

```
npm install
```

This will download the express module and put it in a node_modules/ folder in the current location. Now we can start writing our app. The entry point for your server on node applications is usually called app.js or server.js. I&#8217;ll use app.js because I have seen it being used more often. Create a file app.js in your app/ folder:

```js
var express = require('express');

var app = express();

app.get('/', function(req, res) {
  res.send('Home page');
});

app.get('/contact', function(req, res) {
  res.send('Contact page');
});

app.listen(9988);
```

This is very similar to my simple server example, but express abstracts some things for us. In lines 5 and 9 I use app.get, which means that they will only respond to GET requests. I also specify a route, so each function will only be executed if the route is matched. If you start your server using **node app.js** and go to **http://localhost:9988/**, you&#8217;ll get &#8216;Home page&#8217;, if you go to **http://localhost:9988/contact** you&#8217;ll get &#8216;Contact page&#8217;. So you may be asking yourself, what happens if I go to http://localhost:9988/other. Well, right now you will get a message saying Cannot GET /other, but we can fix it like this:

```js
var express = require('express');

var app = express();

app.get('/', function(req, res) {
  res.send('Home page');
});

app.get('/contact', function(req, res) {
  res.send('Contact page');
});

app.get('*', function(req, res) {
  res.send('How did you get here?');
});

app.listen(9988);
```

We defined a new route `(*)`, that catches any request. It is important to put it as the last route on your list because express will try to match the requested URL against all the defined routes in the order they were defined and will use the first that matches. So now if you go to **http://localhost:9988/something/else** you&#8217;ll get &#8216;How did you get here?&#8217;.

## An MVC app

Now that we are familiar with express, we can try to create an MVC app. Lets start by creating our folder structure

```
app/
 |---models/
 |---views/
 |---controllers/
 |---public/
```

It should be obvious what we are going to put on each folder. The public folder will contain our images, css, js, etc. Our application will be a very simple in-memory CRUD application. Lets start by creating our controller (app/controllers/crud.js):

```js
app = require('../app');

function create(req, res) {
  res.send('Create a record');
}

function read(req, res) {
  res.send('Show the records here');
}

function update(req, res) {
  res.send('Update a record');
}

// delete is a reserved word so I had to use deletes
function deletes(req, res) {
  res.send('Delete a record');
}

// Routes
app.get('/create', create);
app.get('/', read);
app.get('/update', update);
app.get('/delete', deletes);
```

This is very similar to our previous app.js file, but with a little more order. We created functions for each of the possible actions and defined the routes at the bottom of the file. We got access to the express app by calling require(&#8216;../app&#8217;), but we will have to modify app.js for this to work:

```js
var fs = require('fs'),
    express = require('express'),
    app = express();

function initRoutes() {
  // load controllers
  var controllersFolder = __dirname + '/controllers/';
  fs.readdir(controllersFolder, function(err, files) {
    files.forEach(function(file){
      var name = file.replace('.js', '');
      require(controllersFolder +  name);
    });
  });
}

initRoutes();

app.listen(9988);

// Make the app available to the outside
module.exports = app;
```

The first change we made was creating the initRoutes function to load all the controllers in the controllers/ folder. By doing this we are also activating all the routes defined in our controllers. The other important change we made is adding app to module.exports so we can access the app from other modules.

The next thing I want to do is to create a little model for the example. This will be a really simple model that I will put on **models/records.js**:

```js
module.exports = [];
```

As I said, this is very simple. Our module is a plain array where our records will live. The next thing we want to do is to show our records on our main route (/), to do this we&#8217;ll use a template engine. I don&#8217;t have any preference for template engines, but since express recommends [jade](http://jade-lang.com/ "Jade templating engine"), I&#8217;ll use that one for my example. So we need to add it as a dependency in our package.json:

```json
{
  "name": "app",
  "description": "A simple sample app",
  "version": "0.0.1",
  "dependencies": {
    "express": "3.x",
    "jade": "0.30.x"
  }
}
```

I added a new entry on the dependencies object for jade. I chose to get the latest revision of the current version (0.30), you can use a different version if you want. To actually download this dependency we need to go to our project folder and execute:

```
npm install
```

Now we will create a layout with some html boilerplate. This is views/layout.jade:

```
doctype 5
html(lang='en')
  head
    title Example express app
  block body
```

Jade syntax is a little weird, but hopefully not enough to prevent you from understanding what this does. What is worth explaining is that **block body** is a place holder for accepting content from other template. This is views/read.jade:

```
extends layout

block body
  ul
    each d in data
      li= d
```

This will print a list with all the elements found in the data array. The first line (**extends layout**) tells jade that we will be using layout.jade as our template and **block body** tells it that we want the body block to have the following content. Now we need to make some changes to our crud.js controller:

```js
app = require('../app');
records = require('../models/records');

// Removed code from here to show only what was changed

function read(req, res) {
  res.render('read.jade', { data: records });
}

// Removed code from here to show only what was changed
```

So, what we did is to require the records model so we can use it in our template and then we call render passing it our records. Note that we are putting our records in the **data** index of an object. This is the name our jade template uses to loop through the records.

If you go to **http://localhost:9988/** you wont see anything yet because our records array is empty. Lets fix this with our create page. We will start by creating our template (views/create.jade):

```
extends layout

block body
  form(action='/create' method='post')
    label Record:
    input(name="record")
    input(type='submit', value='Submit')
```

It is a very simple form with one input field. Note also that we are posting to **/create**. We defined a get route above, which will show this form, but we didn&#8217;t define a post route. Lets add this route as well as the functionality for both post and get:

```js
// Not showing other includes to keep example short
express = require('express');

function create(req, res) {
  if (req.body) {
    records.push(req.body.record);
    res.redirect('/');
    return;
  }

  res.render('create.jade');
}

// Routes
app.post('/create', express.bodyParser(), create);
app.get('/create', create);
// Not showing other routes to keep example short
```

The first thing I did is add a route for the POST method. You will see in this line: **express.bodyParser()**. This is referred by express as a middleware. What it does for us is parsing the POST request so we can easily access it from req.body as we do in the create function. Notice also that both the post and the get action point to the same action, so in the action code I check if there is content in the request and if a record is found I add it to our model and redirect you to the read page. This is of course a terrible user experience, but I won&#8217;t pay much attention to it in this post.

Lest take care of the delete now. I will add a link to delete records to the read.jade template:

```
extends layout

block body
  ul
    each d in data
      li= d
        a(href='/delete?record=#{d}') delete
```

We are making each of the links look like **/delete?record=value**. Finally, lets modify our controller to take care of this:

```js
// delete is a reserved word so I had to use deletes
function deletes(req, res) {
  var index = records.indexOf(req.query.record);
  records.splice(index, 1);
  res.redirect('/');
}
```

This method uses splice to remove the item from the records. I&#8217;m not going to explain the update action since it should be very easy to create with the previous examples.
