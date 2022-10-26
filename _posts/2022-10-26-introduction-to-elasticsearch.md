---
title: Introduction to Elasticsearch
author: adrian.ancona
layout: post
date: 2022-10-26
permalink: /2022/10/introduction-to-elasticsearch
tags:
  - architecture
  - data_structures
  - databases
---

## Why do I need a search engine?

Search is everywhere. We use Google to find websites, we search for products in Amazon, we use keywords to find videos on Youtube, etc.

From the consumer side, it's a great way to get the information we need quickly. From the producer side, it means that we need to make sure we provide this interface the users have come to expect.

Relational or document databases allow us to create indices and find pieces of information based on ids, but they don't work for searching for various keywords inside a text or when there are typos or synonyms involved. This is where search engines become useful; when we need to index unstructured data and offer flexible search capabilities.

<!--more-->

## What's Elasticsearch?

Elasticsearch is one of the most popular search engines currently available. They recently changed their license to one that forbids cloud providers from offering it as a service, but it can be used freely for any other use case.

Another important feature of Elasticsearch is its "elasticity", which means it can be horizontally scaled to accommodate larger loads.

## What's Lucene?

[Lucene](https://lucene.apache.org/) is an open source search engine library that is used by Elasticsearch.

Lucene provides many of the core features needed in a world class search engine: advanced indexing, ranked search, fuzzy search, search by multiple terms and fields, just to name a few.

## Installing Elasticsearch

The most up-to-date instructions can be found in the official [Installing Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/8.4/install-elasticsearch.html) documentation. In this section I'm going to show how to start a single node cluster using Docker.

First we need to create a network to be used by our cluster:

```bash
docker network create elastic
```

Then we can start our cluster using that network:

```bash
docker run --name es01 --net elastic \
    -p 9200:9200 -p 9300:9300 \
    -it docker.elastic.co/elasticsearch/elasticsearch:8.4.3
```

We will see a lot of logs while Elasticsearch is starting up and eventually we will get a message similar to this one:

```bash
-> Elasticsearch security features have been automatically configured!
-> Authentication is enabled and cluster connections are encrypted.

->  Password for the elastic user (reset with `bin/elasticsearch-reset-password -u elastic`):
  GzAfOPy=u5jbG1rAmTOD

->  HTTP CA certificate SHA-256 fingerprint:
  3fee1ec275d3fbd663732e17678e6a63fb358af4c776082ce916b0d4f9f1e938

->  Configure Kibana to use this cluster:
* Run Kibana and click the configuration link in the terminal when Kibana starts.
* Copy the following enrollment token and paste it into Kibana in your browser (valid for the next 30 minutes):
  eyJ2ZXIiOiI4LjQuMyIsImFkciI6WyIxNzIuMTguMC4yOjkyMDAiXSwiZmdyIjoiM2ZlZTFlYzI3NWQzZmJkNjYzNzMyZTE3Njc4ZTZhNjNmYjM1OGFmNGM3NzYwODJjZTkxNmIwZDRmOWYxZTkzOCIsImtleSI6InFDRTg0b01CUUpoUDRWd2ZLbnY4OmV0NHhVMHhBVEhTdGVWZTdjVWZRX3cifQ==

-> Configure other nodes to join this cluster:
* Copy the following enrollment token and start new Elasticsearch nodes with `bin/elasticsearch --enrollment-token <token>` (valid for the next 30 minutes):
  eyJ2ZXIiOiI4LjQuMyIsImFkciI6WyIxNzIuMTguMC4yOjkyMDAiXSwiZmdyIjoiM2ZlZTFlYzI3NWQzZmJkNjYzNzMyZTE3Njc4ZTZhNjNmYjM1OGFmNGM3NzYwODJjZTkxNmIwZDRmOWYxZTkzOCIsImtleSI6InFpRTg0b01CUUpoUDRWd2ZLM3ROOnJYOUlfNm1CVFpDWjEyTVRSbFRJTEEifQ==

  If you're running in Docker, copy the enrollment token and run:
  `docker run -e "ENROLLMENT_TOKEN=<token>" docker.elastic.co/elasticsearch/elasticsearch:8.4.3`
```

We need to keep this information somewhere safe in case we want to expand our cluster.

To verify our cluster is working correctly we need the CA certificate for the cluster. Open a new terminal and run this command:

```bash
docker cp es01:/usr/share/elasticsearch/config/certs/http_ca.crt .
```

Then we can make a request:

```bash
curl --cacert http_ca.crt -u elastic https://localhost:9200
```

We will be prompted for the password for the cluster, which is the one marked with `Password for the elastic user` above (in my case is `GzAfOPy=u5jbG1rAmTOD`).

The response will be some information about the cluster:

```json
{
  "name" : "86142542cf14",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "SqivlKCPQMWqwPJEUxRazw",
  "version" : {
    "number" : "8.4.3",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "42f05b9372a9a4a470db3b52817899b99a76ee73",
    "build_date" : "2022-10-04T07:17:24.662462378Z",
    "build_snapshot" : false,
    "lucene_version" : "9.3.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

If we get an error similar to:

```bash
max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```

We can fix it by using this command:

```bash
sysctl -w vm.max_map_count=262144
```

And adding this line to `/etc/sysctl.conf`:

```
vm.max_map_count=262144
```

## Documents and Indices

> There used to be a concept of `type` in older versions of Elasticsearch, but it doesn't exist anymore. We can read [the reasons types were removed](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/removal-of-types.html).


In Elasticsearch all `documents` belong to an `index`. We could put all our documents in a single index but here are some reasons we might want to have multiple indices:

- **Organize data** - Different indices can contain different types of data. For example: users, invoices, etc.
- **Different settings** - We can tune settings like number of shards on a per index basis. This allows us to choose different settings that work better depending on the usage patterns for that specific index.
- **Mappings** - Each index keeps track of all the fields it has seen and the data type of that field. The data type used per field determines how the index works and can have a big impact on performance. We can set and modify data types for fields so they perform better.

Elasticsearch stores data as unstructured JSON documents. `Unstructured` refers to the fact that different documents in the same index can have different shapes. For example, these could be two documents in the same index:

```bash
{
  "id": "1234",
  "username": "jose",
  "type": "manager",
  "office_location": "Orlando, Florida, USA",
  "num_reportees": 5
}

{
  "id": "9999",
  "username": "carlos",
  "type": "sales representative",
  "manager": "felipe"
}
```

We can see that the first record contains some fields the second record doesn't have and viceversa. This is not a problem in Elasticsearch.

## The REST API

One of the selling points of Elasticsearch is that it provides a REST API that makes it easy to use with most programming languages. We already used this API once in this article when we called:

```
curl --cacert http_ca.crt -u elastic https://localhost:9200
```

In this section we are going to explore other common commands.

Let's put our password in an environment variable so we are not prompted for it after each command:

```
ES_PASS='<replace with password>'
```

We can create a new index using:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X PUT \
  https://localhost:9200/our-index
```

To list all the indices we can use this command:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  'https://localhost:9200/_aliases?pretty'

{
  "our-index" : {
    "aliases" : { }
  },
  ".security-7" : {
    "aliases" : {
      ".security" : {
        "is_hidden" : true
      }
    }
  }
}
```

In the URL above I added `?pretty` so the output would be nicely formatted in the terminal (line breaks and indentation).

Another option to get all indices is:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  'https://localhost:9200/_stats/indexing?pretty'

{
  "indices" : {
    "our-index" : {
      "uuid" : "T6P5x4AuTaSSkTPecxt7zA",
      "health" : "yellow",
      "status" : "open",
      "primaries" : {
        "indexing" : {
          "index_total" : 0,
          "index_time_in_millis" : 0,
          "index_current" : 0,
          "index_failed" : 0,
          "delete_total" : 0,
          "delete_time_in_millis" : 0,
          "delete_current" : 0,
          "noop_update_total" : 0,
          "is_throttled" : false,
          "throttle_time_in_millis" : 0
        }
      },
      "total" : {
        "indexing" : {
          "index_total" : 0,
          "index_time_in_millis" : 0,
          "index_current" : 0,
          "index_failed" : 0,
          "delete_total" : 0,
          "delete_time_in_millis" : 0,
          "delete_current" : 0,
          "noop_update_total" : 0,
          "is_throttled" : false,
          "throttle_time_in_millis" : 0
        }
      }
    }
  },
  ...
}
```

If we wanted to delete the index we could use this command:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X DELETE \
  https://localhost:9200/our-index?pretty
```

Let's now add a document to our index:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "cerveza": 6,
        "taco": 4
      }' \
  'https://localhost:9200/our-index/_doc?pretty'

{
  "_index" : "our-index",
  "_id" : "PaBcAoQBNyD4GzZMK4_1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}
```

This means the data was saved successfully. The field `_id` is also of interest since this is the unique identifier for our document. Since we didn't suply one specifically, one was created automatically (`PaBcAoQBNyD4GzZMK4_1`). We can specify an id for our document like this:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "ceviche": 15,
        "cerveza": 5
      }' \
  'https://localhost:9200/our-index/_doc/9999?pretty'

