---
id: 1850
title: Implementing Content Security Policy (CSP)
date: 2015-03-25T21:25:15+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1850
permalink: /2015/03/implementing-content-security-policy-csp/
tags:
  - javascript
  - programming
  - security
---
Content Security Policy is a browser feature that allows us to make our apps more secure by helping us prevent Cross Site Scripting(XSS) and content injection attacks. The way it does this is by giving us control over where resources will be loaded from and executed.

Even though [CSP is supported by most browsers](http://caniuse.com/#feat=contentsecuritypolicy), you should always develop your apps thinking of the worst case scenario (The browser not supporting CSP). The golden security rule for web apps is: Filter input, escape output.

Enabling CSP requires us to configure our server to add a header to our document response. The most restrictive(and safest) value for this header would be:

```
Content-Security-Policy: default-src 'none';
```

<!--more-->

This policy is too restrictive for any real life applications because it basically blocks everything. You won&#8217;t be able to load any scripts, css or images from any domain (including the domain from which the document was retrieved) and you won&#8217;t be able to include any scripts or styles inline.

If you are starting a new project I would recommend you start with this restrictive scenario and add exceptions(I&#8217;ll explain how to do this later) as you need them. If you already have an app where you want to implement CSP I recommend you start by adding reporting with this header:

```
Content-Security-Policy-Report-Only: default-src 'none';
```

This will log an error to the console just like the one you get with the Content-Security-Policy header but it will allow all content to be loaded and executed. This way you can first enable reporting in your app, then fix all the issues and once you have fixed all of them enable CSP.

A better approach would be to enable a reporting URL that the browser will use to report violations. You can activate this header in your production app or site for some time before you make the complete switch to CSP and that way you will know if you forgot to white list a resource. Activating a reporting URL also helps you spot XSS vulnerabilities in your app, so it is a good idea to activate it anyway. This is how you would do it:

```
Content-Security-Policy-Report-Only: default-src 'none'; report-uri /reporting-endpoint
```

A report request looks like this:

```json
{
  "csp-report": {
    "document-uri": "http://localhost:8080/",
    "referrer": "",
    "violated-directive": "default-src 'none'",
    "effective-directive": "script-src",
    "original-policy": "default-src 'none'; report-uri /reporting-endpoint",
    "blocked-uri": "http://localhost:8080/js/alert.js",
    "status-code": 200
  }
}
```

Once you know enough about your app that you are ready to white list some domains you can use a few directives to do so. The most common directives are:

**default-src** &#8211; Applies to all resources. If you white list a domain using this directive you will be able to load scripts, css, images, etc. I recommend to set this directive to &#8220;none&#8221; and only white list the things you really need.
  
**script-src** &#8211; Scripts loaded with the script tag.
  
**style-src** &#8211; Styles loaded with the link tag.
  
**img-src** &#8211; Images loaded with the img tag.

You can have a [look at the specification](https://w3c.github.io/webappsec/specs/content-security-policy/) to learn more about the available options.

Here is an example of a server header including some of the available directives:

```
Content-Security-Policy: default-src 'none'; report-uri /reporting-endpoint; script-src 'self'; style-src http://localhost:8080
```

Before you run and implement CSP on your site there are a few important things that you should know. By default CSP disables the following features:

Eval: This might sound harmless because you might not be using eval on your code. There are some very popular frameworks out there that use eval heavily. This is very common specially for templating systems. Check for CSP support on your frameworks and libraries before you make the switch.

Passing strings to setTimeout and setInterval: This won&#8217;t be possible:

```js
setTimeout('alert("hello")', 10);
```

You will have to switch it to something like:

```js
setTimeout(function() {
  alert('hello');
}, 10);
```

Attaching events inline: You won&#8217;t be able to attach events inline. For example, this won&#8217;t work:

```html
<button onclick="doSomething()"></button>
```

Using JavaScript links: You shouldn&#8217;t be doing this anyway, but in case you are. This won&#8217;t work:

```js
<a href="javascript:doSomething()">do something</a>
```

## Troubleshooting

Beware that you have to use single quotes to wrap keywords. Double quotes won&#8217;t work.

This works:

```
Content-Security-Policy: default-src 'none';
```

This doesn&#8217;t:

```
Content-Security-Policy: default-src "none";
```
