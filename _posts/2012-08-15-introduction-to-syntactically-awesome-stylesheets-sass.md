---
id: 773
title: Introduction to Syntactically Awesome Stylesheets (SASS)
date: 2012-08-15T23:58:15+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=773
permalink: /2012/08/introduction-to-syntactically-awesome-stylesheets-sass/
categories:
  - CSS
tags:
  - automation
  - css
---
I have been hearing a lot about SASS lately, so I wanted to find out what the fuss is about. SASS is a meta-language for writting CSS that allows you to use variables, nested rules, etc&#8230; that helps you write less code to achieve the same results.

SASS works with a ruby compiler that can be easily download in ubuntu based distrubutions:

```
sudo apt-get install ruby
sudo apt-get install rubygems
sudo gem install listen
sudo gem install sass
```

It is possible that you will need to restart your OS after running these commands.

<!--more-->

## Compiling files

SASS files use a .scss extension. Once you have a file with .scss extension you can tell sass to watch compile it and watch it for changes.

```
sass --watch example.scss:example.css
```

That command will compile the file with the name example.scss in the current directory and create the file example.css. While this command is running, every time example.scss changes, example.css will be updated. You can do the same for a complete directory:

```
sass --watch css/sass:css/compiled
```

If you find that after running these commands your files are not being updated then try the suggestions on this link: <https://github.com/guard/listen#fallback>. Moving the files to another folder worked for me.

## Features

**Variables**. With SASS you can define variables and use them among your css rules.

```sass
$link-color: #f00;
$default-width: 400px;

body {
    width: $default-width;
}

a {
    color: $link-color;
}
```

will compile into:

```css
body {
  width: 400px; }

a {
  color: red; }
```

This may seem like a lot of extra work for nothing, but when you have very large stylesheets that use a standard palette or standard sizes, and a change is requested it will be a lot easier to make that change.

**Nesting**. Allows us to create a hierarchy for css rules and prevents us from having to manually type the context of our css rules.

```css
#wrapper {
    width: 900px;

    .menu {
        width: 200px;
        float: left;

        a {
            text-decoration: none;
        }
    }
}
```

Will compile to:

```css
#wrapper {
  width: 900px; }
  #wrapper .menu {
    width: 200px;
    float: left; }
    #wrapper .menu a {
      text-decoration: none; }
```

**Parent references**. SASS also helps you prevent some typing by allowing you to reference the parent of a rule using &.

```css
a {
    text-decoration: none;

    &:hover {
        font-weight: bold;
    }
}
```

Compiles to:

```css
a {
  text-decoration: none; }
  a:hover {
    font-weight: bold; }
```

**Mixins**. This functionality allows you to define snippets of code that can included inside other rules wihtout having to re-type all the code.

```css
@mixin rounded {
    $radius: 10px;
    border-radius: $radius;
    -moz-border-radius: $radius;
    -webkit-border-radius: $radius;
}

.button {
    @include rounded;
}
```

Compiles to:

```css
.button {
  border-radius: 10px;
  -moz-border-radius: 10px;
  -webkit-border-radius: 10px; }
```

Mixins can also be declared with arguments for further flexibility:

```css
@mixin rounded($radius: 10px) {
    border-radius: $radius;
    -moz-border-radius: $radius;
    -webkit-border-radius: $radius;
}

.button {
    @include rounded;
}

.pretty-div {
    @include rounded(5px);
}
```

Compiles to:

```css
.button {
  border-radius: 10px;
  -moz-border-radius: 10px;
  -webkit-border-radius: 10px; }

.pretty-div {
  border-radius: 5px;
  -moz-border-radius: 5px;
  -webkit-border-radius: 5px; }
```
