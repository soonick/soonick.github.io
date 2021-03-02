---
title: Introduction to AWS Dynamo DB
author: adrian.ancona
layout: post
# date: 2021-01-13
# permalink: /2021/01/introduction-to-aws-dynamo-db
tags:
  - architecture
  - aws
  - databases
  - programming
---

Dynamo DB is AWS' serverless key-value store offering. In some ways it is similar to [Google Firestore](/2020/12/introduction-to-google-firestore/), which I wrote about in a previous article.

## Why use Dynamo DB?

Dynamo DB is one of the most products offered by AWS. The actual [SLA](https://aws.amazon.com/dynamodb/sla/) sounds a little dodgy, but the number of actual failures is very low and the failure modes are mostly safe.

Dynamo DB scales automatically and provides low latency regardless on the amount of data and number of requests it receives. This is something that is simply not possible with relational databases.

Anything stored in Dynamo DB is automatically replicated 3 times.

There are tools that make it easy to create back-ups and restore them when needed.

## Concepts

- `Table` - Similar to SQL offerings, data is stored in tables. Tables have a name that identifies them, but the don't have a schema (predefined columns)
- `Item` - Similar to rows in SQL, they define an entry in the table
- `Attribute` - An item can have multiple attributes. An attribute is a key-value combination, for example: `color: red`
- `Partition key` - Similar to a primary key in SQL. Different items can have different attributes, but all items must define a value for the partition key
- `Sort key` - When a table has a sort key, elements can have duplicated `partition keys` as long as they have different sort keys. This allows queries using a single partition key value that return all the items with the same `partition key`

## Creating tables

To create a table we need a `name` and at least a `partition key`. These names must be UTF-8 encoded, contain 3 to 255 characters and contain only letters (a-z, A-Z), numbers (0-9), dot (.), underscore (_) and dash (-). Dynamo DB supports multiple data types, but partition keys must be `string`, `number` or `binary`.



https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SQLtoNoSQL.CreateTable.html





https://www.youtube.com/watch?v=HaEPXoXVf2k
