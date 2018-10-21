---
id: 1305
title: Writing a simple Node.js server
date: 2013-04-25T03:20:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1305
permalink: /2013/04/writing-a-simple-node-js-server/
tags:
  - javascript
  - node
  - programming
---
I recently wrote a [post about node.js](http://ncona.com/2013/04/introduction-to-node-js/ "Introduction to node.js") and this time I&#8217;m going to talk about one of it&#8217;s most common uses; a web server.

Thanks to the libraries that come packed by default with node, creating a very simple server is very easy. Create a file named server.js and add this content to it:

```js
var http = require('http');

http.createServer(function(req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('I\'m a server');
}).listen('9000', '127.0.0.1');
```

Save the file and open a terminal in the folder where that file is stored. Then run **node server.js** and visit **http://127.0.0.1:9000**. You will see something like this:

[<img src="/images/posts/node-server.png" alt="Node server" />](/images/posts/node-server.png)

Might not be very exciting but this is were everything starts.

<!--more-->

Here is a version describing what is happening:

```js
// Include the http library and assign it to the http variable
var http = require('http');

// The http library exposes the createServer method which takes a function
// as an argument, to which it will in turn pass a request and response
http.createServer(function(req, res) {
  // Set the header for the response. The first argument is the response code
  // And the second is an object with the headers we want to include
  res.writeHead(200, {'Content-Type': 'text/plain'});

  // All requests should have a call to res.end to signal the server
  // that this response can be considered as completed. It optionally
  // takes as first argument data to be sent in the response.
  res.end('I\'m a server');
}).listen('9000', '127.0.0.1'); // Set the port and host name to listen
```

If you want to learn more about the http module you can always check the [HTTP Node.js manual](http://nodejs.org/api/http.html#http_response_writehead_statuscode_reasonphrase_headers)

We didn&#8217;t use it this time but the anonymous function that is executed inside the server receives a request parameter. This argument is an object containing anything you would want to know about the request, so if we added these lines to our server:

```js
console.log(req.url);
console.log(require('url').parse(req.url));
console.log(req.headers['user-agent']);
```

And we visited **http://127.0.0.1:9000/something?hello=world** we would get an output similar to:

```
/something?hello=world
{ search: '?hello=world',
  query: 'hello=world',
  pathname: '/something',
  path: '/something?hello=world',
  href: '/something?hello=world' }
Mozilla/5.0 (X11; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0
```

As it can be seen there is a lot of useful information in the request that can be used to make fully functional websites. Most of the time you will want to use a web framework to do those things but I&#8217;ll talk about that in another article.
