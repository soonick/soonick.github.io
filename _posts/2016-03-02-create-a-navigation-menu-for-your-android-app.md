---
id: 3524
title: Create a navigation menu for your Android app
date: 2016-03-02T18:09:56+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3524
permalink: /2016/03/create-a-navigation-menu-for-your-android-app/
categories:
  - Mobile development
tags:
  - android
  - java
  - programming
  - projects
---
I finished building a hobby app a few weeks ago, but after getting all the functionality right I couldn&#8217;t help but notice that it looked horrible. I&#8217;m going to slowly try to make it less ugly starting with this post.

The first thing that I want to do is get rid of the default title bar because it occupies too much space:

<a href="http://ncona.com/wp-content/uploads/2016/02/title-bar-android.png" rel="attachment wp-att-3527"><img src="http://ncona.com/wp-content/uploads/2016/02/title-bar-android.png" alt="title-bar-android" width="1080" height="498" class="alignnone size-full wp-image-3527" srcset="https://ncona.com/wp-content/uploads/2016/02/title-bar-android.png 1080w, https://ncona.com/wp-content/uploads/2016/02/title-bar-android-300x138.png 300w, https://ncona.com/wp-content/uploads/2016/02/title-bar-android-768x354.png 768w, https://ncona.com/wp-content/uploads/2016/02/title-bar-android-1024x472.png 1024w" sizes="(max-width: 1080px) 100vw, 1080px" /></a>

Create the file **src/main/res/values/style.xml** if it doesn&#8217;t exist already and create a new theme with no title:

<!--more-->

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<resources>
  <style name="NewTheme" parent="android:Theme.Holo.Light">
    <item name="android:windowNoTitle">true</item>
  </style>
</resources>
```

We create a new theme that extends the light theme of Android and overwrites the windowNoTitle property. Now we need to apply this theme to our application from our manifest:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.example.app"
        android:versionCode="1"
        android:versionName="0.0.1">
    <uses-sdk android:minSdkVersion="9" android:targetSdkVersion="21" />

    <application android:label="@string/app_name"
        android:theme="@style/NewTheme" >
        <activity android:name="Main" android:label="@string/app_name">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

Line 9 assigns the theme to the application. The app doesn&#8217;t have a title bar anymore:

<a href="http://ncona.com/wp-content/uploads/2016/02/android-no-title.png" rel="attachment wp-att-3531"><img src="http://ncona.com/wp-content/uploads/2016/02/android-no-title.png" alt="android-no-title" width="1080" height="210" class="alignnone size-full wp-image-3531" srcset="https://ncona.com/wp-content/uploads/2016/02/android-no-title.png 1080w, https://ncona.com/wp-content/uploads/2016/02/android-no-title-300x58.png 300w, https://ncona.com/wp-content/uploads/2016/02/android-no-title-768x149.png 768w, https://ncona.com/wp-content/uploads/2016/02/android-no-title-1024x199.png 1024w" sizes="(max-width: 1080px) 100vw, 1080px" /></a>

The next step I would recommend is to grab some icons from the [material icon library](https://design.google.com/icons/) depending on what items you want in your navigation bar. After grabbing some icons you can use ImageButton to create the navigation bar. This is how my **res/layout/main.xml** looks like:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="fill_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical">
  <LinearLayout android:layout_width="match_parent"
      android:layout_height="40dip"
      android:orientation="horizontal">
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_add_black_24dp" />
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_people_black_24dp" />
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_menu_black_24dp" />
  </LinearLayout>
</LinearLayout>
```

So far it is a simple LinearLayout containing three ImageButtons with icons from the google material library. I set the height of the LinearLayout to 40dip because this is the height I want for my navigation bar, this can be adjusted as needed. This is the result:

<a href="http://ncona.com/wp-content/uploads/2016/02/menu-first-attempt.png" rel="attachment wp-att-3535"><img src="http://ncona.com/wp-content/uploads/2016/02/menu-first-attempt.png" alt="menu-first-attempt" width="1080" height="360" class="alignnone size-full wp-image-3535" srcset="https://ncona.com/wp-content/uploads/2016/02/menu-first-attempt.png 1080w, https://ncona.com/wp-content/uploads/2016/02/menu-first-attempt-300x100.png 300w, https://ncona.com/wp-content/uploads/2016/02/menu-first-attempt-768x256.png 768w, https://ncona.com/wp-content/uploads/2016/02/menu-first-attempt-1024x341.png 1024w" sizes="(max-width: 1080px) 100vw, 1080px" /></a>

