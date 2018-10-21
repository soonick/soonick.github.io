---
id: 1747
title: Using Android preferences for storage
date: 2013-09-12T04:31:21+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1747
permalink: /2013/09/using-android-preferences-for-storage/
tags:
  - android
  - java
  - mobile
  - programming
---
Android provides a few ways to persist information between sessions, with the simplest option being the preferences system. The preferences system allows you to save key value pairs with primitive data types as values.

To use preferences you need to import SharedPeferences and then use getSharedPreferences() within your activity to get the preferences object:

```java
import android.content.SharedPreferences;

// Somewhere in your code
SharedPreferences settings = getSharedPreferences("SomeKey", MODE_PRIVATE);
```

<!--more-->

The second argument for getSharedPreferences is the mode in which your preferences will be saved and made accessible. I chose MODE_PRIVATE which means that only my application will be able to access it. There are other modes that allow you to share your preferences with other apps or processes.

Once you have your preferences object you can use functions like getInt() to retrieve values:

```java
settings.getInt("someKey", 0);
```

The second argument for getInt (and other similar functions) is a default value to be returned if the key is empty.

Using the same settings object you can save values like this:

```java
settings.edit().putInt("someKey", 1).commit();
```

You need to call edit() on your SharedPreferences object to get an Editor instance of your preferences and then you can call putInt() with the key and value you want to save. Keep in mind that the value won&#8217;t be saved until you call commit() on your object object.
