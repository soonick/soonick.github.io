---
title: Introduction to Gatsby framework for React
author: adrian.ancona
layout: post
# date: 2021-01-13
# permalink: /2021/01/introduction-to-aws-dynamo-db
tags:
  - architecture
  - javascript
  - programming
  - react
  - application_design
---

In this article we're going to learn how to use Gatsby to build a simple PWA (Progressive Web App). Some of the points we are going to cover:

- Developer experience - How easy was it to build the app?
- Performance - Time and size of first page load and page transitions
- Features - Help making the app a PWA:
    - Service workers
    - Manifest.json
    - HTTP2 push
    - Web notifications

## Bootstrap

Gatsby depends on [node](https://nodejs.org/en/), so we need to make sure it's installed in our system.

Gatsby provides a CLI to help us start a new app:

```sh
npm install -g gatsby-cli
```

We can use it to start a new project:

```sh
gatsby new gatsby https://github.com/gatsbyjs/gatsby-starter-hello-world
```

To start the app in development mode:

```sh
gatsby develop
```

Finally, go to `http://localhost:8000/`. We'll see a "Hello world!" page.

## Development

Gatsby comes with hot reload by default, so as soon as a change is made to a file in the project, the page will be refreshed and the change will take effect.

If we look at `gatsby/src/pages/index.js`, we'll se the code for our main page:

```js
import React from "react"

export default function Home() {
  return <div>Hello world!</div>
}
```

In Gatsby, all pages are [React](https://reactjs.org/) components under `src/pages`. To create a new page, we just need to add it to that folder.

Let's say we create the file: `src/pages/profile.js` with this content:

```js
import React from "react"

export default function Profile() {
  return <div>My profile</div>
}
```

We can now visit `http://localhost:8000/profile` and see our new page.

Gatsby provides the `Link` component to link between pages. We can add it to both our pages:

```js
import React from "react"
import { Link } from "gatsby"

export default function Home() {
  return (
    <div>
      <div>Hello world!</div>
      <Link to="/profile">Profile page</Link>
    </div>
  )
}
```

And

```js
import React from "react"
import { Link } from "gatsby"

export default function Profile() {
  return (
    <div>
      <div>My profile</div>
      <Link to="/">Homepage</Link>
    </div>
  )
}
```




## Building for production

```
Gatsby build
```







https://www.gatsbyjs.com/
https://nextjs.org/
