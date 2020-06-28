---
title: Push notifications on web applications
author: adrian.ancona
layout: post
# date: 2020-07-08
# permalink: /2020/07/push-notifications-on-web-applications/
tags:
  - javascript
  - programming
  - application_design
---

In this post I'm going to explore how to use the [Notification API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API) and the [Push API](https://developer.mozilla.org/en-US/docs/Web/API/Push_API) to send push notifications to users.

Push notifications are built on top or service workers, so taking a look at [using service workers for caching](/2019/12/using-service-workers-for-caching/) might be useful.

## Notification API

The notification API provides allows us to create notifications for the user. In a phone they will look like a native app notification, while in the browser they will look like a pop up.

Let's make a simple web page that shows a simple notification (`index.html`):

```html
<html>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <button id="notification">Show notification</button>
  <script>
    // Register service worker. The app won't be able to show notifications if
    // it doesn't register a service worker
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', () => {
        navigator.serviceWorker.register('/worker.js').then(registration => {
          // Registered successfully
        }, err => {
          alert('failed to register service worker');
        });
      });
    }

    // Sadly, not all browsers support notifications. This can be used to test
    // for support
    if (!('Notification' in window)) {
      alert('Your browser doesn\'t support notifications');
    }

    document.getElementById('notification').addEventListener('click', () => {
      // Before we can show notifications, we need to request permission
      Notification.requestPermission(status => {
        if (status !== 'granted') {
          alert('You blocked notifications');
          return;
        }

        // Show the notification
        navigator.serviceWorker.getRegistration().then(reg => {
          reg.showNotification('Our first notification');
        });
      });
    });
  </script>
</html>
```

We will need `worker.js` to exist. We can create an empty file for now.

The code above will creates a web app with a single button that when clicked will show a notification. The first of part of the JavaScript code registers a service worker, since it's a requirement for notifications.

Since there are some browsers (namely, apple browsers) that are not up to speed with web standards, we need to check if the feature is available:

```js
// Sadly, not all browsers support notifications. This can be used to test
// for support
if (!('Notification' in window)) {
  alert('Your browser doesn\'t support notifications');
}
```

The example shows an alert if notifications are not available. In a real application, you might have to live with it, and provide a degraded experience (without notifications).

The next interesting part is the event listener:

```js
Notification.requestPermission(status => {
  if (status !== 'granted') {
    alert('You blocked notifications');
    return;
  }

  // Show the notification
  navigator.serviceWorker.getRegistration().then(reg => {
    reg.showNotification('Our first notification');
  });
});
```

We need to get permission from the user to show notifications, so we use `Notification.requestPermission` for this. If the user allows notifications, the status will be `granted`. Subsequent calls to `Notification.requestPermission` won't result on the user being asked multiple times. The callback will be executed with the status provided by the user when they were first asked.

Finally, it's time to show the notification. For this, we get the service worker registration and call `showNotication`. This simple example just shows a string, but we'll make them look a little better next.

We can use python to start a server and test what we have done:

```sh
python -m SimpleHTTPServer 9876
```

Then go to `http://localhost:9876` and click the button. The result should look something like this:

[<img src="/images/posts/first-pwa-notification.png" alt="First PWA notification" />](/images/posts/first-pwa-notification.png)

The [showNotification](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/showNotification) has the following signature:

```js
showNotification(title, [options]);
```

The options argument can be used to configure the notification. For example, we can add an image to it:

```js
navigator.serviceWorker.getRegistration().then(reg => {
  const options = {
    icon: 'icon.png'
  };
  reg.showNotification('Smiley face', options);
});
```

The result looks like this:

[<img src="/images/posts/smiley-pwa-notification.png" alt="Smiley PWA notification" />](/images/posts/smiley-pwa-notification.png)

A notification will be default notify the user (depending on their settings it might vibrate or beep). If we don't want to do this, we can mark it as silent:

```js
navigator.serviceWorker.getRegistration().then(reg => {
  const options = {
    icon: 'icon.png',
    silent: true
  };
  reg.showNotification('Smiley face', options);
});
```

The notification bar will by default show a browser icon when there is a notification for any PWA, but we can provide our own icon:

```js
navigator.serviceWorker.getRegistration().then(reg => {
  const options = {
    icon: 'icon.png',
    badge: 'badge.png'
  };
  reg.showNotification('Smiley face', options);
});
```

The badge should be a `png` image using only color white, and it should be at least 96px by 96px.

A notification can be given an ID using a tag. If a notification with the same tag value is started it will overwrite the previous one.

