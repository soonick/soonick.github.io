---
id: 2543
title: Google+ sign-in on Android
date: 2015-01-28T20:25:54+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2543
permalink: /2015/01/google-sign-in-on-android/
categories:
  - Mobile development
tags:
  - android
  - authentication
  - google
  - java
  - mobile
  - programming
---
I&#8217;m building a system for which I want to use Google+ as authentication system. This will allow me to focus on my app instead of worrying about building a secure authentication system.

The first step to building this system is to have my Android app allow users to sign in with Google. We are going to build a simple Android app that allows users to Sign In using their Google+ account.

## Scaffolding the app

To get started we can use [a generator I created with yeoman](https://www.npmjs.com/package/generator-android-minimal). Once installed create an empty folder and run:

```
yo android-minimal
```

At this point you should be able to build and run a very simple app.

<!--more-->

## The flow

Our application will have two screens: A sign-in screen that the user will get when they are not signed in, and an application screen that will allow the user to sign out.

[<img src="http://ncona.com/wp-content/uploads/2015/01/IMG_20150122_141625.jpg" alt="App diagram" width="700" height="571" class="alignnone size-full wp-image-2546" srcset="https://ncona.com/wp-content/uploads/2015/01/IMG_20150122_141625.jpg 700w, https://ncona.com/wp-content/uploads/2015/01/IMG_20150122_141625-300x245.jpg 300w" sizes="(max-width: 700px) 100vw, 700px" />](http://ncona.com/wp-content/uploads/2015/01/IMG_20150122_141625.jpg)

## Setting up the API

In order to use Google+ API to sign in our users we first need to configure our project on the [Google API console](https://console.developers.google.com).

Create a new project. The name of the project doesn&#8217;t matter at this point:

[<img src="http://ncona.com/wp-content/uploads/2015/01/create-project.png" alt="create-project" width="536" height="295" class="alignnone size-full wp-image-2548" srcset="https://ncona.com/wp-content/uploads/2015/01/create-project.png 536w, https://ncona.com/wp-content/uploads/2015/01/create-project-300x165.png 300w" sizes="(max-width: 536px) 100vw, 536px" />](http://ncona.com/wp-content/uploads/2015/01/create-project.png)

In the API section enable Google+ API:

[<img src="http://ncona.com/wp-content/uploads/2015/01/google-api.png" alt="google-api" width="900" height="219" class="alignnone size-full wp-image-2550" srcset="https://ncona.com/wp-content/uploads/2015/01/google-api.png 900w, https://ncona.com/wp-content/uploads/2015/01/google-api-300x73.png 300w" sizes="(max-width: 900px) 100vw, 900px" />](http://ncona.com/wp-content/uploads/2015/01/google-api.png)

Then you will need to configure a consent screen. Only the e-mail and product name are necessary:

[<img src="http://ncona.com/wp-content/uploads/2015/01/consent.png" alt="consent" width="768" height="316" class="alignnone size-full wp-image-2551" srcset="https://ncona.com/wp-content/uploads/2015/01/consent.png 768w, https://ncona.com/wp-content/uploads/2015/01/consent-300x123.png 300w" sizes="(max-width: 768px) 100vw, 768px" />](http://ncona.com/wp-content/uploads/2015/01/consent.png)

Finally, create an new client-id from the credentials section.

[<img src="http://ncona.com/wp-content/uploads/2015/01/oauth-credentials.png" alt="oauth-credentials" width="507" height="326" class="alignnone size-full wp-image-2553" srcset="https://ncona.com/wp-content/uploads/2015/01/oauth-credentials.png 507w, https://ncona.com/wp-content/uploads/2015/01/oauth-credentials-300x193.png 300w" sizes="(max-width: 507px) 100vw, 507px" />](http://ncona.com/wp-content/uploads/2015/01/oauth-credentials.png)

[<img src="http://ncona.com/wp-content/uploads/2015/01/create-client-id.png" alt="create-client-id" width="471" height="602" class="alignnone size-full wp-image-2552" srcset="https://ncona.com/wp-content/uploads/2015/01/create-client-id.png 471w, https://ncona.com/wp-content/uploads/2015/01/create-client-id-235x300.png 235w" sizes="(max-width: 471px) 100vw, 471px" />](http://ncona.com/wp-content/uploads/2015/01/create-client-id.png)

If you are following the steps on this post you should use example.com as package name, otherwise use your app package name. You can get the singing certificate fingerprint using this command:

```
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -list -v
```

The password is **android**. If you are releasing for production, you can change ~/.android/debug.keystore for the production keystore. You will find a line similar to this one in the output:

```
SHA1: 1B:AF:83:6F:9A:EA:47:C5:17:60:84:93:33:D5:2B:6D:F1:EE:03:75
```

## Enabling Google play services on the app

Enabling google services on our app is easy with gradle. We just have to add this at the bottom of build.gradle:

```groovy
dependencies {
  compile 'com.google.android.gms:play-services:6.5.87'
}
```

And this inside the application section of AndroidManifest.xml:

```xml
<meta-data android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

## Sign-in screen

Google play services comes with a branded sing-in button that can be easily integrated in our app. Lets modify main.xml to include our sign in button:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
       android:layout_width="fill_parent" android:layout_height="fill_parent">
    <com.google.android.gms.common.SignInButton
       android:id="@+id/sign_in_button"
       android:layout_centerInParent="true"
       android:layout_width="wrap_content"
       android:layout_height="wrap_content" />
</RelativeLayout>
```

[<img src="http://ncona.com/wp-content/uploads/2015/01/sing-in-button.png" alt="sing-in-button" width="200" height="355" class="alignnone size-full wp-image-2556" srcset="https://ncona.com/wp-content/uploads/2015/01/sing-in-button.png 200w, https://ncona.com/wp-content/uploads/2015/01/sing-in-button-169x300.png 169w" sizes="(max-width: 200px) 100vw, 200px" />](http://ncona.com/wp-content/uploads/2015/01/sing-in-button.png)

## Google+ functionality

We want to know if our user is signed-in in all our activities. To avoid code duplication we are going to create a single activity that takes care of connecting to Google+ API and then we can extend this activity from our app activities.

Lets create an activity called GoogleActivity:

```java
package com.example.app;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentSender.SendIntentException;
import android.os.Bundle;
import android.util.Log;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient.ConnectionCallbacks;
import com.google.android.gms.common.api.GoogleApiClient.OnConnectionFailedListener;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.plus.Plus;

/**
 * Extend this activity when you want your activity to use Google+ API
 */
public class GoogleActivity extends Activity
implements ConnectionCallbacks, OnConnectionFailedListener {
  /**
   * Tag for logging
   */
  private static final String TAG = "GoogleActivity";

  /**
   * Current sign in state. STATE_DEFAULT, STATE_SIGN_IN, STATE_IN_PROGRESS
   */
  private int signInState;

  /**
   * State before sign in has started of after we are done resolving sign-in
   * errors
   */
  private static final int STATE_DEFAULT = 0;

  /**
   * Resolve successive sign in errors.
   */
  private static final int STATE_SIGN_IN = 1;

  /**
   * We are in the middle of an intent to resolve an error. Don't start new
   * intents
   */
  private static final int STATE_IN_PROGRESS = 2;

  /**
   * Is used to identify that we are launching an activity from the sign-in flow
   */
  private static final int RC_SIGN_IN = 0;

  /**
   * State key in which we will save the sign-in progress
   */
  private static final String SAVED_PROGRESS = "sign_in_progress";

  /**
   * GoogleApiClient wraps our service connection to Google Play services and
   * provides access to the users sign in state and Google's APIs.
   */
  protected GoogleApiClient googleApiClient;

  /**
   * Used to store the PendingIntent most recently returned by Play services
   */
  private PendingIntent signInIntent;

  /**
   * Used to store the error code most recently returned by Google Play services
   */
  private int signInError;

  /**
   * Build google api client. If there is a saved state assign it to signInState
   */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if (savedInstanceState != null) {
      signInState = savedInstanceState.getInt(SAVED_PROGRESS, STATE_DEFAULT);
    }

    googleApiClient = buildGoogleApiClient();
  }

  /**
   * Build GoogleApiClient
   */
  protected GoogleApiClient buildGoogleApiClient() {
    return new GoogleApiClient.Builder(this)
        .addConnectionCallbacks(this)
        .addOnConnectionFailedListener(this)
        .addApi(Plus.API, Plus.PlusOptions.builder().build())
        .addScope(Plus.SCOPE_PLUS_PROFILE)
        .build();
  }

  /**
   * Connect to googleApi when activity starts
   */
  @Override
  protected void onStart() {
    super.onStart();
    googleApiClient.connect();
  }

  /**
   * Disconnect from google api when activity is stoped
   */
  @Override
  protected void onStop() {
    super.onStop();

    if (googleApiClient.isConnected()) {
      googleApiClient.disconnect();
    }
  }

  /**
   * Save state before activity is killed
   */
  @Override
  protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    outState.putInt(SAVED_PROGRESS, signInState);
  }

  /**
   * Called when our Activity successfully connects to Google Play services.
   */
  @Override
  public void onConnected(Bundle connectionHint) {
    // Indicate that the sign in process is complete.
    signInState = STATE_DEFAULT;
  }

  /**
   * Called when our Activity could not connect to Google Play services.
   */
  @Override
  public void onConnectionFailed(ConnectionResult result) {
    // Refer to the javadoc for ConnectionResult to see what error codes might
    // be returned in onConnectionFailed.
    Log.i(TAG, "onConnectionFailed: ConnectionResult.getErrorCode() = "
        + result.getErrorCode());

    if (signInState != STATE_IN_PROGRESS) {
      // We do not have an intent in progress so we should store the latest
      // error resolution intent for use when the sign in button is clicked.
      signInIntent = result.getResolution();
      signInError = result.getErrorCode();

      if (signInState == STATE_SIGN_IN) {
        // STATE_SIGN_IN indicates the user already clicked the sign in button
        // so we should continue processing errors until the user is signed in
        // or they click cancel.
        resolveSignInError();
      }
    }
  }

  /**
   * Starts an appropriate intent for user interaction to resolve the current
   * error preventing the user from being signed in.
   */
  protected void resolveSignInError() {
    // If there isn't an Intent then there is nothing we can do
    if (signInIntent != null) {
      try {
        // Send the pending intent that we stored on the most recent
        // OnConnectionFailed callback.
        signInState = STATE_IN_PROGRESS;
        startIntentSenderForResult(signInIntent.getIntentSender(),
            RC_SIGN_IN, null, 0, 0, 0);
      } catch (SendIntentException e) {
        Log.i(TAG, "Sign in intent could not be sent: "
            + e.getLocalizedMessage());
        // The intent was canceled before it was sent.  Attempt to connect to
        // get an updated ConnectionResult.
        signInState = STATE_SIGN_IN;
        googleApiClient.connect();
      }
    }
  }

  /**
   * Called after a pending Intent has been resolved.
   */
  @Override
  protected void onActivityResult(int requestCode, int resultCode,
      Intent data) {
    if (requestCode == RC_SIGN_IN) {
      if (resultCode == RESULT_OK) {
        // If the error resolution was successful we should continue
        // processing errors.
        signInState = STATE_SIGN_IN;
      } else {
        // If the error resolution was not successful or the user canceled,
        // we should stop processing errors.
        signInState = STATE_DEFAULT;
      }

      if (!googleApiClient.isConnecting()) {
        // If Google Play services resolved the issue with a dialog then
        // onStart is not called so we need to re-attempt connection here.
        googleApiClient.connect();
      }
    }
  }

  /**
   * The connection to Google Play services was lost for some reason. We call
   * connect() to attempt to re-establish the connection or get a
   * ConnectionResult that we can attempt to resolve.
   */
  @Override
  public void onConnectionSuspended(int cause) {
    googleApiClient.connect();
  }
}
```

This activity adds hooks to the life cycle so it can connect to Google+ easily.

## Sign-in functionality

We can now use GoogleActivity to add functionality to our sign-in button in Main.java:

```java
package com.example.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import com.google.android.gms.common.SignInButton;

/**
 * Sign in screen
 */
public class Main extends GoogleActivity
implements View.OnClickListener {
  /**
   * Sign in button
   */
  private SignInButton mSignInButton;

  /**
   * Show layout and attach event listener
   */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);

    mSignInButton = (SignInButton) findViewById(R.id.sign_in_button);
    mSignInButton.setOnClickListener(this);
  }

  /**
   * Resolve sign in errors when sign in button is clicked
   */
  @Override
  public void onClick(View v) {
    // We only process button clicks when GoogleApiClient is not transitioning
    // between connected and not connected.
    if (!googleApiClient.isConnecting()) {
      resolveSignInError();
    }
  }

  /**
   * Go to other activity when we connect successfully
   */
  @Override
  public void onConnected(Bundle connectionHint) {
    super.onConnected(connectionHint);

    final Intent destination = new Intent(this, Other.class);
    startActivity(destination);
  }
}
```

There are two important things happening here. First, we override onConnected so it opens Other Activity. This could happen even before the sign-in button is clicked if the user is already signed-in and given authorization to the app. The second thing to notice is the onClick method. Since we try to connect to Google automatically when the activity is started we just call resolveSignInError to fix the reasons why the user couldn&#8217;t connect. This will more likely show a dialog asking the user to authorize your application.

## Other Activity

At this point the app is broken because we try to open an Activity that doesn&#8217;t exist. Lets fix it by creating the activity. First lets add our activity to AndroidManifest.xml:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="com.example.app"
       android:versionCode="1"
       android:versionName="0.0.1">
    <uses-sdk android:minSdkVersion="9" android:targetSdkVersion="21" />

    <application android:label="@string/app_name">
        <meta-data android:name="com.google.android.gms.version"
               android:value="@integer/google_play_services_version" />
        <activity android:name="Main" android:label="@string/app_name">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <activity android:name="Other" android:label="@string/app_name" />
    </application>
</manifest>
```

Lets create the layout for other.xml:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="horizontal"
    android:padding="20dip">
      <Button
          android:id="@+id/sign_out_button"
          android:layout_width="wrap_content"
          android:layout_height="wrap_content"
          android:text="Sign out" />
      <Button
          android:id="@+id/revoke_access_button"
          android:layout_width="wrap_content"
          android:layout_height="wrap_content"
          android:text="Revoke" />
</LinearLayout>
```

The difference between the sign out button and the revoke button is that clicking revoke will ask the user for authorization next time they try to sign in. Signing out will just disconnect and allow the user to connect by just clicking the sign-in button again (without a dialog).

Now lets look at Other.java:

```java
package com.example.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import com.google.android.gms.plus.Plus;

/**
 * Signed in activity
 */
public class Other extends GoogleActivity
implements View.OnClickListener {
  /**
   * Sign out button
   */
  private Button signOutButton;

  /**
   * Revoke button
   */
  private Button revokeButton;

  /**
   * Initialize view. Bind click listeners.
   * @param savedInstanceState - You know ;)
   */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.other);

    signOutButton = (Button) findViewById(R.id.sign_out_button);
    revokeButton = (Button) findViewById(R.id.revoke_access_button);

    signOutButton.setOnClickListener(this);
    revokeButton.setOnClickListener(this);
  }

  /**
   * Process button clicks
   */
  @Override
  public void onClick(View v) {
    // We only process button clicks when GoogleApiClient is not transitioning
    // between connected and not connected.
    if (!googleApiClient.isConnecting()) {
      switch (v.getId()) {
          case R.id.sign_out_button:
            // We clear the default account on sign out so that Google Play
            // services will not return an onConnected callback without user
            // interaction.
            Plus.AccountApi.clearDefaultAccount(googleApiClient);
            googleApiClient.disconnect();
            googleApiClient.connect();
            break;
          case R.id.revoke_access_button:
            // After we revoke permissions for the user with a GoogleApiClient
            // instance, we must discard it and create a new one.
            Plus.AccountApi.clearDefaultAccount(googleApiClient);
            // Our sample has caches no user data from Google+, however we
            // would normally register a callback on revokeAccessAndDisconnect
            // to delete user data so that we comply with Google developer
            // policies.
            Plus.AccountApi.revokeAccessAndDisconnect(googleApiClient);
            googleApiClient = buildGoogleApiClient();
            googleApiClient.connect();
            break;
      }
      final Intent destination = new Intent(this, Main.class);
      startActivity(destination);
    }
  }
}
```

Here we add the functionality to disconnect or revoke permissions from Google. Once this is done we direct the user back to the Main activity.

That&#8217;s all is needed to sign-in to Google+ from an Android app.
