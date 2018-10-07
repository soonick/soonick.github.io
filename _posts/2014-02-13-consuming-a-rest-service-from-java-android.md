---
id: 1941
title: Consuming a REST service from Java (Android)
date: 2014-02-13T05:21:05+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1941
permalink: /2014/02/consuming-a-rest-service-from-java-android/
categories:
  - Mobile development
tags:
  - android
  - java
  - json
  - programming
---
The time finally came when I need to consume a service from my Android app. As I expected this is not as easy as with JavaScript. Strict types, threads and craziness come all into play for this simple task.

The first thing I learned about making a request to a REST service was to use the apache library:

```java
public String makeRequest(url) {
  // HttpRequestBase is the parent of HttpGet, HttpPost, HttpPut
  // and HttpDelete
  HttpRequestBase request = new HttpGet(url);
  // The BasicResponseHandler returns the response as a String
  ResponseHandler<String> handler = new BasicResponseHandler();

  String result = "";
  try {
    HttpClient httpclient = new DefaultHttpClient();
    // Pass the handler and request to httpclient
    result = httpclient.execute(request, handler);
  } catch (ClientProtocolException e) {
    e.printStackTrace();
  } catch (IOException e) {
    e.printStackTrace();
  }

  return result;
}
```

<!--more-->

This doesn&#8217;t look so hard. The problem is that this doesn&#8217;t work for Android because you are no allowed to make HTTP requests on the main(UI) thread. To overcome this they recommend you use AsyncTask. AsyncTask allows you to perform operations in the background and then notify the UI thread. After reading a little about how it works and a lot of trial and error I came up with this:

```java
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.support.v4.content.LocalBroadcastManager;
import java.io.IOException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;

/**
 * Helps you make asynchronous rest requests
 * How to use:
 *   First you will need to set up a listener for an intent so you will need to
 *   create an inner class similar to this one:
 *
 *   private class SomeReceiver extends BroadcastReceiver {
 *      @Override
 *      public void onReceive(Context context, Intent intent) {
 *          Bundle extras = intent.getExtras();
 *          extras.get("response"); // This is the response string
 *      }
 *    }
 *
 *   Then you will need to register a listener for the intent:
 *
 *   SomeReceiver receiver = new SomeReceiver();
 *   LocalBroadcastManager.getInstance(this).registerReceiver(receiver, new IntentFilter("StupidRest"));
 *
 *   Finally you need to make the request:
 *
 *   new StupidRestHelper(this).get("http://some/url");
 */
public class StupidRestHelper extends AsyncTask<String, Void, String> {
    private HttpClient httpclient;

    private Context context;

    private HttpRequestBase request;

    public StupidRestHelper(Context c) {
        context = c;
    }

    public void get(String url) {
       request = new HttpGet(url);
       this.execute(url);
    }

    public void post(String url) {
       request = new HttpPost(url);
       this.execute(url);
    }

    public void put(String url) {
       request = new HttpPut(url);
       this.execute(url);
    }

    public String doInBackground(String... urls) {
        httpclient = new DefaultHttpClient();
        ResponseHandler<String> handler = new BasicResponseHandler();

        String result = "";

        try {
            result = httpclient.execute(request, handler);
        } catch (ClientProtocolException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return result;
    }

    protected void onPostExecute(String result) {
        httpclient.getConnectionManager().shutdown();
        Intent intent = new Intent("StupidRest");
        intent.putExtra("response", result);
        LocalBroadcastManager lbm = LocalBroadcastManager.getInstance(context);
        lbm.sendBroadcast(intent);
    }
}
```

This is all cool. Now we have a relatively easy way to make a call to a rest service and be notified about the response. The problem now is that the response is just a string and it is not of much use that way, so we need some way to parse it into something we can use. There are many libraries that do this but for some reason I ended up using [jackson](http://jackson.codehaus.org/ "Jackson JSON procesor"). The way this works seemed interesting because in order for Jackson to parse your JSON string you need to first give it a class with the structure you expect the JSON to have. For example, if you expect your JSON to have this structure:

```json
{
  "someString" : "hello"
}
```

You would need to create a class like this:

```java
public class Something {
  public String someString;
}
```

Then you can parse it with something similar to this:

```java
ObjectMapper mapper = new ObjectMapper();
Something something = null;
try {
  something = mapper.readValue(response, Something.class);
  // something.someString will contain the value from the JSON
} catch (IOException e) {
  e.printStackTrace();
}
```
