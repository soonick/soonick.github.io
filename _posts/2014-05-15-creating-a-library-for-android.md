---
id: 2081
title: Creating a library for Android
date: 2014-05-15T04:35:49+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2081
permalink: /2014/05/creating-a-library-for-android/
tags:
  - android
  - java
  - mobile
  - productivity
---
I already went through the process of [creating an application from the command line](http://ncona.com/2013/02/introduction-to-android-development-building-an-application-without-an-ide/ "Creating an application from the command line"). This time I am going to show how to create a library project and integrate it into your app.

To create your library project create a folder and execute this command from inside that folder:

```
android create lib-project \
--name <project_name> \
--target 1 --path . \
--package com.example.whatever
```

Then you can you ahead and write some code. I created a view that will print a hello message (src/com/ncona/hello/Hello.java):

<!--more-->

```java
package com.ncona.hello;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.View;

public class Hello extends View
{
    /**
     * Initialize the view
     */
    public Hello(final Context context) {
      super(context);
    }

    /**
     * Draws everything
     * @param canvas
     */
    @Override
    protected void onDraw(final Canvas canvas) {
        drawHello(canvas);
    }

    /**
     * Draws a hello message
     * @param canvas
     */
    public void drawHello(final Canvas canvas) {
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Color.WHITE);
        paint.setTextSize(20);
        canvas.drawText("Hello World", (float)10, (float)10, paint);
    }
}
```

then you can create a jar using ant:

```
ant debug
```

You will find a file named classes.jar in your bin folder. To use this library you just need to copy this jar into your project&#8217;s libs folder and the library&#8217;s classes will be available for you to use.

It becomes a little more complicated when your project has resource files because resources have to be compiled into your application and made available via the R variable. Lets say we wanted to move the &#8220;Hello World&#8221; string to a resource file instead of having it in the code. We would have a file similar to this (res/values/strings.xml):

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="hello_world">Hello World</string>
</resources>
```

And we would make some changes to our code:

```java
package com.ncona.hello;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.View;

public class Hello extends View
{
    /**
     * Context from which this view is being used
     */
    private Context context;

    /**
     * Initialize the view
     */
    public Hello(final Context ctx) {
      super(ctx);
      context = ctx;
    }

    /**
     * Draws everything
     * @param canvas
     */
    @Override
    protected void onDraw(final Canvas canvas) {
        drawHello(canvas);
    }

    /**
     * Draws a hello message
     * @param canvas
     */
    public void drawHello(final Canvas canvas) {
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Color.WHITE);
        paint.setTextSize(20);
        canvas.drawText(
            context.getString(R.string.hello_world),
            (float)10,
            (float)10,
            paint
        );
    }
}
```

If you tried to grab the generated jar and add it to your project you would get a run time exception when calling drawHello because R.string.hello_world is not found. For this reason and so all resources from all libraries can be available from within your app we need to do a little more work.

First we need to create a folder where we will add all the libraries we want to compile within our app and copy our library code in there:

```
cd yourApplicationProjectFolder
mkdir linkedlibs
cd linkedlibs
cp -r /path/to/libProjectFolder .
cd libProjectFolder
android update project --path . --target 1
cd ../..
android update project --target 1 --path . \
--library ./linkedlibs/libProjectFolder/ \
--subprojects
```

Build your project:

```
ant clean
ant debug
```

**Note**: If get a message complaining about some identifier not working, look at the target version on your project.properties file and make sure it corresponds to your target version. It seems like one of the steps above modifies this number.
  
**Note**: Make sure that you remove the jar from your libs folder or the build will fail.
