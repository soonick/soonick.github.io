---
title: Push notifications on web applications
author: adrian.ancona
layout: post
date: 2020-07-15
permalink: /2020/07/push-notifications-on-web-applications/
tags:
  - javascript
  - programming
  - application_design
---

In this post I'm going to explore how to use the [Notification API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API) and the [Push API](https://developer.mozilla.org/en-US/docs/Web/API/Push_API) to send push notifications to users.

Push notifications are built on top or service workers, so taking a look at [using service workers for caching](/2019/12/using-service-workers-for-caching/) might be useful.

I have created a minimal [web-push-example that can be found in github](https://github.com/soonick/web-push-example).

<!--more-->

## Notification API

The notification API allows us to show notifications users. In a phone they will look like a native app notification, while in the browser they will look like a pop up.

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

The code above creates a web app with a single button that when clicked will show a notification. The first of part of the JavaScript code registers a service worker, since it's a requirement for notifications.

Since there are some browsers (namely apple browsers) that are not up to speed with web standards, we need to check if the feature is available:

```js
// Sadly, not all browsers support notifications. This can be used to test
// for support
if (!('Notification' in window)) {
  alert('Your browser doesn\'t support notifications');
}
```

The example shows an alert if notifications are not available. In a real application, we might have to provide a degraded experience (without notifications).

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

We need to get permission from the user to show notifications. We use `Notification.requestPermission` for this. If the user allows notifications, the status will be `granted`.

Subsequent calls to `Notification.requestPermission` won't result in the user being asked multiple times. The callback will be executed with the status provided by the user when they were first asked.

Finally, it's time to show the notification. For this, we get the service worker registration and call `showNotication`. This simple example just shows a string, but we'll make them look a little better next.

We can use python to start a server and test what we have done:

```sh
python -m SimpleHTTPServer 9876
```

Then go to `http://localhost:9876` and click the button. The result should look something like this:

[<img src="/images/posts/first-pwa-notification.png" alt="First PWA notification" />](/images/posts/first-pwa-notification.png)

The [showNotification](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/showNotification) method has the following signature:

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

A notification will by default notify the user by beeping or vibrating. If we don't want to do this, we can mark it as silent:

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

Now that we know how to show notifications, let's see how users can interact with them. A notification can contain some arbirary `data` that can be used by the web app. We just need to trigger a function to do the processing we need. By default, we can set event listeners for when the user closes the notification or when they click it. We can also add custom actions:

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

The notification will look like this on a phone:

[<img src="/images/posts/phone-pwa-notification.jpg" alt="Phone PWA notification" />](/images/posts/phone-pwa-notification.jpg)

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

Before we start writing code for sending and receiving push notifications, it is useful to know a little about the push protocol.

There are 3 players when it comes to push notifications:
- The browser - Sometimes referred to as user agent
- The server - Our web server that will generate and send notifications
- The push service - A third party service where our server sends push notifications. This service will make sure the notification is delivered to the browser

There are 2 things the web push protocol ensures:
- All our messages are encrypted so only the user's browser can read them (The push service won't be able to read them)
- Only our server can send push notifications to our users

To make sure only our server can send push notifications to our users, we need to start by generating a key pair. To do this we can use the npm package `web-push`:

```sh
mkdir tmp-folder
cd temp-folder
npm install web-push
node ./node_modules/web-push/src/cli.js generate-vapid-keys --json
```

This will generate a public and private key:

```json
{
  "publicKey": "BHo63e6lXyh2L9_VU8M6dM0bREJcwIO5QRBs2ZB_AVEKOmaKuseoids_yId54cD8VzZ1WdIPQWFfTaTYE4WZ7gQ",
  "privateKey":"w9zYauQoMggimjDh3Si_FNthepJSQ-4_xdF4DNPn7uY"
}
```

The private key will be used by our server to sign push notifications. The public key will be sent to the push service by the browser. The push service will use it to validate that the push notifications come from us. Whoever has the private key will be able to send push notifications to our app, so it needs to be kept secret.

To ensure only our users' browsers can see the push notifications we need another set of keys. This set of keys will be generated by the browser when we request a push subscription:

