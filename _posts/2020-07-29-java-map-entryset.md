---
title: Java Map::entryset
author: adrian.ancona
layout: post
date: 2020-07-29
permalink: /2020/07/java-map-entryset/
tags:
  - data_structures
  - java
  - programming
---

The [entryset](https://docs.oracle.com/javase/8/docs/api/java/util/Map.html#entrySet--) method of a Java [Map](https://docs.oracle.com/javase/8/docs/api/java/util/Map.html) is used to provide a Set "view" of the Map. Since `Map` is not iterable, this method provides a way to iterate over the key-value pairs. Let's look at it in action:

```java
import java.util.HashMap;
import java.util.Set;

class Streams {
  public static void main(String[] args) {
    HashMap<String, String> map = new HashMap<String, String>();
    map.put("hello", "world");
    map.put("hola", "mundo");

    Set<HashMap.Entry<String, String>> set = map.entrySet();
    for (HashMap.Entry<String, String> entry : set) {
      System.out.println("Key: " + entry.getKey() + " Value: " + entry.getValue());
    }
  }
}
```

The output of this program is:

```
Key: hello Value: world
Key: hola Value: mundo
```
