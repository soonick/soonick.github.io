---
id: 1371
title: Why and how is dust.js asynchronous
date: 2013-05-16T01:58:36+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1371
permalink: /2013/05/why-and-how-is-dust-js-asynchronous/
tags:
  - debugging
  - javascript
  - programming
  - projects
---
Today we had a discussion at work about which templating library we should use for our backbone applications. Since Dust is the library most teams in the company use, we thought it may be the direction we want to take. I have never used Dust, but some people in the room mentioned that the fact that it was asynchronous made it a little painful to do some tasks. It was very weird for me to hear that the rendering of templates happened asynchronously, mostly because I don&#8217;t know a way to make JS execute asynchronously other than using setTimeout. So I decided to dive into the code and figure out how they are doing it.

I started my journey by getting [dust from github](https://github.com/akdubya/dustjs "Dust templating"). The only file I really needed was dist/dust-full-0.3.0.js, so I got the file and built a simple example in an HTML file:

```html
<html>
<head>
  <script src='dust-full-0.3.0.js'></script>
  <script>
    var compiled = dust.compile("Hello {name}!", "intro");
    dust.loadSource(compiled);
    dust.render("intro", {name: "Fred"}, function(err, out) {
      console.log(out);
    });
  </script>
</head>
<body>
</body>
</html>
```

<!--more-->

We can see that **dust.render** doesn&#8217;t return the rendered template, but it passes it to a callback function, so lets see what is happening. This is how dust.render looks like:

```js
dust.render = function(name, context, callback) {
  var chunk = new Stub(callback).head;
  dust.load(name, chunk, Context.wrap(context)).end();
};
```

The three arguments we are passing are the name of the template, the object containing the data we will use in our template and the callback to which we&#8217;ll pass the final result. This function by itself doesn&#8217;t tell us what is happening. A mysterious chunk variable is created from the Stub constructor, so lets take a look:

```js
function Stub(callback) {
  this.head = new Chunk(this);
  this.callback = callback;
  this.out = '';
}
```

It seems like the callback is saved to use later, so lets continue with **dust.load**:

```js
dust.load = function(name, chunk, context) {
  var tmpl = dust.cache[name];
  if (tmpl) {
    return tmpl(chunk, context);
  } else {
    if (dust.onLoad) {
      return chunk.map(function(chunk) {
        dust.onLoad(name, function(err, src) {
          if (err) return chunk.setError(err);
          if (!dust.cache[name]) dust.loadSource(dust.compile(src, name));
          dust.cache[name](chunk, context).end();
        });
      });
    }
    return chunk.setError(new Error("Template Not Found: " + name));
  }
};
```

**dust.cache** is a hash table with the templates we have already compiled. Since we already compiled our template, it will be there and tmpl will have this value (I am formatting it to make it more readable):

```js
function body_0(chk, ctx) {
  return chk.write("Hello ")
      .reference(ctx.get("name"),ctx,"h")
      .write("!");
}
```

Since chk is the the chunk variable we created previously we will have to take a look at what the write method does:

```js
Chunk.prototype.write = function(data) {
  var taps  = this.taps;

  if (taps) {
    data = taps.go(data);
  }
  this.data += data;
  return this;
}
```

Not much going on here either, it only saves the data for later use, we haven&#8217;t executed the callback. Do you remember: dust.load(name, chunk, Context.wrap(context)).**end()**; ?. Lets look at this last step:

```js
Chunk.prototype.end = function(data) {
  if (data) {
    this.write(data);
  }
  this.flushable = true;
  this.root.flush();
  return this;
}
```

The important part here is the call to **this.root.flush()**, which essentially executes this function:

```js
Stub.prototype.flush = function() {
  var chunk = this.head;

  while (chunk) {
    if (chunk.flushable) {
      this.out += chunk.data;
    } else if (chunk.error) {
      this.callback(chunk.error);
      this.flush = function() {};
      return;
    } else {
      return;
    }
    chunk = chunk.next;
    this.head = chunk;
  }
  this.callback(null, this.out);
}
```

You can see in the last line that the callback gets executed and the output is passed to it in the second argument. So, how did dust achieve to make the rendering asynchronous? Well, from what I can see in the code I would say, it didn&#8217;t. It seems like it is not doing anything asynchronously, it just chose to use a callback to pass the rendered template. This decision seems a little weird to me, but if I had to guess I would say that it has something to do with dust also running on node, and most node libraries working asynchronously.
