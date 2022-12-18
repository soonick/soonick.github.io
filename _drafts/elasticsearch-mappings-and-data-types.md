---
title: Elasticsearch Mappings and Data Types
author: adrian.ancona
layout: post
# date: 2022-10-26
# permalink: /2022/10/introduction-to-elasticsearch
tags:
  - architecture
  - data_structures
  - databases
---

In my last article we learned how to [get started with Elasticsearch](/2022/10/introduction-to-elasticsearch). In this article we are going to take a deeper look into the data types supported by Elasticsearch and why they matter.

## Mappings

Each Elasticsearch index contains exactly one mapping. A mapping defines the data types (string, boolean, etc.) for all the fields in all the documents in that index.

Every time we save a new document in an index, Elasticsearch will look at all the fields in that document and try to find the data type (defined in the mapping) for each of them. If a field is not defined in the mapping, Elasticsearch will automatically choose a data type for that field based on the value of the field.

<!--more-->

Let's start by creating an empty index:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X PUT \
  https://localhost:9200/indexone?pretty
```

Since we didn't specify any mappings and we haven't added any documents, the mappings will be empty. To get the mappings:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X GET \
  https://localhost:9200/indexone/_mapping?pretty
```

The response should be:

```json
{
  "indexone" : {
    "mappings" : { }
  }
}
```

As mentioned before, creating a document will automatically create mappings for the fields on that document. Let's add a new document to our index:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "name": "carlos",
        "age": 4
      }' \
  'https://localhost:9200/indexone/_doc?pretty'
```

If we inspect the mappings, we will see that new fields have been added:

```json
{
  "indexone" : {
    "mappings" : {
      "properties" : {
        "age" : {
          "type" : "long"
        },
        "name" : {
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

We can see that the property (field) `age` was set to the type `double`, since it was a number in our document. For the `name` field, `text` was chosen since it was a text field. We'll explain the `fields` part under `name` later in the article.

Once a mapping is set we can't insert documents that don't match the mapping. For example, if we try to insert a document where `age` is not a `double`:

```bash
curl --cacert http_ca.crt -u elastic:$ES_PASS \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{
        "name": "carlos",
        "age": "four"
      }' \
  'https://localhost:9200/indexone/_doc?pretty'
```

We'll get an error:

```json
{
  "error" : {
    "root_cause" : [
      {
        "type" : "mapper_parsing_exception",
        "reason" : "failed to parse field [age] of type [long] in document with id 'gyT8KYQBwbwr_DhKoQTQ'. Preview of field's value: 'four'"
      }
    ],
    "type" : "mapper_parsing_exception",
    "reason" : "failed to parse field [age] of type [long] in document with id 'gyT8KYQBwbwr_DhKoQTQ'. Preview of field's value: 'four'",
    "caused_by" : {
      "type" : "illegal_argument_exception",
      "reason" : "For input string: \"four\""
    }
  },
  "status" : 400
}
```

Since changing a field type after it has already been mapped is not easy we might want to define a mapping when we create an index:

```bash
```