```
{
  "endpoint": "https://updates.push.services.mozilla.com/wpush/v1/gAAAAABe7ruTkV65q-11wPk4gnWu022HtidezPePx5mWmmmWmz",
  "keys": {
    "auth": "SnhbZ2I_E7aBnK_ZI9tRTg",
    "p256dh": "BMhflLnnr2I8czZgH_B6gHQcjisClt1f-T1ShCR4hnbCiosIdDewWBw3SCz4AbNoXXvH4Bd3Qu3J7k8Q"
  }
}
```

- `endpoint` - The URL where we will send our push notifications
- `auth` - A secret that will only be known by the server
- `p256dh` - The generated public key

Both the browser and our server have now generated and shared public keys. Our server can now use [ECDH](https://www.youtube.com/watch?v=F3zzNa42-tQ) to encrypt messages that can be decrypted by the browser.

Let's have our web app request a subscription and push it to our server:

```js
const VAPID_PUBLIC = 'BHo63e6lXyh2L9_VU8M6dM0bREJcwIO5QRBs2ZB_AVEKOmaKuseoids_yId54cD8VzZ1WdIPQWFfTaTYE4WZ7gQ';

// We need this function to transform our VAPID public key to the correct format
// for requesting a subscription
function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding)
    .replace(/-/g, '+')
    .replace(/_/g, '/');

  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

// Register service worker. The app won't be able to show notifications if
// it doesn't register a service worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/worker.js').then(registration => {
      return registration.pushManager.getSubscription();
    }).then(subscription => {
      if (subscription) {
        return subscription;
      }

      const convertedVapidKey = urlBase64ToUint8Array(VAPID_PUBLIC)
      return registration.pushManager.subscribe({
        // This means all push events will result in a notification
        userVisibleOnly: true,
        applicationServerKey: convertedVapidKey
      });
    }).then(subscription => {
      // Send the subscription details to our server
      fetch('http://localhost:9999/register-push-device', {
        method: 'post',
        headers: {
          'Content-type': 'application/json'
        },
        body: JSON.stringify({ subscription: subscription })
      });
    });
  });
}
```

The serialized subscription object looks like this:

```js
{
  "endpoint": "https://updates.push.services.mozilla.com/wpush/v1/gAAAAABe7ruTkV65q-11wPk4gnWu022HtidezPePx5mWmmmWmz",
  "keys": {
    "auth": "SnhbZ2I_E7aBnK_ZI9tRTg",
    "p256dh": "BMhflLnnr2I8czZgH_B6gHQcjisClt1f-T1ShCR4hnbCiosIdDewWBw3SCz4AbNoXXvH4Bd3Qu3J7k8Q"
  }
}
```

We will also need to listen to `push` events from our service worker:

```js
self.addEventListener('push', event => {
  event.waitUntil(
    self.registration.showNotification(event.data.text())
  );
});
```

The last step is to create a simple node server that will use this information to send push notifications (`app.js`):

```sh
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const webpush = require('web-push');
const app = express();
const port = 9999;

const VAPID_PUBLIC = 'BHo63e6lXyh2L9_VU8M6dM0bREJcwIO5QRBs2ZB_AVEKOmaKuseoids_yId54cD8VzZ1WdIPQWFfTaTYE4WZ7gQ';
const VAPID_PRIVATE = 'w9zYauQoMggimjDh3Si_FNthepJSQ-4_xdF4DNPn7uY';

let subscription;

webpush.setVapidDetails(
  'mailto:example@yourdomain.org',
  VAPID_PUBLIC,
  VAPID_PRIVATE
);

app.use(bodyParser.json());
app.use(cors());

app.post('/register-push-device', (req, res) => {
  console.log('saving subscription');
  subscription = req.body.subscription;
  res.end();
});

app.get('/send-notification', (req, res) => {
  console.log('sending notification');
  // webpush takes care of all the complexity related to encryption and signing
  // of messages
  webpush.sendNotification(subscription, 'My message').catch((ex) => {
    console.log(ex);
  });
  res.end();
});

app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`));
```

Luckily, the `web-push` library takes care of most of the complexity related to sending a push notification. Our server simply saves the subscription and uses it to send a push notification when `/send-notification` is visited.

In the real world, we will probably have one subscription per user device and send notifications when something interesting happens that the user needs to be aware of.

To run the server:

```sh
npm install express web-push body-parser cors
node app.js
```

[A working example can be found in github](https://github.com/soonick/web-push-example).

## Conclusion

In this post I covered how to show push notifications and how to send push notifications from a server to a web app. The example I showed is very naive, but it shows the mechanisms that need to be used in a real app.
