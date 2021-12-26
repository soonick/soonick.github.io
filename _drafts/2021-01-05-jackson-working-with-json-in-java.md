---
title: Jackson - Working with JSON in Java
author: adrian.ancona
layout: post
date: 2021-01-05
permalink: /2021/12/jackson-working-with-json-in-java
tags:
  - data_structures
  - java
  - programming
---

[Jackson](https://github.com/FasterXML/jackson) is a set of tools for working with JSON data in Java. [Jackson](https://github.com/FasterXML/jackson) contains a wealth of features, so don't expect this article to cover them all.

## Parsing arbitrary JSON strings

To get started with Jackson, let's look at how we can parse an arbitrary JSON string:

```java
package example;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Exampler {
  public static void main(String args[]) throws Exception {
    String json = "{\"hello\":\"world\"}";
    JsonNode root = new ObjectMapper().readTree(json);
    if (root.has("hello")) {
      System.out.println("Value of hello is: " + root.get("hello"));
    }
  }
}
```

The example above prints:

```bash
Value of hello is: "world"
```

<!--more-->

`ObjectMapper` provides functionality for serializing and deserializing from JSON.

In the example above we serialize a JSON string to a generic `JsonNode`. `JsonNode` allows us to deal with JSON strings that come in any shape. It provides methods for inspecting and traversing the JSON data.

When we don't know the shape of a JSON string, `JsonNode` makes it possible to traverse the data programmatically. Later in this article we'll see how we can parse JSON strings into custom Java classes when we know the shape of the JSON.

## Serializing objects to JSON

In this section we'll learn how we can create a JSON string based on a Java object. Let's say we have this class:

```java
package example;

public class Person {
  public String name;
  public int age;
}
```

We can serialize an instance of this class like so:

```java
package example;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Exampler {
  public static void main(String args[]) throws Exception {
    Person adrian = new Person();
    adrian.name = "Adrian";
    adrian.age = 35;

    System.out.println(new ObjectMapper().writeValueAsString(adrian));
  }
}
```

The resulting string is:

```json
{"name":"Adrian","age":35}
```

## Deserializing JSON string to custom object

We already saw how to deserialize a JSON string to a `JsonNode`. Let's this time serialize a JSON string to our `Person` class:

```java
package example;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Exampler {
  public static void main(String args[]) throws Exception {
    String json = "{\"name\":\"Adrian\",\"age\":35}";

    Person adrian = new ObjectMapper().readValue(json, Person.class);
  }
}
```

Using the `readValue` method we can parse the String into a known object and get type safety in return.

### Unrecognized properties

By default, when a JSON string contains fields that are not defined in our object, we'll get an exception. Let's say we try to run this code:

```java
package example;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Exampler {
  public static void main(String args[]) throws Exception {
    String json = "{\"name\":\"Adrian\",\"age\":35,\"residency\":\"mexico\"}";

    Person adrian = new ObjectMapper().readValue(json, Person.class);
  }
}
```

This time, the JSON string contains an extra field: `residency`. Since this field is not defined in our `Person`, Jackson will throw an exception:

```
Exception in thread "main" com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException: Unrecognized field "residency" (class example.Person), not marked as ignorable (2 known properties: "name", "age"])
```

The message is descriptive and hints us to a solution: Mark the field as ignorable.

It's common that JSON strings will include fields we don't care about or that new fields are added in the future, so handling unknown fields is important.

To fix the problem we just need to add an annotation to our `Person` class:

```java
package example;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Person {
  public String name;
  public int age;
}
```

### Json arrays

Sometimes the json we want to parse is an array, instead of a single object. In these cases, we can use `TypeReference` to tell Jackson that it should serialize it to a `List<T>`:

```java
package example;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;

public class Exampler {
  public static void main(String args[]) throws Exception {
    String json = "[{\"name\":\"Adrian\",\"age\":35}]";

    List<Person> people = new ObjectMapper().readValue(
      json,
      new TypeReference<List<Person>>(){}
    );
  }
}
```

## Conclusion

In this article we learned how to deserialize JSON strings into objects that can be used in our Java code, as well as how to serialize Java objects to JSON strings.

If your case is more complex than the examples shown above, Jackson provides features to customize the way things are serialized and deserialized that should help you solve your problem.
