---
title: Using service workers for caching
author: adrian.ancona
layout: post
tags:
  - javascript
  - programming
  - application_design
---

## What's a service worker?

A service worker is a script that can be used as a client-side proxy for network requests. When the browser makes a request, a service worker can intercept it and decide what to do with it. This article is going to focus on using service workers for client side caching of web apps.

## Why use service workers?

Service workers can be used to improve the performance and user experience of an application. They can be used to cache assets that are commonly needed but don't change often, or to provide offline functionality.

## HTTPS

For security reasons, service workers only work over HTTPs.

## Registration

Before using a service worker, it is necessary to register it. In the HTML of the page, add something like this:

```js
<script>
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/worker.js').then(registration => {
      // Registered successfully
    }, err => {
      // Registration failed
    });
  });
}
</script>
```

The code above first verifies if the browser is compatible with service workers. If it is, it will try to download `/worker.js`. This file is going to have all the code for the service worker.

There is a callback for success and one for failure. The registration can fail for multiple reasons; One of the reasons could be the service worker not being found.

## Scope

If you look at the success callback, you will notice that it receives an argument. The argument is a `ServiceWorkerRegistration` with some information about the service worker. One of the properties of this object is the `scope`.

If the service worker is located at `/worker.js`, inspecting the value of `registration.scope` will return something like `https://ncona.com/`. This means that the service worker can intercept any request under `https://ncona.com/`.

The scope changes depending on the location of the service worker. If the service worker was located at `https://ncona.com/folder/worker.js`, then the scope would be `https://ncona.com/folder` and it would only work with requests under that path.

It is possible to have more than one service worker under one domain with different scopes, but you probably don't want to do it unless you have very specific needs. If a service worker is registered for `/` and another one for `/folder/`; the service worker with `/` scope won't be able to see any requests under `/folder/`. All those request will go to the service worker with a more specific scope.

## [CacheStorage](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage) and [Cache](https://developer.mozilla.org/en-US/docs/Web/API/Cache)

A `Cache` is a key-value store where the key is a Request and the value is a Response. When we intercept a request we want to cache, we will wait for the response and then add it to this storage.

A `CacheStorage` is a key-value store where the key is a string representing the name for a cache and the value is a `Cache` object. It is possible to have multiple caches; for example: "STATIC_ASSETS", "API_REQUESTS". Most often you'll interact with a global variable named `caches` which is an instance of `CacheStorage`.

To create or open a `Cache`, we can use the `open` method:

```js
const cache = await caches.open(API_CACHE);
```

If a cache with that name doesn't exist, an empty `Cache` will be returned.

We'll look more closely into `Cache` later on this article.

## Installation

Now it's time to move to the service worker code.

After a service worker is downloaded, it will be "installed". As part of the installation, an `install` event will be triggered:

```js
// This code goes inside the service worker (`worker.js`)
self.addEventListener('install', async (event) => {
  console.log('sw installed');
});
```

If there is a problem on this callback, the service worker won't be installed and it won't work.

The install event is triggered only once. If the page is refreshed and the service worker didn't change, the `install` event won't be triggered again. Only if the service worker changes the new one will be installed.

One common step as part of the installation of a service worker is downloading and cachine some assets. Let's say we want to cache the app logo:

```js
const STATIC_ASSETS_CACHE = "STATIC_ASSETS_CACHE_V1";

self.addEventListener('install', event => {
  const download = async () => {
    // Open or create a cache for static assets
    const cache = await caches.open(STATIC_ASSETS_CACHE);

    // Tries to download `logo.png`. If the request succeeds, it will be added
    // to the cache
    return cache.add('/logo.png');
  }

  // waitUntil delays the event until the given promise has been fulfilled.
  // In this case, it delays the event until all the assets have been downloaded
  event.waitUntil(download());
});
```

I added some comments, explaining what is happening. If more than one asset needs to be cached, `addAll` provides a way to do this:

```js
const STATIC_ASSETS_CACHE = "STATIC_ASSETS_CACHE_V1";

const staticAssets = [
  'logo.png',
  'other-image.png'
];

self.addEventListener('install', event => {
  const download = async () => {
    const cache = await caches.open(STATIC_ASSETS_CACHE);
    return cache.addAll(staticAssets);
  }
  event.waitUntil(download());
});
```

## Debugging

Before we move further with service workers, I think it's good to talk a little about debugging.

One thing to understand about service workers is that they follow a different lifecycle than the web app they support. When an app is loaded for the first time by the browser, and it registers a service worker, the service worker will be downloaded and installed, but it won't be used for that session.

