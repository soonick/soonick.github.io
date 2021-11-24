---
title: Introduction to GraphQL
author: adrian.ancona
layout: post
date: 2021-11-24
permalink: /2021/11/introduction-to-graphql
tags:
  - architecture
  - java
  - json
  - programming
  - server
---

GraphQL advertises itself as a query language for APIs. To understand what this means, let's compare it with REST.

In REST, we usually have endpoints that give us information about a resource, for example: `GET /user/1` could return something like:

```json
{
  "id": 1,
  "name": "Jose",
  "phone": "999-888-7777"
}
```

We have multiple endpoints we can use to get different information about different resources. If we need an endpoint that contains information from different resources, we sometimes create endpoints for specific purposes: `GET /user/1?includeParents=true`. Which could return something like this:

```json
{
  "id": 1,
  "name": "Jose",
  "phone": "999-888-7777"
  "parents": {
    "mom": "Maria",
    "dad": "Carlos"
  }
}
```

<!--more-->

For each endpoint, we usually create a route in our server and write the code necessary to get the information we need.

Often the code consists mostly of making calls to other services and stitching the data together. GraphQL provides a framework that can make these tasks easier for us.

## GraphQL Schema

A GraphQL server is defined using a schema file. In this file, we define the types our service supports and queries that are possible against these types.

A GraphQL schema file looks like this:

```graphql
type Query {
  people: [Person]
}

type Person {
  id: ID
  name: String
  phone: String
}
```

The `Query` type is special in that it's mandatory and it defines the entry point for GraphQL queries. By defining a `people` field of type `[Person]` in `Query` we are saying that the `people` query returns a list of `Person`s.

The `Person` type is defined by 3 fields that use scalar GraphQL types. The available scalar types are: `Int`, `Float`, `String`, `Boolean` and `ID` (`ID` is serialized the same way as `String`).

Now that we know how to define our API, let's build a server.

## Starting a GraphQL server

