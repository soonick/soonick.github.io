---
title: Searching Related Documents With Elasticsearch
author: adrian.ancona
layout: post
date: 2022-11-30
permalink: /2022/11/searching-related-documents-with-elasticsearch
tags:
  - architecture
  - data_structures
  - databases
---

In my last article we learned how to [get started with Elasticsearch](/2022/10/introduction-to-elasticsearch). In this article we are going to learn some strategies for dealing with related documents.

## Relationships

Relationships between documents depend on the type of data we are storing. Some examples of relationships:

- Restaurants and locations, where a restaurant can have multiple locations, but a location can only belong to one restaurant. This is a one to many relationship.
- Orders and users, where each order belongs to a user. A user can have multiple orders but an order belongs to a single user. Also, one to many.
- Movies and actors. A movie can star multiple actors and an actor can star in multiple movies. Many to many relationship.

<!--more-->

## Denormalizing data

In Elasticsearch we have the same options as in any other document store, and one of them is denormalization. While in a relational database we generally want to [normalize](https://en.wikipedia.org/wiki/Database_normalization), in non-relational databases, sometimes the opposite is recommended.

In a relational database we might do this for the restaurants with locations example:

Restaurants table:

```
restaurant_id
owner
name
```

Locations table:

```
location_id
restaurant_id
adress
city
country
```

In Elasticsearch we could denormalize this same data if we have these fields:

```
restaurant_id
owner
name
location.adress
location.city
location.country
```

That would allow us to store a document like this one, for example:

```json
{
  "name": "My little food spot",
  "owner": "Carlos",
  "locations": [
    {
      "address": "32 Some street name",
      "city": "Mytown",
      "country": "Some country"
    },
    {
      "address": "398 Another street",
      "city": "Bigger town",
      "country": "Some country"
    }
  ]
}
```

This works well for the restaurants and locations example because it's unlikely that we will be interested in a location without getting information about the restaurant it belongs to.

There are some things we need to be wary of when we do this:
- Restaurant records could become large if they have many locations
- Every time a location changes, the whole restaurant needs to be updated
- There is a gotcha searching nested documents that we will explain later in this article

Denormalization is a little more complicated when we deal with many-to-many relationships.

Let's look at our movies and actors example. We have multiple actors and multiple movies, so we could have documents like these:

```json
{
  "name": "The Machinist",
  "release_year": 2004,
  "director": "Brad Anderson",
  "actors": [
    {
      "name": "Christian Bale",
      "birth_year": 1974,
      "birth_country": "United Kingdom"
    },
    {
      "name": "Jennifer Jason Leigh",
      "birth_year": 1962,
      "birth_country": "United States"
    }
  ]
}

{
  "name": "American Psycho",
  "release_year": 2000,
  "director": "Mary Harron",
  "actors": [
    {
      "name": "Christian Bale",
      "birth_year": 1974,
      "birth_country": "United Kingdom"
    },
    {
      "name": "Reese Witherspoon",
      "birth_year": 1976,
      "birth_country": "United States"
    }
  ]
}
```

Depending on our query patterns, we might want to index the other way around, having an index of `actors` instead of `movies` and list each of the actors' movies. Or we might want to keep both indices for different kinds of queries.

In the example above, if we decided to modify the data for `Christian Bale` we would need to modify two documents instead of one. These updates ideally would be atomic (Either both documents are updated or none). Atomic updates of multiple documents can make database operations slow. This speed hit might be acceptable, but it's something to keep in mind.

## Gotcha searching nested documents

To illustrate a problem with searching denormalized data, let's look at the restaurants with locations example. Let's create this document:

```json
{
  "name": "My little food spot",
  "owner": "Carlos",
  "locations": [
    {
      "address": "32 Some street name",
      "city": "Mytown",
      "country": "Some country"
    },
    {
      "address": "398 Another street",
      "city": "Bigger town",
      "country": "Some country"
    }
  ]
}
```

And let's say we try to find all restaurants that have a location in a street named `Some` in the city `Mytown`. We can use a query like this one:

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "locations.city": "Mytown"
          }
        },
        {
          "match": {
            "locations.address": "Some"
          }
        }
      ]
    }
  }
}
```

The result will be as expected:

```json
{
  "took" : 4,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.970927,
    "hits" : [
      {
        "_index" : "restaurants",
        "_id" : "7zBcRYQB1JvA4r1h7mXr",
        "_score" : 0.970927,
        "_source" : {
          "name" : "My little food spot",
          "owner" : "Carlos",
          "locations" : [
            {
              "address" : "32 Some street name",
              "city" : "Mytown",
              "country" : "Some country"
            },
            {
              "address" : "398 Another street",
              "city" : "Bigger town",
              "country" : "Some country"
            }
          ]
        }
      }
    ]
  }
}
```

Our restaurant has a location that matches the search criteria.

The problem comes when we want to search `Some` in `Bigger town`:

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "locations.city": "Bigger town"
          }
        },
        {
          "match": {
            "locations.address": "Some"
          }
        }
      ]
    }
  }
}
```