To see the service worker in action you might need to close the current tab and open a new one.

Usual debugging primitives can be used inside of service workers. `console.log` and `debugging` will work as expected if used inside of service worker code.

Another tool that can help understand what is happening is the browser developer tools. In Chrome, the Application tab will show you information about the currently installed and running service worker:

[<img src="/images/posts/sw-application-tab.png" />](/images/posts/sw-application-tab.png)

In the cache section in the same tab, you can inspect the contents of the cache for your service worker:

[<img src="/images/posts/sw-caches-debugging.png" />](/images/posts/sw-caches-debugging.png)

## Fetch

Once we have some responses cached, we need a way to retrieve them from our cache instead of making the actual request. Here is where `fetch` comes into play:

```js
self.addEventListener('fetch', event => {
  const retrieve = async () => {
    // caches.match will return the response that matches the request or
    // undefined if the request is not found in the cache
    const response = await caches.match(event.request);

    // If this request is not in the cache, we send the request to the network
    return response ? response : fetch(event.request);
  };

  // respondWith allows us to overwrite the response for this fetch event
  event.respondWith(retrieve());
});
```

The example above shows one of the simplest ways to serve a response from cache. A more elaborate example would be to try to find a request in the cache; if it's not found, make the request and cache that response to use in the future:

```js
const API_CACHE = "API_CACHE_V1";

self.addEventListener('fetch', event => {
  const retrieve = async () => {
    const cachedResponse = await caches.match(event.request);

    // Cache hit - return response
    if (cachedResponse) {
      return cachedResponse;
    }

    const response = await fetch(event.request);

    // If it's a bad response, don't cache it
    if (!response || response.status !== 200) {
      return response;
    }

    // A response stream can only be consumed once. If we want to store one in
    // the cache and give one back, we need to make a clone of the response
    // before it has been consumed. Whenever we retrieve a response from the
    // cache, we are actually retrieving a clone
    var responseClone = response.clone();

    const cache = await caches.open(API_CACHE);
    cache.put(event.request, responseClone);

    return response;
  };

  event.respondWith(retrieve());
});
```

The code above shows an example of caching requests on the fly. A huge problem with the code above is that once it caches a request, it will always return a response from cache, which is most likely not what you want.

## What and when to cache

Knowing how to cache requests is the easy part. The hard part is knowing what to cache and when.

First of all, the data we can store in the cache isn't unlimited, so we can't store everything there. The limit is somehow opaque to developers so the application needs to be written with the assumption that things can dissapear from the cache at any time.

I don't claim to know everything about caching, but I'll list some things that I like to keep in mind:

- **Static assets** - This refers to images, icon, fonts, etc, that are part of your application and don't change very often. There are build systems that rename static assets bassed on a hash of their contents. If you are using one of these systems, you can cache your static assets forever. Whenever an icon changes it will be given a new name, so it will be always downloaded and cached.

- **Application** - If you have a build system in place that renames your html and js files, you can for the most part do the same as for static assets. And exception to this will be your main page (index.html). Most of the time you will want to load the most recent version; only when there is no network (the request fails), you will want to load this page from cache.

- **API requests** - In mosts cases you won't want to cache your API requests, but it is possible that you want to cache some read requests. An example could be a request that returns information about the currently logged in user. If the logged in user is the same as the one making the request, you could serve it from cache (This could have security implications that should be considered). In any case you most likely want to try to get the freshest information from your server and only serve from cache if the user is offline.

## Example

Let's look at how we can implement the different caching strategies with a service worker. We can separate our strategies with simple if statements:

```js
self.addEventListener('fetch', event => {
  const retrieve = async () => {
    if (isStaticAssetRequest(event.request)) {
      return handleStaticAssetRequest(event.request);
    }

    if (isApplicationRequest(event.request)) {
      return handleApplicationRequest(event.request);
    }

    if (isApiRequest(event.request)) {
      return handleApiRequest(event.request);
    }

    // If there is no match, forward the request to the server
    return await fetch(event.request);
  };

  event.respondWith(retrieve());
});
```

Now, let's look at the static assets case:

```js
function isStaticAssetRequest(request) {
  if request
}

function handleStaticAssetRequest(request) {
}
```

--- A bug in the service worker can cause the whole application not to work. To fix this install a new empty service worker








https://developers.google.com/web/fundamentals/primers/service-workers
https://blog.bitsrc.io/understanding-service-workers-and-caching-strategies-a6c1e1cbde03
https://developers.google.com/web/fundamentals/primers/service-workers/lifecycle
