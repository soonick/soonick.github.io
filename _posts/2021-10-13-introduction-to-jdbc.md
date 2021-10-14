---
title: Introduction to JDBC
author: adrian.ancona
layout: post
date: 2021-10-13
permalink: /2021/10/introduction-to-jdbc
tags:
  - databases
  - design_patterns
  - java
  - programming
---

JDBC (Java DataBase Connectivity) is a part of the JDK (Java Development Kit) that provides methods to interact with databases.

The api can be found under [java.sql](https://docs.oracle.com/javase/8/docs/api/java/sql/package-summary.html) and [javax.sql](https://cr.openjdk.java.net/~iris/se/13/latestSpec/api/java.sql/javax/sql/package-use.html).

## Connecting to a database

In order to communicate with a database we need to first stablish a connection. The preferred way to get a database connection is using a `DataSource`:

```java
package example;

import com.mysql.cj.jdbc.MysqlDataSource;
import java.sql.Connection;
import java.sql.SQLException;
import javax.sql.DataSource;

public class JdbcExample {
  private static DataSource createDataSource() {
    final MysqlDataSource datasource = new MysqlDataSource();
    datasource.setPassword("my-secret-pw");
    datasource.setUser("root");
    datasource.setServerName("0.0.0.0");

    return datasource;
  }

  public static void main(String[] args) throws SQLException {
    final Connection con = createDataSource().getConnection();
  }
}
```

<!--more-->

We can also use a connection string instead of setting each argument independently:

```java
package example;

import com.mysql.cj.jdbc.MysqlDataSource;
import java.sql.Connection;
import java.sql.SQLException;
import javax.sql.DataSource;

public class JdbcExample {
  private static DataSource createDataSource() {
    final MysqlDataSource datasource = new MysqlDataSource();
    datasource.setURL("jdbc:mysql://0.0.0.0:3306?user=root&password=my-secret-pw");

    return datasource;
  }

  public static void main(String[] args) throws SQLException {
    final Connection con = createDataSource().getConnection();
  }
}
```

In the examples above we use `MysqlDataSource`. There are different `DataSource` implementation for different databases, the way these DataSouces are configured might also be different.

## Retrieving data

Once we have a connection, we want to get some data from our database:

```java
package example;

import com.mysql.cj.jdbc.MysqlDataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.sql.DataSource;

public class JdbcExample {
  private static DataSource createDataSource() {
    final MysqlDataSource datasource = new MysqlDataSource();
    datasource.setURL("jdbc:mysql://0.0.0.0:3306?user=root&password=my-secret-pw");

    return datasource;
  }

  public static void main(String[] args) throws SQLException {
    final Connection con = createDataSource().getConnection();

    final Statement stmt = con.createStatement();
    final ResultSet rs = stmt.executeQuery("SHOW DATABASES");

    System.out.println("Found the following databases:");
    while (rs.next()) {
      System.out.println(rs.getString(1));
    }
  }
}
```

As we see above, we can use `executeQuery` to send queries to the database. The `ResultSet` interface is not super friendly, but it allows us to get our results out. In the example above we only have one column, which we access by its index (Indexes start at `1`). We can select multiple columns and access them based on their index:

```java
package example;

import com.mysql.cj.jdbc.MysqlDataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.sql.DataSource;

public class JdbcExample {
  private static DataSource createDataSource() {
    final MysqlDataSource datasource = new MysqlDataSource();
    datasource.setURL("jdbc:mysql://0.0.0.0:3306/information_schema?user=root&password=my-secret-pw");

    return datasource;
  }

  public static void main(String[] args) throws SQLException {
    final Connection con = createDataSource().getConnection();

    final Statement stmt = con.createStatement();
    final ResultSet rs = stmt.executeQuery("SELECT table_name, checksum FROM tables LIMIT 5;");

    System.out.println("Some tables:");
    while (rs.next()) {
      System.out.println("Table name: " + rs.getString(1) + " Checksum: " + rs.getString(2));
    }
  }
}
```

Note that in the example above we connect directly to the `information_schema` database and query the `tables` table.

## Writing data

Writing data is very similar to reading; The difference is that we use `executeUpdate` instead of `executeQuery`. In this case there is no result, the return value is the number of modified or inserted rows. An exception will be thrown if there is a problem

```java
package example;

import com.mysql.cj.jdbc.MysqlDataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.sql.DataSource;

public class JdbcExample {
  private static DataSource createDataSource() {
    final MysqlDataSource datasource = new MysqlDataSource();
    datasource.setURL("jdbc:mysql://0.0.0.0:3306/test?user=root&password=my-secret-pw");

    return datasource;
  }

  public static void main(String[] args) throws SQLException {
    final Connection con = createDataSource().getConnection();

    final Statement stmt = con.createStatement();
    final int res = stmt.executeUpdate("INSERT into my_table VALUES(1, 5)");

    System.out.println(res + " records inserted successfully");
  }
}
```

## Conclusion

In this article we learned how to communicate with databases using JDBC. It's uncommon to use barebones JDBC to interact with databases in large projects, but this shows the foundation that other frameworks use to provide richer functionality.
