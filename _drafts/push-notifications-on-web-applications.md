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


################## TODO: Show other options. More specifically: badge (Notification bar icon), (renotify and tag), silent, vibrate

Now that we know how to show notifications, let's see how users can interact with them. 


data and actions


https://codelabs.developers.google.com/codelabs/pwa-integrating-push/index.html?index=..%2F..dev-pwa-training#2
