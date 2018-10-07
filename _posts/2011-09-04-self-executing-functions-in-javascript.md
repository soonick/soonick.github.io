---
id: 284
title: Self executing functions in javascript
date: 2011-09-04T01:45:23+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=284
permalink: /2011/09/self-executing-functions-in-javascript/
categories:
  - Javascript
tags:
  - design patterns
  - javascript
---
When I first saw this programming pattern I found very difficult to understand why would people want to make their code so confusing. When I finally understood why this is used I knew I had to write about it someday. Today is that day.

Self executing functions are useful because using them you avoid creating global variables that could interfere with other parts of your code.

To understand this better I will give three examples of how you pollute and avoid the pollution of the global space.
  
<!--more-->

## The worst case: In-line code

When you want to execute some code right away you can just do this:

```js
<script type="text/javascript">
var a = 2;
var b = 3;
var c = a + b;
alert(c);
</script>
```

In that snippet we declared three variables that are global because they are not in a function. Because of this they can be accessed from anywhere in your code. This is bad because you are storing references to variables you don&#8217;t need anymore, but also because you may have overwritten contents that were already in those variables.

## Not so bad case: Function

To make pollution of the global space less, we can use a function to execute that code:

```js
<script type="text/javascript">
function add()
{
    var a = 2;
    var b = 3;
    var c = a + b;
    alert(c);
}

add();
</script>
```

In this occasion we created a function to execute the code. This is good if that function is going to be needed after that first execution, but if that function is never going to be called again then we reduced the number of global variables to one (which is good), but we can do better than that.

## The solution: Self executing function

To completely avoid the pollution of the global space you can use an anonymous (without name) self executing function:

```js
<script type="text/javascript">
function()
{
    var a = 2;
    var b = 3;
    var c = a + b;
    alert(c);
}();
</script>
```

By removing the name of the function you make it anonymous so it doesn&#8217;t have a reference. The parenthesis after the closing brackets execute the function right after it is defined.

Most of the times you will see a self executing function enclosed in parenthesis. This is not necessary, but is recommended because that way you tell the person reading your code that it is a self executing function from the beginning of your function.

```js
<script type="text/javascript">
(function()
{
    var a = 2;
    var b = 3;
    var c = a + b;
    alert(c);
})();
</script>
```

I haven&#8217;t found a use for passing parameters to a self executing function, but in case you find one, you can do it this way:

```js
<script type="text/javascript">
(function(a, b)
{
    var c = a + b;
    alert(c);
})(2, 3);
</script>
```
