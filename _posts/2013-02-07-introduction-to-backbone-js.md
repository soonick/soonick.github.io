---
id: 792
title: Introduction to Backbone.js
date: 2013-02-07T02:38:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=792
permalink: /2013/02/introduction-to-backbone-js/
categories:
  - Javascript
tags:
  - backbone
  - design patterns
  - javascript
  - mvc
---
Backbone.js is a JavaScript framework that facilitates the separation between models and views. It&#8217;s lack of controllers make me think of it as being similar to Django framework, so familiarity with Django may make it easier to understand backbone.

Backbone comes packaged in a js file that you can download from [backbonejs.org](http://backbonejs.org/). If you are not planning to hack backbone you should probably download the production version. Backbone can be used with any templating system but it comes with underscore.js support by default. For this reason to use backbone you will also need to download it from [underscorejs.org](http://underscorejs.org). jQuery is another dependency of backbone, so you also need to include it in your bundle.

In all the examples I show I assume that you have already included jQuery, underscore.js and backbone.js with something similar to:

```html
<script type="text/javascript" src="jquery.js"></script>
<script type="text/javascript" src="underscore.js"></script>
<script type="text/javascript" src="backbone.js"></script>
```

<!--more-->

## Models

Backbone philosophy is that of a more model-driven application, so models are in the hearth of backbone. When building an application you should first concentrate on the information that is important for your application to run and abstract it into models independent from the presentation.

We can create backbone models by extending Backbone.Model this way:

```js
var Person = Backbone.Model.extend({
    'defaults': {
        'weight': null
    },
    // If the person eats increase weight by one
    'eat': function() {
        var w = this.get('weight');
        this.set({'weight': (w + 1)})
    },
    // If the person exercises decrease weight by one
    'exercise': function() {
        var w = this.get('weight');
        this.set({'weight': (w - 1)})
    }
});
```

A few things to notice here. We use backbones **extend** method to customize our new object type. Extend can receive an object defining the properties of our object as it&#8217;s first parameter. We can use the **defaults** attribute to define default values for our objects properties. We can also define custom methods for our object.

Backbone.Model defines a get and a set method. It is best practice to use them to access the properties of our models. Probably the most important reason to do this is because the set method triggers an event that the views can listen to know when a model has changed and needs to be re-rendered.

Since our new object extends Backbone.Model we can extend our new object too:

```js
var FatPerson = Person.extend({
    'defaults': {
        'weight': 150
    }
});
```

And we can make use of our models like this:

```js
var adrian = new Person({'weight': 70});
adrian.exercise();
console.log(adrian.get('weight')); // Outputs 69

var mario = new FatPerson();
mario.eat();
mario.eat();
console.log(mario.get('weight')); // Outputs 152
```

Notice that we are using the **new** keyword to instantiate our objects.

Another useful feature of backbone models is the **initialize** method, which acts as a constructor for your objects and can be useful in many scenarios. Here is a very simple example of how to use it:

```js
var Cat = Backbone.Model.extend({
    'initialize': function(args) {
        console.log(args);
    }
});
var myCat = new Cat({'age': 20});
```

## Views

From the way I see it, views in backbone work more like controllers in common MVC frameworks, and very similarly to views on Django. They communicate with models and templates to keep them synchronized in a convenient way.

Views as well as models have an extend method that takes an object as it&#8217;s first argument, but the properties of this object are very different:

```js
var PersonView = Backbone.View.extend({
    // If not defined this will default to div, but you can use any html tag
    'tagName': 'div',

    // We can define events that this element will listen to
    'events': {
        'click': 'alertSomething',
        'mouseover span': 'changeColor' // Will listen to hover on span elements
                                        // inside of this view
    },

    // You can also use initialize as a constructor
    'initialize': function() {
        // Usually you want to re-render the view when the model changes
        this.listenTo(this.model, 'change', this.render);
    },

    // Of course you want to have the function that will render the model
    'render': function() {
        // this.$el is a reference to the DOM object that represents this view
        // wrapped by jQuery
        this.$el.html('You weight <span>' + this.model.get('weight') + ' kg</span>');
    },

    'alertSomething': function() {
        alert('something');
    },

    'changeColor': function() {
        this.$el.css('background-color', '#f00');
    }
});
```

With the PersonView we created and our Person model we can start seeing the advantage of using backbone. Lets start with this:

```js
ar carlos = new Person({'weight': 70});
var pv = new PersonView({'model': carlos});
pv.render();
$('body').append(pv.el);
```

If we run this code in an HTML page we will see a div saying: You weight 70 kg. We can also try clicking on it to see an alert and hovering over the weight to turn the background red. The most interesting part though is that if you run this command from firebug (or it&#8217;s equivalent):

```
carlos.eat();
```

You will see how the view is automatically updated when the model changes.

## Templates

I think so far we have seen the advantage of using Backbone, but in my view example I used a bad practice: Inserting HTML strings in my views. We can avoid this by using templates.

Backbone allows you to use any templating library you like, but it has built in support (and dependency) for underscore. I won&#8217;t go into much depth on how underscore works, but I will show how we can modify our view to use an underscore template.

We need to create a JS with our template:

```html
var personTemplate = '<p>\
    You weigth <span><%- weight %> kg</span>\
</p>';
```

Note that we are creating a JS file that assigns a string to a variable. There are ways to avoid this and have just an HTML file loaded asynchronously, but they require libraries like require.js.

Once we have this file loaded we can modify our view to use this template:

```js
var PersonView = Backbone.View.extend({
    // The template we will use to render this view
    'template': _.template(personTemplate),

    // If not defined this will default to div, but you can use any html tag
    'tagName': 'div',

    // We can define events that this element will listen to
    'events': {
        'click': 'alertSomething',
        'mouseover span': 'changeColor' // Will listen to hover on span elements
                                        // inside of this view
    },

    // You can also use initialize as a constructor
    'initialize': function() {
        // Usually you want to re-render the view when the model changes
        this.listenTo(this.model, 'change', this.render);
    },

    // Of course you want to have the function that will render the model
    'render': function() {
        // this.$el is a reference to the DOM object that represents this view
        // wrapped by jQuery
        this.$el.html(this.template(this.model.attributes));
    },

    'alertSomething': function() {
        alert('something');
    },

    'changeColor': function() {
        this.$el.css('background-color', '#f00');
    }
});
```

We added a **template** attribute that stores the compiled template, and we modified the render method to use the new template.