This returns the restaurant even when there is no address `Some` in `Bigger town`:

```json
{
  "took" : 4,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 1.258609,
    "hits" : [
      {
        "_index" : "restaurants",
        "_id" : "7zBcRYQB1JvA4r1h7mXr",
        "_score" : 1.258609,
        "_source" : {
          "name" : "My little food spot",
          "owner" : "Carlos",
          "locations" : [
            {
              "address" : "32 Some street name",
              "city" : "Mytown",
              "country" : "Some country"
            },
            {
              "address" : "398 Another street",
              "city" : "Bigger town",
              "country" : "Some country"
            }
          ]
        }
      }
    ]
  }
}
```

This is not what we wanted. We wanted to find restaurants with locations that match both `Bigger town` and `Some street`.

The reason this doesn't work is because all indexing is happening at the `restaurant` level. The field `locations.address` is indexed without distinguishing that they belong to two different addresses.

To fix this problem we need to change the mappings for our index. Let's look at the current mapping for the `restaurants` index:

```json
{
  "restaurants" : {
    "mappings" : {
      "properties" : {
        "locations" : {
          "properties" : {
            "address" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            },
            "city" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            },
            "country" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            }
          }
        },
        "name" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "owner" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        }
      }
    }
  }
}
```

We can see that `locations` doesn't really have a type, but it defines internal properties and those properties do have types. This basically means that there are 5 text fields being indexed: `locations.address`, `locations.city`, `locations.country`, `name` and `owner`.

To fix the issue we need to change the `type` for `locations` in the index mapping. Since Elasticsearch doesn't allow changing an already defined type in a mapping, we will instead create a new index and define the mapping before we index the first document:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X PUT \
  -H 'Content-Type: application/json' \
  -d '{
        "mappings": {
          "properties": {
            "name": { "type": "text" },
            "owner": { "type": "text" },
            "locations": {
              "type": "nested",
              "properties": {
                "country": { "type": "text" },
                "city": { "type": "text" },
                "address": { "type": "text" }
              }
            }
          }
        }
      }' \
  https://localhost:9200/restaurants-nested?pretty
```

Notice how we used `nested` as the type for `locations`. This will efectively cause every location to become an object that will be indexed separately.

We can add the document the same way we did with our initial index:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "My little food spot",
    "owner": "Carlos",
    "locations": [
      {
        "address": "32 Some street name",
        "city": "Mytown",
        "country": "Some country"
      },
      {
        "address": "398 Another street",
        "city": "Bigger town",
        "country": "Some country"
      }
    ]
  }' \
  'https://localhost:9200/restaurants-nested/_doc?pretty'
```

After adding the document, we will effectively have three documents.

The restaurant:

```
name: My little food spot
owner: Carlos
```

The locations:

```
address: 32 Some street name
city: Mytown
country: Some country

---

address: 398 Another street
city: Bigger town
country: Some country
```

Since these are 3 documents now, searching them is not that straightforward.