{
  "_index" : "our-index",
  "_id" : "9999",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 1,
  "_primary_term" : 1
}
```

This time the `_id` is `9999` as specified in our request (`https://localhost:9200/our-index/_doc/9999?pretty`).

Now we have two documents in our index. We can see all the documents in the index with this command:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
        "query": {
            "match_all": {}
        }
    }' \
  'https://localhost:9200/our-index/_search?pretty'

{
  "took" : 6,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "our-index",
        "_id" : "PaBcAoQBNyD4GzZMK4_1",
        "_score" : 1.0,
        "_source" : {
          "cerveza" : 6,
          "taco" : 4
        }
      },
      {
        "_index" : "our-index",
        "_id" : "9999",
        "_score" : 1.0,
        "_source" : {
          "ceviche" : 15,
          "cerveza" : 5
        }
      }
    ]
  }
}
```

We can see that it not only returns the documents (under the `hits` attribute), it also returns some other information. The `took` field tells us that it took `6` milliseconds to return the results. The `score` tells us how good was the match. A higher number means a better match.

We can also retrieve a specific document if we know the id:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  'https://localhost:9200/our-index/_doc/9999?pretty'

{
  "_index" : "our-index",
  "_id" : "9999",
  "_version" : 1,
  "_seq_no" : 1,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "ceviche" : 15,
    "cerveza" : 5
  }
}
```

