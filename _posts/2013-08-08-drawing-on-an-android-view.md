---
id: 1669
title: Drawing on an android view
date: 2013-08-08T04:24:47+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1669
permalink: /2013/08/drawing-on-an-android-view/
tags:
  - android
  - java
  - mobile
  - programming
---
I am building a simple app that will need to graph some data, so I found myself in the need of using Android&#8217;s drawing library. There are a few good tutorials out there of how to do this using a canvas, but I read somewhere that it was possible to draw directly into a view and I wanted to try that. Drawing directly into the view is useful when you have data that you don&#8217;t need to redraw very often. When you use a canvas you have to manually call the onDraw method every time you want to show something, which makes sense for animations. For more static data you can draw directly into the view and the onDraw method will be called automatically every time the view it is shown to the user.

<!--more-->

The first thing I did was create a custom view. I created a **views** folder inside my project folder (e.g. src/com/ncona/myapp/views) and then created a custom view file called **RedCircle.java**:

```java
// The package is the folder where this view lives
package com.ncona.myapp.views;

// Some packages that we use in this class
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.view.View;

// Our class extends View
public class RedCircle extends View
{
    // The constructor calls the View constructor
    public RedCircle(Context context)
    {
        super(context);
    }

    // This is automatically called every time this view is
    // shown to the user
    @Override
    protected void onDraw(Canvas canvas)
    {
        // Draw a red circle
        Path circle = new Path();
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Color.RED);
        circle.addCircle(150, 150, 100, Path.Direction.CW);
        canvas.drawPath(circle, paint);
    }
}
```

I added some comments explaining what each part does, it should be really easy to understand. The next thing I had to do was modify my main activity file (src/com/ncona/myapp/MyApp.java):

```java
package com.ncona.myapp;

import android.app.Activity;
import android.os.Bundle;

// To import our view we need to use the fully qualified
// name. This is basically the path beginning from the src
// directory but using . instead of /
import com.ncona.myapp.views.RedCircle;

public class MyApp extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        // Note here that instead of passing R.layout.main as
        // you would usually do, we are passing an instance of
        // our custom view, which will result on a screen
        // showing a red circle
        setContentView(new RedCircle(this));
    }
}
```

And this is how it looks:

[<img src="/images/posts/red_circle.png" alt="red_circle" />](/images/posts/red_circle.png)

Now I have a very exciting piece of software I can show off to my mom.
