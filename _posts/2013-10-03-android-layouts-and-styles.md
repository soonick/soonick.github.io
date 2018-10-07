---
id: 1759
title: Android layouts and styles
date: 2013-10-03T04:25:37+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1759
permalink: /2013/10/android-layouts-and-styles/
categories:
  - Mobile development
tags:
  - android
  - design patterns
  - java
  - mobile
  - programming
---
I have been slowly working more with Android and as I go I find myself in the need to do more complex stuff. I have been recently working on the UI side and I have been asking friends who have more experience with Android to review my code and I learned that I was doing some things the wrong way.

I come from a web development background so while I was learning how to use Android layouts I was looking at ways to translate what you do in Android with what you would do in the web. In Android we have layout files which are written in XML and live in res/layout/. When I started I pictured these being my HTML files, which is not completely correct. For styling android apps we use another XML file that lives in res/values/, these I thought of as being my CSS files.

<!--more-->

Following this frame of thought this is how one of my layouts would look:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
       style="@style/ScreenLayout">
    <Button android:id="@+id/save"
           android:text="@string/save"
           style="@style/MainButton" />
    <Button android:id="@+id/cancel"
           android:text="@string/cancel"
           style="@style/MainButton.Cancel" />
</RelativeLayout>
```

And then, since I want to have the cancel button at the right of the save button I would have this in my style file:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="ScreenLayout">
        <item name="android:layout_width">fill_parent</item>
        <item name="android:layout_height">fill_parent</item>
        <item name="android:orientation">vertical</item>
    </style>

    <style name="MainButton">
        <item name="android:layout_width">wrap_content</item>
        <item name="android:layout_height">wrap_content</item>
    </style>

    <style name="MainButton.Cancel">
        <item name="android:layout_toRightOf">@id/save</item>
    </style>
</resources>
```

To me, this way of doing things made perfect sense. We have the layout file specify semantically which elements are part of the screen and then have the style file define margins, sizes and positions. When I showed this to my Android developer friends they yelled at me about the MainButton.Cancel style. Their strongest argument was about referencing an id from the styles as I do for the MainButton.Cancel style:

```xml
<style name="MainButton.Cancel">
    <item name="android:layout_toRightOf">@id/save</item>
</style>
```

We had a long discussion about how in web we keep our HTML semantic and then we take care of the layout in CSS, but at the end their arguments made good sense.

Layouts don&#8217;t translate directly to HTML, they don&#8217;t only specify which elements are in one page, but also how they are laid out, so all the information about their positions should be part of the layout file. This means that instead of having layout_toRightOf in a style file I would have it in the layout file:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
        style="@style/ScreenLayout">
    <Button android:id="@+id/save"
            android:text="@string/save"
            style="@style/MainButton" />
    <Button android:id="@+id/cancel"
            android:text="@string/cancel"
            style="@style/MainButton"
            android:layout_toRightOf="@id/save" />
</RelativeLayout>
```

Doing it this way will allow you to know how this layout looks without having to look at your styles, it also makes your style file smaller so it is easier to read.

## Reusing layouts

One thing that felt weird about android is that because you don&#8217;t have something like an HTML class, it seemed like the layouts couldn&#8217;t be reused the way they are in HTML. I asked about this an the answer to this problem is to use nested layouts. We can create a layout file like this and call it child.xml:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
        style="@style/TwoButtons">
    <Button android:id="@+id/save"
            android:text="@string/save"
            style="@style/MainButton" />
    <Button android:id="@+id/cancel"
            android:text="@string/cancel"
            style="@style/MainButton"
            android:layout_toRightOf="@id/save" />
</RelativeLayout>
```

Define the styles for TwoButtons in the style file:

```xml
<style name="TwoButtons">
    <item name="android:layout_width">fill_parent</item>
    <item name="android:layout_height">wrap_content</item>
</style>
```

And then we can include the child inside of a parent layout:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
        style="@style/ScreenLayout">
    <include layout="@layout/child" />
    <include layout="@layout/child" />
</LinearLayout>
```

And this would be the result:

[<img src="http://ncona.com/wp-content/uploads/2013/10/include_layout.png" alt="include_layout" width="404" height="198" class="alignnone size-full wp-image-1775" srcset="https://ncona.com/wp-content/uploads/2013/10/include_layout.png 404w, https://ncona.com/wp-content/uploads/2013/10/include_layout-300x147.png 300w" sizes="(max-width: 404px) 100vw, 404px" />](http://ncona.com/wp-content/uploads/2013/10/include_layout.png)

However, this has some repercussions. Now, you have two elements with the same Id on your layout, so you can&#8217;t directly use findViewById. To fix this we need to assign an id to each of our include tags, select that view and then look for an element with an specific id inside:

```java
View include = findViewById(R.id.first_include_id);
Button b = (Button)include.findViewById(R.id.new_entry_button);
```
