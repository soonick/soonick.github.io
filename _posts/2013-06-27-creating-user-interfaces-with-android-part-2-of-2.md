---
id: 1487
title: Creating user interfaces with android (Part 2 of 2)
date: 2013-06-27T03:53:50+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1487
permalink: /2013/06/creating-user-interfaces-with-android-part-2-of-2/
categories:
  - Mobile development
tags:
  - android
  - internationalization
  - java
  - mobile
  - programming
---
This is part 2 of an introduction to [creating user interfaces for Android](http://ncona.com/2013/06/creating-user-interfaces-with-android-part-1-of-2/ "Creating user interfaces with android").

## Styling

If you come from a web development background, you probably find it ugly to define styles inline. Luckily as with HTML and CSS, you can define your styles in an external file. The syntax is completely different so it may take some time to get used to, but I think of it as assigning classes to the elements I want to style and then defining their styles.

To create a stylesheet we need to create an XML file in the **res/values/** directory, it should look something like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="FillWidth">
        <item name="android:layout_width">fill_parent</item>
        <item name="android:layout_height">wrap_content</item>
    </style>
</resources>
```

<!--more-->

The style tag lets you define a name for our style (you can think of this as a css class) and the item tags define different styles.

To reference this style you would have to do something like this:

```xml
<TextView style="@style/FillWidth" android:text="Text"/>
```

After moving everything to a stylesheet main.xml is a lot easier to read:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
        style="@style/Container">
    <ImageView android:id="@+id/image" style="@style/FillContent"
            android:src="@drawable/sun"/>
    <TextView android:id="@+id/name" style="@style/PersonName"
            android:text="Juanito Perez"/>
    <CheckBox android:id="@+id/cool" style="@style/PersonCool"
            android:text="Is he cool?"/>
    <View android:id="@+id/ruler" style="@style/Ruler"/>
    <ScrollView android:id="@+id/scroller" style="@style/TextScroller">
        <LinearLayout style="@style/TextContainer">
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
            <TextView style="@style/FillWidth" android:text="Text"/>
        </LinearLayout>
    </ScrollView>
    <EditText android:id="@+id/message" style="@style/MessageBox"
            android:hint="Message"/>
    <Button android:id="@+id/send" style="@style/SendButton"
            android:text="Send"/>
</RelativeLayout>
```

And we can find our styles in res/values/style.xml:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="FillWidth">
        <item name="android:layout_width">fill_parent</item>
        <item name="android:layout_height">wrap_content</item>
    </style>
    <style name="Container" parent="FillWidth">
        <item name="android:paddingLeft">10px</item>
        <item name="android:paddingTop">10px</item>
        <item name="android:paddingRight">10px</item>
    </style>
    <style name="FillContent">
        <item name="android:layout_width">wrap_content</item>
        <item name="android:layout_height">wrap_content</item>
    </style>
    <style name="PersonName" parent="FillContent">
        <item name="android:layout_marginTop">50px</item>
        <item name="android:layout_toRightOf">@id/image</item>
        <item name="android:layout_marginLeft">20px</item>
    </style>
    <style name="PersonCool" parent="FillContent">
        <item name="android:layout_below">@id/name</item>
        <item name="android:layout_toRightOf">@id/image</item>
        <item name="android:layout_marginLeft">20px</item>
    </style>
    <style name="Ruler">
        <item name="android:layout_width">fill_parent</item>
        <item name="android:layout_height">1px</item>
        <item name="android:background">#FF00FF00</item>
        <item name="android:layout_below">@id/image</item>
        <item name="android:layout_marginTop">5px</item>
        <item name="android:layout_marginBottom">5px</item>
    </style>
    <style name="TextScroller">
        <item name="android:layout_height">250px</item>
        <item name="android:layout_width">fill_parent</item>
        <item name="android:layout_below">@id/ruler</item>
        <item name="android:layout_marginBottom">5px</item>
    </style>
    <style name="TextContainer" parent="FillWidth">
        <item name="android:orientation">vertical</item>
    </style>
    <style name="MessageBox">
        <item name="android:layout_width">180px</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:layout_below">@id/scroller</item>
    </style>
    <style name="SendButton">
        <item name="android:layout_width">100px</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:layout_toRightOf">@id/message</item>
        <item name="android:layout_below">@id/scroller</item>
    </style>
</resources>
```

You can find more information about styling android apps in the [styles and themes documentation](http://developer.android.com/guide/topics/ui/themes.html "Styles and themes documentation").

## Strings

You may have noticed that I added all my strings from within the layout. This is usually a bad idea if you ever want to translate your app, and doing it the right way is easy enough that there isn&#8217;t really a reason not to do it from the beginning.

Lets look at an example:

```xml
<CheckBox android:id="@+id/cool" style="@style/PersonCool"
        android:text="Is he cool?"/>
```

This would change to:

```xml
<CheckBox android:id="@+id/cool" style="@style/PersonCool"
        android:text="@string/cool_checkbox_caption"/>
```

And you can define the value for cool\_checkbox\_caption in **res/values/strings.xml** which will look something like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="cool_checkbox_caption">Is he cool?</string>
</resources>
```

In the future you would only need to create another strings.xml file in another location to add another language to your app, but I won&#8217;t go into details to do that in this article.
