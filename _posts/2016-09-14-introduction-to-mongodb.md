---
id: 3885
title: Introduction to MongoDB
date: 2016-09-14T00:48:47+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3885
permalink: /2016/09/introduction-to-mongodb/
categories:
  - MongoDB
tags:
  - databases
  - mongodb
---
Last weekend I participated in a hack day with some colleagues and one of them decided that it would be a good idea to use MongoDB. Since I had never used it, I thought it would be fun to learn a little about it. Here I&#8217;m going to write about the things that I learned.

## Installation

I chose to use Docker because it makes everything easier. The only thing to keep in mind when using Docker for a database is that you need to store the data files outside the container so they don&#8217;t disappear when the container is destroyed. This is enough to get the MongoDB running in a container and making sure the data is persisted in $(PWD)/data in the host:

```
docker run --name my-mongo -v $(PWD)/data:/data/db -d mongo:3.3
```

## First steps

Once we have mongo running we need to open a shell in the running container so we can play with it:

<!--more-->

```
docker exec -it my-mongo bash
```

Then you can get a mongo cli client by running:

```
mongo shell
```

The mongo shell works similarly to mysql-client. The first thing you probably want to do is check the databases that already exist:

```
> show dbs
admin  0.000GB
local  0.000GB
```

You can switch to a DB:

```
> use admin
```

And see the collections (similar to MySQL tables):

```
> show collections;
system.version
```

To create a database you have to move into the database and then create a collection in it:

```
> use temp;
> createCollection('users');
```

Now you will see your database in the list:

```
> show dbs;
admin  0.000GB
local  0.000GB
temp   0.000GB
```

And the collection:

```
> show collections;
users
```

Collections, are different to MySQL tables in that they don&#8217;t have schemas. You can save data without defining what kind of data you are saving. Lets add some users:

```
> db.users.insert({'name': 'Pancho Villa', 'email': 'pancho@villa.com'});
> db.users.insert({'name': 'Miguel Hidalgo', 'phone': '12345678'});
> db.users.insert({'name': 'Benito Juarez', 'email': 'benito.juarez@gmail.com', 'weight': '83kg'});
```

As you can see, I can insert any data I want. It doesn&#8217;t matter if the fields are the same. We can see all the documents in the collection by using find:

```
> db.users.find();
{ "_id" : ObjectId("57d3bd869c149b0f37405e87"), "name" : "Pancho Villa", "email" : "pancho@villa.com" }
{ "_id" : ObjectId("57d3bfbc9c149b0f37405e88"), "name" : "Miguel Hidalgo", "phone" : "12345678" }
{ "_id" : ObjectId("57d3bfed9c149b0f37405e89"), "name" : "Benito Juarez", "email" : "benito.juarez@gmail.com", "weight" : "83kg" }
```

An `_id` field is added automatically to each document. This id is used when you want to make relationships between documents in other collections.

Now that we have documents in our collection we probably want to be able to find them. We already saw how to use the find command in its simplest form, but lets say we only want to get an element with an specific id. We can do it this way:

```
> db.users.find('57d3bfbc9c149b0f37405e89');
{ "_id" : ObjectId("57d3bfed9c149b0f37405e89"), "name" : "Benito Juarez", "email" : "benito.juarez@gmail.com", "weight" : "83kg" }
```

It is important to mention that there is no index in this field, so a linear search is done. I&#8217;ll explain how to create indexes later in this post.

If you want to search by a different field, you can do:

```
> db.users.find({'name': 'Pancho Villa'});
{ "_id" : ObjectId("57d3bd869c149b0f37405e87"), "name" : "Pancho Villa", "email" : "pancho@villa.com" }
```

The [MongoDB documentation explains more advanced queries](https://docs.mongodb.com/manual/tutorial/query-documents/) in detail. I prefer not to duplicate all that information.

Another common operation is updating a document. An update by default will only update one document and will also replace the whole document by default. For example, executing this command:

```
> db.users.update({'_id': ObjectId("57d3bd869c149b0f37405e87")}, {'weight': '79kg'});
```

Will probably not have the effect you expect:

```
> db.users.find('57d3bd869c149b0f37405e87');
{ "_id" : ObjectId("57d3bd869c149b0f37405e87"), 'weight': '79kg' }
```

This could be an unpleasant surprise, so be careful with your updates. To just update the fields without replacing the whole document we need to use [update operators](https://docs.mongodb.com/manual/reference/operator/update/):

```
> db.users.update({'_id': ObjectId("57d3bd869c149b0f37405e87")}, {$set: {'weight': '70kg'}});
```

In the previous example, $set is an update operator and tells MongoDB how to make the update.

To complete the standard CRUD operation set, we need to be able to delete an element. For this we use the remove command:

```
> db.users.remove({'_id': ObjectId("57d3bfab9c149b0f37405e88")});
```

It works similar to a find and will delete all documents matching the query.

## Document validation

Some times you want to enforce certain fields to contain data in certain formats. For this you can use document validation. You can for example update the users table to only accept numbers lower than 300 in the age field:

```
> db.runCommand({'collMod': 'users', validator: {'age': {$type: 'int', $lt: 300}}});
```

If you try to insert a document with an invalid age, you will get an error:

```
> db.users.insert({'name': 'Josefa Ortiz', 'age': 700});
WriteResult({
    "nInserted" : 0,
    "writeError" : {
        "code" : 121,
        "errmsg" : "Document failed validation"
    }
})
```

One gotcha about this is that you now have to use NumberInt function when you insert a new document:

```
> db.users.insert({'name': 'Josefa Ortiz', 'age': NumberInt(70)});
```

## Indexing

Without the ability to index fields, all our queries would be too slow as we add more data into our collections. Indexes are necessary to be able to perform searches efficiently.

To create a simple index on the age field of of users collection we can do:

```
> db.users.createIndex({age: 1});
```

The value 1 means that it will be an ascending index. If we specified -1, it would be a descending index. For a single column index, this doesn&#8217;t really make a difference, the index can be traversed equally in any direction.

There are [other types of indexes in MongoDB](https://docs.mongodb.com/manual/indexes/). You can learn more about them in their documentation.

## Conclusion

Although there are a lot more features in MongoDB, this should be enough to start using it in a project. As I learn more about it, I will write more articles with the parts that I find interesting.
