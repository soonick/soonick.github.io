---
id: 2565
title: Using Google+ id tokens from an Android app
date: 2015-02-06T17:08:33+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2565
permalink: /2015/02/using-google-id-tokens-from-an-android-app/
categories:
  - Mobile development
tags:
  - android
  - java
  - mobile
  - programming
---
I already wrote a post explaining [how to sign-in to Google+ from an Android app](http://ncona.com/2015/01/google-sign-in-on-android/). Now I want to be able to match all requests my app makes with the user associated with those requests.

Google uses the OpenID protocol and ID Tokens to make this possible. An ID Token consists of two JSON objects, base64 encoded, concatenated and cryptographically signed. This token can be attached to your requests so your server knows who is the user it should associate the request with. This token must be kept secret because anybody using it will be able to identify themselves as the user. To keep the token safe always use HTTPS and transfer it as an HTTP header.

<!--more-->

One requisite to create an ID Token is to provide the client id of the server that will be consuming this token. Go to [Google API Console](https://console.developers.google.com) and in the same project where you created your Android client create another client of type **Web Application**. Once created you will be given a client id.

[<img src="/images/posts/web_application_client.png" alt="web_application_client" />](/images/posts/web_application_client.png)

[<img src="/images/posts/client_id.png" alt="client_id" />](/images/posts/client_id.png)

Once you have the client ID for your server you can use something like this to get a token:

```java
/**
 * Get an ID Token from Google
 */
@Override
public void onConnected(Bundle connectionHint) {
  final Context context = this.getApplicationContext();

  new AsyncTask<Void, Void, String>() {
    @Override
    protected String doInBackground(Void... voids) {
      try {
        String accountName = Plus.AccountApi.getAccountName(googleApiClient);
        String token = GoogleAuthUtil.getToken(
          context,
          accountName,
          "audience:server:client_id:" +
          "1097205969433-fa8a4ieaa5vcnhprg72rutka22vpqcl4.apps.googleusercontent.com"
        );

        // Now you can save the token so you can send it with
        // your requests
      } catch (UserRecoverableAuthException recoverableException) {
      } catch (GoogleAuthException authEx) {
      } catch (IOException ioEx) {
      }

      return "";
    }
  }.execute();
}
```

You will also need to add this permission to your AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.GET_ACCOUNTS" />
```

Keep in mind that the ID token has an expiration time so you will have to build a mechanism where you call getToken again every time the token expires.
