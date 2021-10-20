---
title: Introduction to JDBI
author: adrian.ancona
layout: post
date: 2021-10-20
permalink: /2021/10/introduction-to-jdbi
tags:
  - databases
  - design_patterns
  - java
  - programming
---

JDBI is a Java library that can be used to interact with a relational database. JDBI provides a more friendly interface than [JDBC](/2021/10/introduction-to-jdbc), which makes it easier to write code that is correct and safe.

## Getting started

The easiest way to create a JDBI instance is by passing a DataSource:

```java
final MysqlDataSource ds = new MysqlDataSource();
datasource.setURL("jdbc:mysql://0.0.0.0:3306/test?user=root&password=my-secret-pw");
final Jdbi jdbi = Jdbi.create(ds);
```

Once we have a `Jdbi` object we can use it to get `handles`. A `handle` represents an active database connection. Handles need to be closed once they are not needed, or the database might be overwhelmed by open connections. A simple example of using a handle to execute an insert operation:

<!--more-->

```java
jdbi.useHandle(handle -> {
  handle.execute("INSERT INTO my_table VALUES(?, ?)", 8, 25);
});
```

Note that the `useHandle` function gives us a handle that will automatically close the connection after the lamda finishes. It's also important to notice the placeholders in the query: `?`, which are then replaced by the values in the arguments (`8` and `25`). Using placeholders in this way prevents SQL injection attacks by automatically escaping values as needed.

A similar method exists for queries that return results:

```java
final List<Integer> values = jdbi.withHandle(handle -> {
  return handle.createQuery("SELECT the_value from my_table")
      .mapTo(Integer.class)
      .list();
});
```

In this case, `values` will hold the values returned by the query.

## Retrieving data

In the example above, we showed how to retrieve a single column from a table. In this section we are going to learn other ways to retrieve data.

A simple way to get multiple columns from a database is by getting a `List` of `Map`s:

```java
List<Map<String, Object>> results = handle
    .createQuery("SELECT the_key, the_value from my_table")
    .mapToMap()
    .list();
```

To access the value of each column we just have to use the column name as the key. For example:

```java
System.out.println(
    "The key: " + results.get(0).get("the_key") + " " +
    "The value: " + results.get(0).get("the_value"));
```

A more friendly way to retrieve results is by using `mappers`. Using `mappers` we can automatically convert a row in a result to a specific Java object.

Let's say we have a table like this:

```sql
CREATE TABLE my_table(
  the_key string not null,
  the_value string not null
);
```

We can map results from this table to an object like this one:

```java
public class MyData {
  public String theKey;
  public String theValue;
}
```

We simply need to do:

```java
handle.registerRowMapper(FieldMapper.factory(MyData.class));

List<MyData> results = handle
    .createQuery("SELECT the_key, the_value from my_table")
    .mapTo(MyData.class)
    .list();
```

Before JDBI can convert results to a specific type, we need to register that type using `registerRowMapper`. JDBI then takes care of automatically converting the snake cased SQL column names to the camel cased Java attribute names.

The `User` class above has all public attributes, which is uncommon and not recommended in the Java world. JDBI supports Java Beans and immutables, which is a better practice.

## SQL Objects

So far we have used what's called the fluent API of JDBI. There is a very widely used alternative syntax called the declarative style API.

In the declarative API, we create an interface and each method in this interface is annotated with the SQL query we want the method to execute. The body of the methods is automatically created for us based on the method signature.

To start using the declarative API we need to add `jdbi3-sqlobject` as a dependency to our project.

Once we have the dependency, we need to install the plugin into our `jdbi` object:

```java
final Jdbi jdbi = Jdbi.create(ds);
jdbi.installPlugin(new SqlObjectPlugin());
```

At the time of this writing, there are four possible annotations that we can add to a method: `@SqlBatch`, `@SqlCall`, `@SqlQuery`, or `@SqlUpdate`.

The `@SqlUpdate` annotation can be used for inserts, updates, and deletes. Let's look at an example:

```java
import org.jdbi.v3.sqlobject.statement.SqlUpdate;

public interface MyDataDao {
  @SqlUpdate("INSERT INTO my_table(the_key, the_value) VALUES(?, ?)")
  void insert(int key, int value);
}
```

To get an instance of this interface we can use the `attach` method of `handle`:

```java
final MyDataDao myDataDao = handle.attach(MyDataDao.class);
myDataDao.insert(5, 99);
```

The `insert` method will throw an exception if there is a problem with the insert.

In the example above we pass each parameter explicitly in the call to insert. It's also possible to receive an object and have the attributes of the object be used in the query:

```java
import org.jdbi.v3.sqlobject.customizer.BindFields;
import org.jdbi.v3.sqlobject.statement.SqlUpdate;

public interface MyDataDao {
  @SqlUpdate("INSERT INTO my_table(the_key, the_value) VALUES(:theKey, :theValue)")
  void insert(@BindFields MyData data);
}
```

Note the use of the `BindFields` annotation. There are multiple [annotations that provide different bindings](https://jdbi.org/#_binding_arguments_2) for different scenarios.

If we want to get results back from the database, we need to use `SqlQuery`:

```java
import java.util.List;
import org.jdbi.v3.sqlobject.statement.SqlQuery;

public interface MyDataDao {
  @SqlQuery("SELECT * FROM my_table")
  List<MyData> getAll();
}
```

Since we are returning a list of `MyData`, we need to have already registered a mapper for `MyData` as explained earlier in this article.

## Conclusion

This article shows some of the most common uses of JDBI. There are a lot of features that we didn't cover, but this gives an idea of how JDBI is used in the real world. We can always refer to [the JDBI documentation](https://jdbi.org/) to learn more about its capabilities.
