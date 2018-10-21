---
id: 1571
title: Twitter Bootstrap
date: 2013-07-18T06:01:42+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1571
permalink: /2013/07/twitter-bootstrap/
tags:
  - bootstrapping
  - css
  - javascript
  - open_source
---
Twitter bootstrap is a front end framework that helps rapidly develop responsive web apps. Everybody says it is awesome, so I thought it was time to explore what it does.

I started by downloading it from [Twitter Bootstrap Website](http://twitter.github.io/bootstrap/index.html "Download Twitter Bootstrap"). Twitter Bootstrap depends on jQuery and requires an HTML5 doctype so make sure your page has both.

<!--more-->

## The grid

Bootstrap uses a 12 columns grid by default. You can create a row by adding the class **.row** to a div and create columns using the class **.span<n>**.

```html
<div class="row">
    <div class="span6">Half</div>
    <div class="span3">Quarter</div>
    <div class="span3">Quarter</div>
</div>
```

For the example below you get a 3 column page that accommodates the columns when you resize the window:

[<img src="/images/posts/full_size.png" alt="full_size" />](/images/posts/full_size.png)

[<img src="/images/posts/resized.png" alt="resized" />](/images/posts/resized.png)

By default the grid will adapt to be 1170px wide, but you can make it completely fluid using the **.row-fluid** class. This configuration will expand or collapse your row to use the whole space without breaking the row:

```html
<div class="row-fluid">
    <div class="span6">Half</div>
    <div class="span3">Quarter</div>
    <div class="span3">Quarter</div>
</div>
```

[<img src="/images/posts/fluid.png" alt="fluid" />](/images/posts/fluid.png)

## Styles

Bootstrap provides a lot of styles for base HTML elements that make for an easy to build nice looking UI. You can find all about it on the [Bootstrap Base CSS documentation](http://twitter.github.io/bootstrap/base-css.html "Base CSS"). Here are some examples:

```html
<!-- Buttons -->
<div>
    <a href='#' class='btn'>Button</a>
    <a href='#' class='btn btn-danger'>Button</a>
    <a href='#' class='btn btn-primary btn-large'>Button</a>
    <a href='#' class='btn btn-success btn-mini'>Button</a>
</div>

<!-- Icons -->
<div>
    <i class='icon-lock'></i>
    <a href='#' class='btn'><i class='icon-briefcase'></i></a>
    <a href='#' class='btn'><i class='icon-wrench'></i> Settings</a>
</div>

<!-- Forms -->
<form class='form-horizontal'>
    <div class='control-group'>
        <label class='control-label'>Name</label>
        <div class='controls'>
            <input type='text'>
        </div>
    </div>
    <div class='control-group'>
        <input type='text' placeholder='E-mail'>
    </div>
    <div class='input-append control-group'>
        <input type='text'>
        <button class='btn'>Search</button>
    </div>
    <div class='control-group'>
        <input type='text' class='input-xxlarge'>
    </div>
</form>
```

[<img src="/images/posts/base_css1.png" alt="base_css" />](/images/posts/base_css1.png)

## The rest

Besides basic styling basic HTML elements for you Bootstrap also provides a bunch of components that are commonly used on the web, like navigation bars, progress bars, breadcrumbs, pagination which you can learn more about in the [components documentation](http://twitter.github.io/bootstrap/components.html "Bootstrap components").

It also provides more advanced components that need JavaScript to work, like tabs, modals, carousels, typeahead, etc, which you can also learn about in the [JavaScript components documentation](http://twitter.github.io/bootstrap/javascript.html "Bootstrap JS").

## Conclusion

When I first heard about bootstrap for some reason I thought it was another JS framework, but now that I have taken the time to look at it I realize that it is more like a style guide you can use to quickly build a web application. This ended up being a really fast introduction because their documentation explains all their features pretty well, so if you are interested I encourage you to take a look.
