---
title: Writing a PWA with Svelte
author: adrian.ancona
layout: post
# date: 2021-01-13
# permalink: /2021/01/introduction-to-aws-dynamo-db
tags:
  - architecture
  - javascript
  - programming
  - application_design
---

In this article we're going to learn how to use Svelte to build a simple PWA (Progressive Web App). Some of the points we are going to cover:

- Developer experience - How easy was it to build the app?
- Performance - Time and size of first page load and page transitions
- Features - Help making the app a PWA:
    - Service workers
    - Manifest.json
    - HTTP2 push
    - Web notifications

## What is Svelte?

Svelte is one of the new competitors in the web app building battle. While most popular frameworks (Vue, React, etc.) provide libraries that run with our app in the browser, Svelte uses a compiler to transform our code into a version that contains only the minimum it requires to run. It promises to deliver fast and small web apps.

## The toolbox

One drawback of Svelte is that it's still pretty new, so things are chaging rapidly. I suspect if we build an application with Svelte today, the tools used to create that app might be deprecated in a few months.

We're going to be using the newest tools from Svelte, since that might be more similar to what the future will look like.

We start by creating a project:

```
```