There are many [libraries that can help us start a GraphQL server](https://graphql.org/code/). In this article, I'm going to show how to do it with Java and Spring using [graphql-java](https://github.com/graphql-java/graphql-java).

I'm going to build my project with Bazel, so you might find my [building a Spring Boot server with Bazel](/2021/11/building-a-spring-boot-server-with-bazel) article useful to get you started.

We are going to need a folder with this structure:

```
├── BUILD
├── src
│   └── main
│       ├── java
│       │   └── com
│       │       └── example
│       │           └── demo
│       │               ├── DemoApplication.java
│       │               └── GraphQLProvider.java
│       └── resources
│           └── schema.graphqls
└── WORKSPACE
```

Our `WORKSPACE` file installs the required GraphQL and Spring artifacts:

```python
load('@bazel_tools//tools/build_defs/repo:http.bzl', 'http_archive')

RULES_JVM_EXTERNAL_TAG = '4.1'
RULES_JVM_EXTERNAL_SHA = 'f36441aa876c4f6427bfb2d1f2d723b48e9d930b62662bf723ddfb8fc80f0140'

http_archive(
  name = 'rules_jvm_external',
  strip_prefix = 'rules_jvm_external-%s' % RULES_JVM_EXTERNAL_TAG,
  sha256 = RULES_JVM_EXTERNAL_SHA,
  url = 'https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip' % RULES_JVM_EXTERNAL_TAG,
)

load('@rules_jvm_external//:defs.bzl', 'maven_install')

maven_install(
  artifacts = [
    'com.google.guava:guava:26.0-jre',
    'com.graphql-java:graphql-java-spring-boot-starter-webmvc:1.0',
    'com.graphql-java:graphql-java:11.0',
    'javax.annotation:javax.annotation-api:1.3.2',
    'org.springframework.boot:spring-boot-autoconfigure:2.1.3.RELEASE',
    'org.springframework.boot:spring-boot-starter-web:2.1.3.RELEASE',
    'org.springframework.boot:spring-boot:2.1.3.RELEASE',
    'org.springframework:spring-beans:5.1.5.RELEASE',
    'org.springframework:spring-context:5.1.5.RELEASE',
    'org.springframework:spring-web:5.1.5.RELEASE',
  ],
  repositories = [
    'https://repo1.maven.org/maven2',
  ],
  fetch_sources = True,
)
```

Our `BUILD` file uses those dependencies to build our server:

```python
java_binary(
  name = 'app',
  main_class = 'com.example.demo.DemoApplication',
  srcs = glob(['src/**/*.java']),
  resources = glob(["src/main/resources/**/*"]),
  deps = [
    '@maven//:com_google_guava_guava',
    '@maven//:com_graphql_java_graphql_java',
    '@maven//:com_graphql_java_graphql_java_spring_boot_starter_webmvc',
    '@maven//:javax_annotation_javax_annotation_api',
    '@maven//:org_springframework_boot_spring_boot',
    '@maven//:org_springframework_boot_spring_boot_autoconfigure',
    '@maven//:org_springframework_boot_spring_boot_starter_web',
    '@maven//:org_springframework_spring_beans',
    '@maven//:org_springframework_spring_context',
    '@maven//:org_springframework_spring_web',
  ],
)
```

We put our schema definition in `schema.graphqls`:

```json
type Query {
  people: [Person]
}

type Person {
  id: ID
  name: String
  phone: String
}
```

`DemoApplication.java` just takes care of initializing our Spring Boot app:

```java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
  public static void main(String[] args) {
    SpringApplication.run(DemoApplication.class, args);
  }
}
```

And finally, the magic happens in `GraphQLProvider.java`:

```java
package com.example.demo;

import static graphql.schema.idl.TypeRuntimeWiring.newTypeWiring;

import com.google.common.base.Charsets;
import com.google.common.collect.ImmutableMap;
import com.google.common.io.Resources;
import graphql.GraphQL;
import graphql.schema.DataFetcher;
import graphql.schema.GraphQLSchema;
import graphql.schema.idl.RuntimeWiring;
import graphql.schema.idl.SchemaGenerator;
import graphql.schema.idl.SchemaParser;
import graphql.schema.idl.TypeDefinitionRegistry;
import java.io.IOException;
import java.net.URL;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import javax.annotation.PostConstruct;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

@Component
public class GraphQLProvider {
  private static final List<Map<String, String>> people = Arrays.asList(
    ImmutableMap.of("id", "1",
            "name", "Carlos",
            "phone", "111-111-1111"),
    ImmutableMap.of("id", "2",
            "name", "Jose",
            "phone", "999-999-9999")
  );

  private GraphQL graphQL;

  @Bean
  public GraphQL graphQL() {
    return graphQL;
  }

  @PostConstruct
  public void init() throws IOException {
    URL url = Resources.getResource("schema.graphqls");
    String sdl = Resources.toString(url, Charsets.UTF_8);
    GraphQLSchema graphQLSchema = buildSchema(sdl);
    this.graphQL = GraphQL.newGraphQL(graphQLSchema).build();
  }

  private GraphQLSchema buildSchema(String sdl) {
    TypeDefinitionRegistry typeRegistry = new SchemaParser().parse(sdl);
    RuntimeWiring runtimeWiring = buildWiring();
    SchemaGenerator schemaGenerator = new SchemaGenerator();
    return schemaGenerator.makeExecutableSchema(typeRegistry, runtimeWiring);
  }

  public DataFetcher getPeopleDataFetcher() {
    return dataFetchingEnvironment -> {
        return people;
    };
  }

  private RuntimeWiring buildWiring() {
    return RuntimeWiring.newRuntimeWiring()
            .type(newTypeWiring("Query").dataFetcher("people", getPeopleDataFetcher()))
            .build();
  }
}
```

We can run the application using:

```sh
bazel run :app
```

And we can test it using curl:

```sh
curl -g \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{people{id name}}"}' \
  http://localhost:8080/graphql
```

The result will be:

```json
{"data":{"people":[{"id":"1","name":"Carlos"},{"id":"2","name":"Jose"}]}}
```

We'll talk a little more about how to query data later in this article. Before that, we're going to take a closer look into the code we just ran.

The magic starts in the `init` method:

```java
@PostConstruct
public void init() throws IOException {
  URL url = Resources.getResource("schema.graphqls");
  String sdl = Resources.toString(url, Charsets.UTF_8);
  GraphQLSchema graphQLSchema = buildSchema(sdl);
  this.graphQL = GraphQL.newGraphQL(graphQLSchema).build();
}
```

It starts by loading the `schema.graphqls` file into a string. This string is used to build a our GraphQL schema and intialize our GraphQL server.

The `buildSchema` method ties the schema and the corresponding wiring together:

```java
private GraphQLSchema buildSchema(String sdl) {
  TypeDefinitionRegistry typeRegistry = new SchemaParser().parse(sdl);
  RuntimeWiring runtimeWiring = buildWiring();
  SchemaGenerator schemaGenerator = new SchemaGenerator();
  return schemaGenerator.makeExecutableSchema(typeRegistry, runtimeWiring);
}
```

Wiring in this context refers to matching the different GraphQL queries to their implementation. This mapping is done in `buildWiring`:

```java
private RuntimeWiring buildWiring() {
  return RuntimeWiring.newRuntimeWiring()
          .type(newTypeWiring("Query").dataFetcher("people", getPeopleDataFetcher()))
          .build();
}
```

We can see that this method matches the `people` query with `getPeopleDataFetcher`, which returns the `DataFetcher` for getting all `people`.

In this example we are not using any database, so the data fetcher consists of just returning a `List` of `Map`s that represent the fields of a `Person`.

```java
public DataFetcher getPeopleDataFetcher() {
  return dataFetchingEnvironment -> {
      return people;
  };
}
```

## Querying

We performed one query in the previous section using curl:

```sh
curl -g \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{people{id name}}"}' \
  http://localhost:8080/graphql
```

We are going to focus on the data we are sending to the `/graphql` endpoint:

```json
{"query":"{people{id name}}"}'
```

If we look closely, we'll notice that it's a JSON with the key `query` and the value `{people{id name}}`. The `query` key identifies the query we are making. The value is the GraphQL query. We can see our query here with some formatting to make it easier to read:

```graphql
{
  people {
    id
    name
  }
}
```

`people` is the name of the operation we are performing, as defined in our GraphQL schema:

```graphql
type Query {
  people: [Person]
}
```

Since the people operation returns a list of `Person` (`[Person]`), we can also specify exactly which fields we want. In the example above we retrieve `id` and `name`, but we could have retrieved any combination of the available fields.

Let's add the ability to get a person by `id`. First we add the operation to the schema:

```graphql
type Query {
  person(id: ID): Person
  people: [Person]
}

type Person {
  id: ID
  name: String
  phone: String
}
```

We added the `person(id: ID): Person` line. The `(id: ID)` part tells us that this operation accepts an `id` argument.

This is what we need to add to our server to support this operation:

```java
  ...

  public DataFetcher getPersonDataFetcher() {
    return dataFetchingEnvironment -> {
        final String personId = dataFetchingEnvironment.getArgument("id");
        return people
                .stream()
                .filter(person -> person.get("id").equals(personId))
                .findFirst()
                .orElse(null);
    };
  }

  private RuntimeWiring buildWiring() {
    return RuntimeWiring.newRuntimeWiring()
            .type(newTypeWiring("Query").dataFetcher("person", getPersonDataFetcher()))
            .type(newTypeWiring("Query").dataFetcher("people", getPeopleDataFetcher()))
            .build();
  }

  ...
```

To use this new operation, we can use this query:

```json
{
  person(id: "1") {
    name
    phone
  }
}
```

This basically means: Give me the `name` and `phone` for person with `id` equal to `1`.

## Mutations

We have learned how to get data, but we also need to modify data. Let's add an `updatePerson` operation to our schema:

```graphql
type Query {
  person(id: ID): Person
  people: [Person]
}

type Mutation {
  updatePerson(input: PersonInput!): Person
}

type Person {
  id: ID
  name: String
  phone: String
}

input PersonInput {
  id: ID!
  name: String!
  phone: String!
}
```

There are a few things to notice here. First of all, our mutation operation is inside the `Mutation` type, as opposed to the read operations, which are under the `Query` type.

The definition of the `updatePerson` operation, is very similar to the one for reading a `person`. One small difference is that we have an exclamation mark (`!`) after the name of our argument. This simply means that the argument is mandatory.

Another important difference is that `PersonInput` is not a `type`, but an `Input`. This is necessary for mutation operations.

Making a mutation request is also a little different. We can use this curl command:

```sh
curl -g \
 -X POST \
 -H "Content-Type: application/json" \
 -d '{"query":"mutation {updatePerson(input: {id: \"1\", name: \"beto\", phone: \"123-456-7890\"}){name phone}}"}' \
 http://localhost:8080/graphql
```

Even though it's a mutation, we still need to use the `query` key in our json. To distinguish a mutation from a read, we prefix our query with the `mutation` keyword. Our mutation query looks like this:

```sh
mutation {
  updatePerson(input: {
    id: "1",
    name: "beto",
    phone: "123-456-7890"
  }) {
    name
    phone
  }
}
```

We also need update our code:

```java
...

// Since we want to be able to edit the data, we stop using Immutables
private static final List<Map<String, String>> people;
static {
  final Map<String, String> carlos = new HashMap<>();
  carlos.put("id", "1");
  carlos.put("name", "Carlos");
  carlos.put("phone", "111-111-1111");

  final Map<String, String> jose = new HashMap<>();
  jose.put("id", "2");
  jose.put("name", "Jose");
  jose.put("phone", "222-222-2222");

  people = Arrays.asList(carlos, jose);
}

...

public DataFetcher updatePersonDataFetcher() {
  return dataFetchingEnvironment -> {
    // Types are passed as maps
    final Map<String, String> newPerson = dataFetchingEnvironment.getArgument("input");

    // Find the person
    final Map<String, String> currentPerson = people
            .stream()
            .filter(person -> person.get("id").equals(newPerson.get("id")))
            .findFirst()
            .orElse(null);

    // This endpoint is just for editing. If the person is not found, do nothing
    if (currentPerson == null) {
      return null;
    }

    // Modify the person
    currentPerson.put("name", newPerson.get("name"));
    currentPerson.put("phone", newPerson.get("phone"));

    return currentPerson;
  };
}

private RuntimeWiring buildWiring() {
  return RuntimeWiring.newRuntimeWiring()
          .type(newTypeWiring("Query").dataFetcher("person", getPersonDataFetcher()))
          .type(newTypeWiring("Query").dataFetcher("people", getPeopleDataFetcher()))
          .type(newTypeWiring("Mutation").dataFetcher("updatePerson", updatePersonDataFetcher()))
          .build();
}

...
```

We can see that registering a mutation is very similar to a query. We only need to use the `Mutation` type wiring:

```java
.type(newTypeWiring("Mutation").dataFetcher("updatePerson", updatePersonDataFetcher()))
```

Our data fetcher does the data update and then returns the new value as with any other query operation.

## Conclusion

In this article we learned how to set up a GraphQL server and make simple queries and mutations.

There is a lot of functionality that wasn't covered, but this should help you get started so you can try examples in [the official documentation](https://graphql.org/learn/).