We can search for a restaurant as we normally do:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "match": {
        "owner": "Carlos"
      }
    }
  }' \
  'https://localhost:9200/restaurants-nested/_search?pretty'
```

And we'll get the expected response:

```json
{
  "took" : 3,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "restaurants-nested",
        "_id" : "8DAgSoQB1JvA4r1hfWVN",
        "_score" : 0.2876821,
        "_source" : {
          "name" : "My little food spot",
          "owner" : "Carlos",
          "locations" : [
            {
              "address" : "32 Some street name",
              "city" : "Mytown",
              "country" : "Some country"
            },
            {
              "address" : "398 Another street",
              "city" : "Bigger town",
              "country" : "Some country"
            }
          ]
        }
      }
    ]
  }
}
```

But we can't search the fields in the nested documents anymore. This query will return no results:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "match": {
        "locations.city": "Mytown"
      }
    }
  }' \
  'https://localhost:9200/restaurants-nested/_search?pretty'
```

To search in nested documents we need a special syntax. To look for restaurants that have a location with a city named `Mytown`, we can use this code:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "nested": {
        "path": "locations",
        "query": {
          "match": {
            "locations.city": "Mytown"
          }
        }
      }
    }
  }' \
  'https://localhost:9200/restaurants-nested/_search?pretty'
```

To search multiple fields like we did in the previous section we can do this:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "nested": {
        "path": "locations",
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "locations.city": "Mytown"
                }
              },
              {
                "match": {
                  "locations.address": "Some"
                }
              }
            ]
          }
        }
      }
    }
  }' \
  'https://localhost:9200/restaurants-nested/_search?pretty'
```

And it will correctly match the restaurant. But now the restaurant is only returned if the match occurs within a nested document. So, this query:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "nested": {
        "path": "locations",
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "locations.city": "Mytown"
                }
              },
              {
                "match": {
                  "locations.address": "Another"
                }
              }
            ]
          }
        }
      }
    }
  }' \
  'https://localhost:9200/restaurants-nested/_search?pretty'
```

Returns nothing because there is no location with city matching `Mytown` and address matching `Another`.

## Parent child relationships

Elastic search provides [a way to create parent-child relationships](https://www.elastic.co/guide/en/elasticsearch/reference/current/parent-join.html), but it comes with multiple limitations and performance considerations. Due to those reasons we are not going to cover those kind of relationships in this article.

## Application side joins

The last alternative we are going to explore in this article is doing application side joins. In this scenario we keep our data normalized, so for the movies and actors scenario we would have two indices: `movies` and `actors`.

Our movies index would contain this data:

```json
{
  "id": 1,
  "name": "The Machinist",
  "release_year": 2004,
  "director": "Brad Anderson"
}

{
  "id": 2,
  "name": "American Psycho",
  "release_year": 2000,
  "director": "Mary Harron"
}
```

Note how our movies have an explicit id field. We need an explicit id so we can create the links between our indices.

Our actors index would look like this:

```json
{
  "name": "Christian Bale",
  "birth_year": 1974,
  "birth_country": "United Kingdom",
  "movies": [1, 2]
}

{
  "name": "Jennifer Jason Leigh",
  "birth_year": 1962,
  "birth_country": "United States",
  "movies": [1]
}

{
  "name": "Reese Witherspoon",
  "birth_year": 1976,
  "birth_country": "United States",
  "movies": [2]
}
```

This way, if we need to change the information of a movie, we only need to update one document and the same is true for actors.

With our data laid out like this, let's imagine that we want to get all movies from actors that were born in the United States. First we would make a query for all the actors where `birth_country` is `United States`. We would get back two records, which combined movies are [1, 2]. Once we have their movies, we can query the `movies` index for the ones that match those ids.

## Conclusion

Even though Elasticsearch has very unique and powerful search capabilities, dealing with relationships is very similar to any other non-relational databases. In this article we learned to deal with some of those problems.

You can find more complete code examples of the topics covered in this article in: [Searching related documents with Elasticsearch](https://github.com/soonick/ncona-code-samples/tree/master/searching-related-documents-with-elasticsearch)