```js
navigator.serviceWorker.getRegistration().then(reg => {
  const options = {
    tag: 'someid'
  };
  window.myCounter = window.myCounter ? window.myCounter + 1 : 1;
  reg.showNotification('Smiley face ' + window.myCounter, options);
});
```

The code above will update the notification with a new number every time. By default updating a notification will not notify the user, if we want the user to be notified, we can pass `renotify: true`.

Now that we know how to show notifications, let's see how users can interact with them. A notification can contain some arbirary `data` that can be used by the web app. We just need to trigger a functions to do the processing we need. By default, we can set event listeners for when the user closes the notification or when they click it. We can also add custom actions:

```js
navigator.serviceWorker.getRegistration().then(reg => {
  const options = {
    icon: 'icon.png',
    badge: 'badge.png',
    body: 'Do you want this smiley face?',
    actions: [
      { action: 'iLikeIt', title: 'Yes', icon: 'check.png' },
      { action: 'iDontLikeIt', title: 'No', icon: 'cross.png' }
    ],
    data: {
      'smileyId': 9876543,
      'smileyUrl': '/icon.png'
    }
  };
  reg.showNotification('Smiley face', options);
});
```

The notification will look like this on an phone:

[<img src="/images/posts/phone-pwa-notification.png" alt="Phone PWA notification" />](/images/posts/phone-pwa-notification.png)

Handling user actions needs to be done in the service worker (`worker.js`):

```js
self.addEventListener('notificationclick', event => {
  const action = event.action;
  const notification = event.notification;
  const smileyId = notification.data.smileyId;

  if (action == 'iLikeIt') {
    console.log('User liked smiley ' + smileyId);
  } else if (action == 'iDontLikeIt') {
    console.log('User didn\'t like smiley ' + smileyId);
  } else {
    // They clicked the notification, but not any of the action buttons
    const url = notification.data.smileyUrl;
    if (url) {
      clients.openWindow('https://localhost:9876' + url);
    }
  }

  notification.close();
});

self.addEventListener('notificationclose', event => {
  const action = event.action;
  const notification = event.notification;
  const smileyId = notification.data.smileyId;
  console.log('User didn\'t respond for smiley ' + smileyId);
});
```

In the example above we can see that 'notificationclose' event is triggered if the user explicitly closes the notification. If the user clicks the notification or any of the action buttons, `notificationclick` will be triggered.

We can also see that `event.notification.data` contains the data from the notification, and `event.action` contains the action that was selected by the user.

## Push API

Now that we know how to show notifications, let's proceed to learn how we can listen to notification messages sent from our servers.

Before our app can receive notifications it needs to request a subscription from the browser. To do this, we need the service worker registration (`index.html`):

```js
registration.pushManager.getSubscription().then(subscription => {
  if (subscription) {
    return subscription;
  }

  return registration.pushManager.subscribe({
    // This means that all push events will result in a notification
    userVisibleOnly: true
  });
}).then(subscription => {
  // Send the subscription details to our server
  fetch('http://localhost:9999/register-push-device', {
    method: 'post',
    headers: {
      'Content-type': 'application/json'
    },
    body: JSON.stringify({
      subscription: subscription
    }),
  });
});
```

application server keys: https://developers.google.com/web/fundamentals/push-notifications/subscribing-a-user

Right after registering our service worker, we use that registration to get our push subscription. If we don't have a push subscription yet, we request one. Before we continue it's worth talking a little about what happens here.

When we request a push subscription, our browser will first generate a key pair for us (a private and a public key). It will then ask their `push service` (Different browsers will use different push services) for a subscription, passing the public key that it generated. The push service generates a unique URL and sends it back to the server. The resulting subscription looks like this for us:

```
{
  "endpoint": "https://updates.push.services.mozilla.com/wpush/v1/gAAAAABe7ruTkV65q-11wPk4gnWu022HtidezPePx5mWmmmWmz",
  "keys": {
    "auth": "SnhbZ2I_E7aBnK_ZI9tRTg",
    "p256dh": "BMhflLnnr2I8czZgH_B6gHQcjisClt1f-T1ShCR4hnbCiosIdDewWBw3SCz4AbNoXXvH4Bd3Qu3J7k8Q"
  }
}
```




What 
The `endpoint` is the URL where we will send our push notification. The `keys` are called `applicationServerKeys`. They are used to identify the server that is allowed to send push messages to this app. This makes sure that only our server can send push notifications to our app.



The server will then receive the subscription object with an `endpoint` it can use to push notifications. Let's create a node server to receive the subscription:

```
```

* Anybody can push to the endpoint, so it needs to be protected
* This is a lot more fucking complex than I expected




https://codelabs.developers.google.com/codelabs/pwa-integrating-push/index.html?index=..%2F..dev-pwa-training#2
