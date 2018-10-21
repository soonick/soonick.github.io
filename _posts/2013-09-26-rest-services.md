---
id: 1539
title: REST Services
date: 2013-09-26T04:02:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1539
permalink: /2013/09/rest-services/
tags:
  - application_design
  - design_patterns
  - json
  - programming
---
The more I have been working on large scale projects the more I have seen the use of REST (Representational State Transfer) for almost everything. The basic concept of having an HTTP end point where you can make a request and get a JSON as a response is pretty easy to understand, but since I have never build a service from scratch I wanted to dig a little deeper into the architecture and requirements of this type of services.

## Representational State Transfer

REST makes us think of our services as an interface to let the client know the current state of a resource. The state of our resource is saved somewhere in the server (Maybe in a database) and is modified or retrieved via HTTP verbs. For example, lets say we have a **people** table in a database and we want to know the current state of a specific person, we would do a GET request to this url:

```
http://service.url/people/1234
```

And we would get a response with the information that is currently stored in the database about the user with an id of 1234.

<!--more-->

## HTTP verbs

This may be subject to discussion, but I have heard from colleagues that a good web service should use all HTTP verbs correctly. There are four HTTP methods that are supposed to match with the four CRUD operations:

```
Create - POST
Read - GET
Update - PUT
Delete - DELETE
```

If you have done web development you might be very familiar with GET and POST. When doing web development we use typically POST for everything that modifies or saves data. This is ok, and in fact a lot of people do it, but there is a reason why some experts suggest to use all verbs for REST services.

## Idempotence

Idempotence means that if you apply an operation to an element once it will have the same result of applying it twice or more times. One example of this operations in mathematics is the |x|(absolute value) operation. No matter how many times you apply that operation to a number it will always give the same result:

```
|-4| = 4
|4| = 4
|4| = 4
...
```

The PUT and DELETE verbs are like this. No matter how many times you execute them they will have the same result. Lets say you make a DELETE request:

```
http://service.url/people/1234
```

this request will delete the record 1234 from the people table. You can call it more than once and the effect on the table will not change, the same goes for PUT:

```
http://service.url/people/1234
{name: "Juan"}
```

You are setting the name of record 1234 to Juan, if you call it more than once the resource will always end in the same state.

## REST APIs

One of the reasons REST APIs are being used all over the place is because it&#8217;s consumption is very easy. You define an end point, you hit it with a GET request and you get some data back (most of the time in JSON format). But for there to be an API to consume someone has to create it first.

A good API should give the consumer a good understanding of the [domain](http://en.wikipedia.org/wiki/Domain-driven_design "Domain Driven Design") of the objects we are modeling and enough freedom to use your API in ways you didn&#8217;t imagine when you created it.

Experts suggest that you should only have two base URLs for a given resource, so instead of having an API like this:

```
/getPerson
/modifyPerson
/deletePerson
...
```

We should have only two base URLs, one for a collection and one for a single element:

```
/people
/people/1234
```

And make use of the HTTP verbs to do all the things we can image against our resource:

  * **POST on /people**: Create a new person.
  * **GET on /people**: Get list of people.
  * **PUT on /people**: Replace list of people with new list.
  * **DELETE on /people**: Delete all people.
  * **POST on /people/1234**: Do nothing, send error back.
  * **GET on /people/1234**: Get person with id 1234.
  * **PUT on /people/1234**: Modify person with id 1234, send error if doesn&#8217;t exist.
  * **DELETE on /people/1234**: Delete person with id 1234.

Another thing worth noticing here is that I used /people instead of /person. The most important rule is to be consistent, but I recommend using plurals because it is easier to understand that **/people** means a list of people than **/person** meaning a list of people. And when working with single elements **/people/1234** and **/person/1234** both express correctly that you want to get the person with id 1234.

## Associations

There are times when you want to work with resources that have relationships with other resources, for example, a person can have cars, so we could list all the cars a person has by doing a get request to:

```
/people/1234/cars
```

Also, if we made a post request to the same URL we could add a car to that person. It isn&#8217;t recommended to go deeper than this because we shouldn&#8217;t in any case need more than one id in our URL, for example, this:

```
/people/1234/cars/9876
```

shouldn&#8217;t be done because it would basically be the same as:

```
/cars/9876
```

## Specific scenarios

So far, we have learned how to create APIs that can do a lot of stuff, but they can&#8217;t do everything we would need on a complex system. So, how can we make it possible for our API to have more advanced functionality without making it more complex? The trick is to make the complexity optional so only people who really need it use it.

Now that we have defined our basic API we can give advanced users a little more power. Say we wanted to list all people with Mexican nationality. We can use our already defined end point for people and pass our extra parameters in the query string:

```
/people?nationality=mexican
```

If you wanted to modify all Mexicans you could use the same URL but use PUT instead of GET.

## HTTP status code

It is not uncommon to see some service responses that look like this:

```
HTTP Status code: 200

{ "statusCode": 501, "message": "OK" }
```

This can be confusing because the HTTP status code is telling you that the request was successful but the response is telling you that there was a server error. Ideally you will want these two values to always match to avoid confusion. Another good idea is to give the user meaningful information about the error and if there is any documentation that can help them point them to it:

```
HTTP Status code: 501

{
  "statusCode": 501,
  "code": "10001",
  "message": "Unexpected value for argument x",
  "more_info": "http://yoursite.com/documentation/err/10001"
}
```

## Versioning

It is very likely that your API won&#8217;t be perfect the first time you release it, so it is a good idea to version it so you can release new features or fix bugs without breaking the users of an old version. Versioning is pretty simple but it is really beneficial to have it in place since the first release so you don&#8217;t break users when you upgrade.

You can version your API in many different ways, but probably the simplest(and best) approach is to precede your API end point by the version of the API:

```
http://service.url/v1/people/1234
```

## Not resourcy stuff

There are going to be times when you will want to make a service that doesn&#8217;t serve resources. An example of this could be google translate, where they have and endpoint where you can send a string and it will return a translation of it. When you find yourself in this situation it is recommended to use verbs for your end points. So, for a service that translates a string it could be something like this:

```
/translate?text=Some text to translate&from=english&to=spanish
```
