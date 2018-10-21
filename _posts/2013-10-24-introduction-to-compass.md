---
id: 1808
title: Introduction to Compass
date: 2013-10-24T00:38:59+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1808
permalink: /2013/10/introduction-to-compass/
tags:
  - css
  - productivity
  - web_design
---
Compass describes itself as an open source CSS authoring framework. For me, it is a tool that helps me organize my CSS and create sprites easily.

To install compass you need to have ruby on your system, which I trust you can do by yourself. Once you have ruby installed you need to use these commands:

```
gem update --system
gem install compass
```

Next you will want to create a compass project. Go to your project folder and use this command:

```
compass create <project-name>
```

<!--more-->

This command will create a new folder in your current folder named <project-name>. In that folder you will see two folders: sass and stylesheets. The sass folder is the place where you will write your CSS in a SASS manner. The stylesheets folder is the place where compass will place the CSS files generated from your SASS files. You will also see a config.rb file that sets some default configuration values for this compass project.

The command will also give you a very informative output with instructions to procede:

```
You may now add and edit sass stylesheets in the sass subdirectory of your project.

Sass files beginning with an underscore are called partials and won't be
compiled to CSS, but they can be imported into other sass stylesheets.

You can configure your project by editing the config.rb configuration file.

You must compile your sass stylesheets into CSS when they change.
This can be done in one of the following ways:
  1. To compile on demand:
     compass compile [path/to/project]
  2. To monitor your project for changes and automatically recompile:
     compass watch [path/to/project]

More Resources:
  * Website: http://compass-style.org/
  * Sass: http://sass-lang.com
  * Community: http://groups.google.com/group/compass-users/


To import your new stylesheets add the following lines of HTML (or equivalent) to your webpage:
<head>
  <link href="/stylesheets/screen.css" media="screen, projection" rel="stylesheet" type="text/css" />
  <link href="/stylesheets/print.css" media="print" rel="stylesheet" type="text/css" />
  <!--[if IE]>
      <link href="/stylesheets/ie.css" media="screen, projection" rel="stylesheet" type="text/css" />
  <![endif]-->
</head>
```

## Getting started

I am not going to explain SASS syntax since I have already talked about it in a [previous post](http://ncona.com/2012/08/introduction-to-syntactically-awesome-stylesheets-sass/ "Introduction to Syntactically Awesome Stylesheets (SASS)").

Compass recommends to have a _base.scss partial to initialize your stylesheets. This file can include constants, custom mixins or style guide elements you want to re-use. Lets look at an example:

sass/_base.scss

```css
$value: 10;
```

sass/screen.scss

```css
// Note that you can refer to partials without the
// underscore and extension
@import "base";

.something {
  margin-top: $value;
}
```

Then you can run this command from the compass project folder:

```
compass compile
```

And the following stylesheets/screen.css will be generated:

```css
/* line 3, ../sass/screen.scss */
.something {
  margin-top: 10;
}
```

## Useful commands

Once you have compass ready there are some commands that can make your life easier.

Watch your sass folder and compile stylesheets every time a change is detected:

```
compass watch
```

Generate a compressed version of your CSS:

```
compass compile --output-style compressed --force
```

If you don&#8217;t specify the &#8211;force parameter it won&#8217;t overwrite files that already exist, so be sure to include it.

## Generating sprites

Spriting is a technique used to merge a lot of images into a single image so only one request is needed in order to get the same information. Compass comes with an automatic sprite generator that will generate these for you and help you optimize your application.

If you look into your config.rb file you will notice there is an entry where you specify the images directory:

```
images_dir = "images"
```

This lets compass know that your images will be in a folder with that name. Compass also expects you to have a folder for each sprite that you want to generate, so you can create a folder and put some images in there. For my example I&#8217;ll use:

```
images/sprite1/image1.png
images/sprite1/image2.png
```

Now you can include this on top of your screen.scss file:

```css
@import "sprite1/*.png";
@include all-sprite1-sprites;
```

And run **compass compile**. Now you will see a new file in your images folder. This is going to be the combination of all the images in the sprite1 folder. If you look at stylesheets/screen.css you will also see something like this:

```css
/* line 50, sprite1/*.png */
.sprite1-sprite, .sprite1-image1, .sprite1-image2 {
  background: url('/images/sprite1-sbddad83877.png') no-repeat;
}

/* line 60, ../../../../.rvm/gems/ruby-1.9.3-p327/gems/compass-0.12.2/frameworks/compass/stylesheets/compass/utilities/sprites/_base.scss */
.sprite1-image1 {
  background-position: 0 0;
}

/* line 60, ../../../../.rvm/gems/ruby-1.9.3-p327/gems/compass-0.12.2/frameworks/compass/stylesheets/compass/utilities/sprites/_base.scss */
.sprite1-image2 {
  background-position: 0 -256px;
}
```

Note that **@include all-sprite1-sprites** comes from the folder name: **@include all-<folder_name>-sprites**. Now you can use the generated classes to add those background images to your elements.
