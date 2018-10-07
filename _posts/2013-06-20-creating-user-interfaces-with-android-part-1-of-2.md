---
id: 1443
title: Creating user interfaces with android (Part 1 of 2)
date: 2013-06-20T04:02:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1443
permalink: /2013/06/creating-user-interfaces-with-android-part-1-of-2/
categories:
  - Mobile development
tags:
  - android
  - java
  - mobile
  - programming
---
I am resuming my journey to learning Android development and for this article I will focus on the UI. On this post I will explain how to add labels, buttons and related elements so the user can interact with our app.

The way I see building UIs for Android is very similar to they way they are built for the web. You can do it in two ways: programmatically or declaratively. Programmatically means creating elements using Java code and declaratively means using XML files. If you are familiar with web development, this is analogous to how JavaScript and HTML interact. As on Web, the recommended way is to do it declaratively whenever possible since it is usually faster.

While designing a user interface for android it is important to keep in mind [Android design guidelines](http://developer.android.com/guide/topics/ui/index.html "Android design guidelines") to give the user a consistent experience among different apps.

<!--more-->

## Loading a layout

Layouts are containers that allow you to group and organize components on your UI. Before explaining how the layouts work I want to show how you can load a layout into your app:

```java
public void onCreate(Bundle savedInstanceState)
{
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);
}
```

You can see how we use the **setContentView** function to load a layout for us. Now, the argument we are passing may be a little confusing. What happens is that the android sdk will automatically create R.layout.<layout-name> based on your layouts on res/layout/ . This means that if you have a file named bananas.xml on your res/layout/ folder you will also have the layout available at R.layout.bananas.

## Referencing a UI element from code

When you create a UI using the declarative way you need a way to reference your element from code so you can interact with them. To easily do this, Android uses the id attribute:

```xml
<Button android:id="@+id/my_button" />
```

The @ sign tells the parser that it should expand whatever comes next. The + sign means that it is a new resource that will be created and added to our resources. Finally the my_button string is an arbitrary string that we used to identify this element so we can reference it from code:

```java
Button myButton = (Button)findViewById(R.id.my_button);
```

## Inputs

Android SDK provides many kinds of inputs that can be used to get information from the user. Namely you can use these controls on your apps: Button, Text field, Checkbox, Radio button, Toggle button, Spinner and Pickers. Lets look at a very quick example:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
       android:layout_height="fill_parent"
       android:layout_width="fill_parent"
       android:orientation="vertical">
    <EditText android:id="@+id/edit_message"
           android:layout_width="fill_parent"
           android:layout_height="wrap_content"
           android:hint="Text"/>
    <Button android:id="@+id/button_send"
           android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="Button"
           android:onClick="sendMessage"/>
    <CheckBox android:id="@+id/checkbox_meat"
           android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="Check"/>
    <RadioButton android:id="@+id/radio_pirates"
           android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="Radio"/>
    <ToggleButton android:id="@+id/togglebutton"
           android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:textOn="I'm on"
           android:textOff="I'm off"/>
</LinearLayout>
```

We created a screen with some of the different kinds of inputs. You can see that most of them use the layout\_width and layout\_height to define their size. Most of them use wrap_content which means that they will be big enough to hold their content, you can also [specify a dimension](http://developer.android.com/guide/topics/resources/more-resources.html#Dimension "Android dimensions") to give an specific size.

## Images

Images in Android fall into the resources category. This means that you need to place all your images inside res/drawable/. Once an image is in that folder (ex: res/drawable/sun.jpg) you can add it to you app using an ImageView:

```xml
<ImageView android:id="@+id/image"
        android:layout_height="wrap_content"
        android:layout_width="wrap_content"
        android:src="@drawable/sun"/>
```

## Layouts

Now that we know how to put elements on the screen we want to be able to put them where we want them. To learn this I am going to do a little exercise. I&#8217;m going to use different layouts to create this UI:

[<img src="http://ncona.com/wp-content/uploads/2013/05/wireframe.png" alt="wireframe" width="269" height="424" class="alignnone size-full wp-image-1458" srcset="https://ncona.com/wp-content/uploads/2013/05/wireframe.png 269w, https://ncona.com/wp-content/uploads/2013/05/wireframe-190x300.png 190w" sizes="(max-width: 269px) 100vw, 269px" />](http://ncona.com/wp-content/uploads/2013/05/wireframe.png)

Lets go over the different kind of layouts really fast to see which ones can help us achieve this:

  * **LinearLayout** aligns all children in a single direction, vertically or horizontally.
  * **RelativeLayout** displays child views in relative positions. The position of each view can be specified as relative to sibling elements or in positions relative to the parent.
  * **ListView** displays a list of scrollable items. The list items are automatically inserted to the list using an Adapter that pulls content from a source such as an array or database query and converts each item result into a view that&#8217;s placed into the list.
  * **GridView** displays items in a two-dimensional, scrollable grid. The grid items are automatically inserted to the layout using a ListAdapter.

The simplest way to achieve what we want would probably be to have a lot of nested LinearLayout but the documentation recommends to instead use RelativeLayout for performance reasons. ListView and GridView seem to be more focused on dynamic content so we will not use them this time.

Lets start by dumping our elements in an xml file:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
        android:layout_height="fill_parent"
        android:layout_width="fill_parent"
        android:orientation="vertical">
    <ImageView android:id="@+id/image"
            android:layout_height="wrap_content"
            android:layout_width="wrap_content"
            android:src="@drawable/sun"/>
    <TextView android:id="@+id/name"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Juanito Perez"/>
    <CheckBox android:id="@+id/cool"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Is he cool?"/>
    <View android:id="@+id/ruler"
            android:layout_width="fill_parent"
            android:layout_height="1px"
            android:background="#FF00FF00"/>
    <LinearLayout
            android:layout_height="wrap_content"
            android:layout_width="fill_parent"
            android:orientation="vertical">
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
        <TextView android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Text"/>
    </LinearLayout>
    <EditText android:id="@+id/message"
            android:layout_width="fill_parent"
            android:layout_height="wrap_content"
            android:hint="Message"/>
    <Button android:id="@+id/send"
            android:layout_width="fill_parent"
            android:layout_height="wrap_content"
            android:text="Send"/>
</LinearLayout>
```

The result will be something like this:

[<img src="http://ncona.com/wp-content/uploads/2013/05/before_layout.png" alt="before_layout" width="481" height="801" class="alignnone size-full wp-image-1470" srcset="https://ncona.com/wp-content/uploads/2013/05/before_layout.png 481w, https://ncona.com/wp-content/uploads/2013/05/before_layout-180x300.png 180w" sizes="(max-width: 481px) 100vw, 481px" />](http://ncona.com/wp-content/uploads/2013/05/before_layout.png)

Now that we have all our elements lets try to put them where we want them. After a playing a little with the values I got to this code:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
        android:layout_height="fill_parent"
        android:layout_width="fill_parent"
        android:paddingLeft="10px"
        android:paddingTop="10px"
        android:paddingRight="10px"> <!-- Relative layout -->
    <ImageView android:id="@+id/image"
            android:layout_height="wrap_content"
            android:layout_width="wrap_content"
            android:src="@drawable/sun"/>
            <!-- By default the first element goes in the top left corner -->
    <TextView android:id="@+id/name"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Juanito Perez"
            android:layout_toRightOf="@id/image"
            android:layout_marginTop="50px"
            android:layout_marginLeft="20px"/>
            <!-- toRightOf lets us place elements relative to others, in this
            case the image -->
            <!-- marginTop and marginLeft let us define margins -->
    <CheckBox android:id="@+id/cool"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Is he cool?"
            android:layout_below="@id/name"
            android:layout_toRightOf="@id/image"
            android:layout_marginLeft="20px"/>
   <View android:id="@+id/ruler"
            android:layout_width="fill_parent"
            android:layout_height="1px"
            android:background="#FF00FF00"
            android:layout_below="@id/image"
            android:layout_marginTop="5px"
            android:layout_marginBottom="5px"/>
        <ScrollView android:id="@+id/scroller"
                android:layout_height="250px"
                android:layout_width="fill_parent"
                android:layout_below="@id/ruler"
                android:layout_marginBottom="5px">
        <!-- ScrollView allows us to scroll its content -->
            <LinearLayout android:layout_height="wrap_content"
                    android:layout_width="fill_parent"
                    android:orientation="vertical">
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
                <TextView android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Text"/>
            </LinearLayout>
        </ScrollView>
    <EditText android:id="@+id/message"
            android:layout_width="180px"
            android:layout_height="wrap_content"
            android:hint="Message"
            android:layout_below="@id/scroller"/>
    <Button android:id="@+id/send"
            android:layout_width="100px"
            android:layout_height="wrap_content"
            android:text="Send"
            android:layout_toRightOf="@id/message"
            android:layout_below="@id/scroller"/>
    <!-- We hardcoded some widths because RelativeLayout doesn't allow us to
    specify percentages. We could alternatively wrapped these two elements in a
    Linear layout and give them percentage weights -->
</RelativeLayout>
```

I added comments in the things I found more interesting. I ended with this screen:

[<img src="http://ncona.com/wp-content/uploads/2013/05/after_layout.png" alt="after_layout" width="484" height="726" class="alignnone size-full wp-image-1471" srcset="https://ncona.com/wp-content/uploads/2013/05/after_layout.png 484w, https://ncona.com/wp-content/uploads/2013/05/after_layout-200x300.png 200w" sizes="(max-width: 484px) 100vw, 484px" />](http://ncona.com/wp-content/uploads/2013/05/after_layout.png)
