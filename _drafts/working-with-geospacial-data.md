---
title: Using H3geo to work with geospacial data
author: adrian.ancona
layout: post
# date: 2021-01-13
# permalink: /2021/01/introduction-to-aws-dynamo-db
tags:
  - open_source
  - productivity
  - programming
  - vim
---

H3geo is a geospatial indexing system (GIS) built by Uber. GIS can be used to create systems that deal with geographic information (maps).

## Maps and projections

Before we dive into H3geo, it's useful to understand how maps works. We use maps of earth to get an idea of how the surface looks like and represent information about what's in that surface.

Most people reading this article have probably seen a map before. Nowadays we see maps in our phones all the time:

[<img src="/images/posts/google-maps-user.jpeg" alt="Google maps user" />](/images/posts/google-maps-user.jpeg)

These maps, as well as paper maps, are shown in a flat surface, but we all know that earth isn't flat. The action of representing earth on a flat map is called a `projection`.

One of the most popular ways of showing a map is using the [mercator projection](https://en.wikipedia.org/wiki/Mercator_projection), which works by wrapping the earth on a cylinder, projecting each point into this cylinder:

[<img src="/images/posts/mercator-projection.gif" alt="Mercator projection" />](/images/posts/mercator-projection.gif)

This gives us a representation of earch where points farther from the Ecuator look larger than those near the Ecuator.

... Other projections
