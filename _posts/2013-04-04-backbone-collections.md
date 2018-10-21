---
id: 1195
title: Backbone collections
date: 2013-04-04T02:57:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1195
permalink: /2013/04/backbone-collections/
tags:
  - backbone
  - collections
  - javascript
---
Collections are a convenient way to group models together. An example usage of them is when you want to show a list of elements in your page. You can create a simple collection using Backbone.Collection (I am using the models I defined on [Introduction to Backbone.js](http://ncona.com/2013/02/introduction-to-backbone-js/ "Introduction to Backbone.js")):

```js
// Create some people
var juan = new Person({'weight': 80});
var carlos = new Person({'weight': 70});
var alicia = new Person({'weight': 75});

var persons = new Backbone.Collection([
  juan,
  carlos,
  alicia
]);
```

<!--more-->

And there are some cool things you can do with them:

```js
// Print weight of all persons
persons.each(function(person) {
  console.log(person.get('weight'));
});

// personWith80 = juan
var personWith80 = persons.find(function(person) {
  return person.get('weight') === 80;
});

// Returns an array of models with all the models that matched the criteria
var thinPeople = persons.filter(function(person) {
  return person.get('weight') < 80;
});

// Print how many models are there currently in persons
console.log(persons.size());
```

There a bunch of other methods that can be used with collections. You can see the whole list in [backbone documentation](http://backbonejs.org/#Collection).

We can also extend the default Collection to create our custom collections, for example:

```js
var Persons = Backbone.Collection.extend({
  // We can specify a model so the collection can instantiate new objects for us
  'model': Person,

  // By adding a comparator we make our collection an ordered list. Every time
  // we add a new element it will be added in the correct order
  'comparator': function(person) {
    return person.get('weight');
  }
});

// Persons creates the models for us
var friends = new Persons([{'weight': 68}, {'weight': 60}, {'weight': 65}]);

var fatPerson = new Person({'weight': 130});
// Add some more models to our collection
friends.add([fatPerson, {'weight': 55}]);

// Prints 50, 60, 65, 68, 130 because of the comparator
friends.each(function(person) {
  console.log(person.get('weight'));
});
```

If you know the ids or cids of your models you can use it to remove elements from your collection:

```js
// Create a new collection
var thinPerson = new Person({'weight': 50});
var fatPerson = new Person({'weight': 130});
var fid = fatPerson.cid;
var friends = new Persons([fatPerson, thinPerson]);

// remove a model based on the cid (client id)
friends.remove([fid]);

// Prints 1
console.log(friends.length);
```

## Events

As with models we can add listeners so we can have our view updated:

```js
var Persons = Backbone.Collection.extend({
    // We can specify a model so the collection can instantiate new objects for us
    'model': Person,

    // Add event listeners on initialization
    'initialize': function() {
      this.on('add', function(person) {
        console.log('This person\'s weight is ' + person.get('weight'));
      });

      this.on('remove', function(person) {
        console.log('Person with cid ' + person.cid + ' is no longer part of the collection');
      });

      this.on('change', function(person) {
        console.log('Weight changed to ' + person.get('weight'));
      });
    }
  });

  var friends = new Persons([{'weight': 68}]);

  var adrian = new Person({'weight': 100});

  friends.add(adrian); // This person's weight is 100
  adrian.set({'weight': 150}); // Weight changed to 150
  friends.remove(adrian); // Person with cid c5 is no longer part of the collection
```