It&#8217;s starting to look better. Lets make the buttons flat and add a border so it looks more like a navigation bar:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="fill_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical">
  <LinearLayout
      android:layout_width="match_parent"
      android:layout_height="40dip"
      android:orientation="horizontal">
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_add_black_24dp"
      style="?android:attr/borderlessButtonStyle" />
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_people_black_24dp"
      style="?android:attr/borderlessButtonStyle" />
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_menu_black_24dp"
      style="?android:attr/borderlessButtonStyle" />
  </LinearLayout>
  <LinearLayout android:layout_height="1dip"
      android:layout_width="match_parent"
      android:background="#000">
  </LinearLayout>
</LinearLayout>
```

To make the buttons flat we added this attribute to all the buttons:

```
style="?android:attr/borderlessButtonStyle"
```

The easiest way I found to add a border to the navigation was by adding a view below it with a background color. All together gives this result:

<a href="http://ncona.com/wp-content/uploads/2016/02/nav-with-border-android.png" rel="attachment wp-att-3537"><img src="http://ncona.com/wp-content/uploads/2016/02/nav-with-border-android.png" alt="nav-with-border-android" width="1080" height="354" class="alignnone size-full wp-image-3537" srcset="https://ncona.com/wp-content/uploads/2016/02/nav-with-border-android.png 1080w, https://ncona.com/wp-content/uploads/2016/02/nav-with-border-android-300x98.png 300w, https://ncona.com/wp-content/uploads/2016/02/nav-with-border-android-768x252.png 768w, https://ncona.com/wp-content/uploads/2016/02/nav-with-border-android-1024x336.png 1024w" sizes="(max-width: 1080px) 100vw, 1080px" /></a>

It looks very good now, but it doesn&#8217;t have those cool ripple effects that material buttons usually have. For getting that effect we need to use the AppCompat.Light theme. First we need to add appcompat as a dependency in build.gradle:

```
compile 'com.android.support:appcompat-v7:23.1.0'
```

Then you need to change the theme definition to use the AppCompat theme:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<resources>
  <style name="NewTheme" parent="Theme.AppCompat.Light">
    <item name="windowNoTitle">true</item>
  </style>
</resources>
```

And then have your activity extend AppCompatActivity:

```java
...

import android.support.v7.app.AppCompatActivity;

public class Main extends AppCompatActivity {
  ...
}
```

This adds the ripple effect to the buttons, but causes the buttons to not occupy all the space available. You can fix this by giving them some negative margin. You can create a style for this and then apply it to all your buttons. Modify **src/main/res/values/style.xml** so it looks like this:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<resources>
  <style name="NewTheme" parent="Theme.AppCompat.Light">
    <item name="windowNoTitle">true</item>
  </style>

  <style name="NavButton" parent="@style/Widget.AppCompat.Button.Borderless">
    <item name="android:layout_marginBottom">-10dip</item>
    <item name="android:layout_marginLeft">-10dip</item>
    <item name="android:layout_marginRight">-10dip</item>
    <item name="android:layout_marginTop">-10dip</item>
  </style>
</resources>
```

And then apply the style to the buttons:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="fill_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical">
  <LinearLayout
      android:layout_width="match_parent"
      android:layout_height="40dip"
      android:orientation="horizontal">
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_add_black_24dp"
      style="@style/NavButton" />
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_people_black_24dp"
      style="@style/NavButton" />
    <ImageButton
      android:layout_height="match_parent"
      android:layout_weight="1"
      android:layout_width="wrap_content"
      android:src="@drawable/ic_menu_black_24dp"
      style="@style/NavButton" />
  </LinearLayout>
  <LinearLayout android:layout_height="1dip"
      android:layout_width="match_parent"
      android:background="#000">
  </LinearLayout>
</LinearLayout>
```

This gives us a nice navigation bar with ripple effect.