## Searching

Elasticsearch is meant to be used for searching, so let's see it in action. First of all, let's create a new index called products:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X PUT \
  https://localhost:9200/products
```

And add some products to it:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "name": "The best book in the world",
        "category": "books",
        "description": "The best book in the world talks about many things that everybody finds interesting"
      }' \
  'https://localhost:9200/products/_doc/1?pretty'

curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "name": "Just average",
        "category": "books",
        "description": "This book can entertain you for a bit, but there are better ones"
      }' \
  'https://localhost:9200/products/_doc/2?pretty'


curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "name": "Cleaner robot",
        "category": "electronics",
        "description": "Cleans the house, does laundry, washes dishes, irons"
      }' \
  'https://localhost:9200/products/_doc/3?pretty'

curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "name": "Smart speaker",
        "category": "electronics",
        "description": "Plays ads, music and can talk to you when you feel lonely"
      }' \
  'https://localhost:9200/products/_doc/4?pretty'
```

To search inside an index we use this URL:

```bash
https://localhost:9200/<index>/_search
```

The search terms go in the request body. If we only want to get the documents where `category` is `books`, we can put this in the request body:

```json
{
  "query": {
    "match": {
      "category": "books"
    }
  }
}
```

If we put the URL and the body together, we get:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
        "query": {
          "match": {
            "category": "books"
          }
        }
      }' \
  'https://localhost:9200/products/_search?pretty'

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
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 0.6931471,
    "hits" : [
      {
        "_index" : "products",
        "_id" : "1",
        "_score" : 0.6931471,
        "_source" : {
          "name" : "The best book in the world",
          "category" : "books",
          "description" : "The best book in the world talks about many things that everybody finds interesting"
        }
      },
      {
        "_index" : "products",
        "_id" : "2",
        "_score" : 0.6931471,
        "_source" : {
          "name" : "Just average",
          "category" : "books",
          "description" : "This book can entertain you for a bit, but there are better ones"
        }
      }
    ]
  }
}
```

Let's now try to search for the word `books` in the `description` field:


```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
        "query": {
          "match": {
            "description": "books"
          }
        }
      }' \
  'https://localhost:9200/products/_search?pretty'

{
  "took" : 5,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 0,
      "relation" : "eq"
    },
    "max_score" : null,
    "hits" : [ ]
  }
}
```

We get `0` matches because none of the descriptions includes the term `books`. In the other hand, they contain the term `book`, so we can use a fuzzy search to find them:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
        "query": {
          "match": {
            "description": {
              "query": "books",
              "fuzziness": "AUTO"
            }
          }
        }
      }' \
  'https://localhost:9200/products/_search?pretty'

{
  "took" : 26,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 0.4981795,
    "hits" : [
      {
        "_index" : "products",
        "_id" : "2",
        "_score" : 0.4981795,
        "_source" : {
          "name" : "Just average",
          "category" : "books",
          "description" : "This book can entertain you for a bit, but there are better ones"
        }
      },
      {
        "_index" : "products",
        "_id" : "1",
        "_score" : 0.48209476,
        "_source" : {
          "name" : "The best book in the world",
          "category" : "books",
          "description" : "The best book in the world talks about many things that everybody finds interesting"
        }
      }
    ]
  }
}
```

To search multiple fields we can use something like this:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  -H 'Content-Type: application/json' \
  -d '{
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "category": "books"
                }
              },
              {
                "match": {
                  "name": "average"
                }
              }
            ]
          }
        }
      }' \
  'https://localhost:9200/products/_search?pretty'

{
  "took" : 80,
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
    "max_score" : 2.087221,
    "hits" : [
      {
        "_index" : "products",
        "_id" : "2",
        "_score" : 2.087221,
        "_source" : {
          "name" : "Just average",
          "category" : "books",
          "description" : "This book can entertain you for a bit, but there are better ones"
        }
      }
    ]
  }
}
```

There are too many ways to search for data to cover all of them in this article. I might cover some advanced scenarios in future articles, but the official [search API documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html) covers all the available options.

## Conclusion

In this article we went from not knowing anything about Elasticsearch from being able to start a test cluster, save some data and search on that data. The setup we used in this article is not suitable for production and there are many topics that we didn't cover so I plan to write a little more about Elasticsearch in future articles.

You can see a more succinct list of all the commands used in this article in: [Introduction to Elasticsearch code samples](https://github.com/soonick/ncona-code-samples/tree/master/introduction-to-elasticsearch).
