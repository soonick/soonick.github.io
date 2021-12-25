---
title: Introduction to Next JS - React framework
author: adrian.ancona
layout: post
date: 2021-02-03
permalink: /2021/02/introduction-to-next-js-react-framework
tags:
  - architecture
  - javascript
  - programming
  - react
---

In a recent article I gave an introduction to [React](/2021/01/introduction-to-react-js). That article shows the first steps of building React components, but leaves us very far from building a useful web application. In this article we will learn how to create a real world application using Next JS.

## Next JS

Next JS sells itself as the "React framework for production". They promise smooth user experience combined with a rich set of features to build fast apps.

## Environment set-up

To start an application from scratch we can use their generator:

```bash
npx create-next-app
```

We will be prompted for a name. I'll use `example` for my app.

When the command finishes, we can start our app in development mode:

```bash
npm run dev
```

What we get out of the box:
- Compilation and bundling (Babel and webpack)
- Auto-refresh on changes
- Static Site Generation (SSG) and Server Side Rendering (SSR)
- Server of static files (Files under `/public/`)

<!--more-->

## Pages

The generator creates a `/pages/` folder. In this folder there is a file named `_app.js`. This file defines the `MyApp` component, which is the entry point for an app:

```js
import '../styles/globals.css'

function MyApp({ Component, pageProps }) {
  return <Component {...pageProps} />
}

export default MyApp
```

As we can see, the only thing it does is render a `Component` with some props. The `Component` attribute depends on the current route, we don't need to worry about `pageProps` for now.

Next uses a file-system based router. This means that routes are created based on files inside `/pages/`. This means `index.js` will be rendered when the user navigates to `/`. When a user navigates to `/contact`, a file named `contact.js` will be used. If the file doesn't exist a 404 page will be shown.

## Pre-rendering

Next uses pre-rendering by default to make pages load fast. It supports 2 approaches: Static Site Generation and Server Side Rendering.

Static Site Generation refers to building an HTML page at compile time, and send this file as-is to users. This is the default mode. When we build a website in production mode, Next will compile the site and convert it into static pages. An example static page could be one that contains no dynamic elements:

```js
export default function Contact() {
  return <div>Call me</div>
}
```

Static pages can also be created based on dynamic sources (A database, a service, etc.). The problem is that the page won't be updated if the database is updated. This can be useful for pages that use information from a database, but we don't expect the data to change often (If the data changes, we will need to re-build the website to get the new values). To build a static page based on dynamic data, we can use `getStaticProps`:

```js
export default function Contact(props) {
  return <div>Call me: {props.phoneNumber}</div>
}

export async function getStaticProps() {
  // Here we could get information from a database, for example

  return {
    props: {
      phoneNumber: '213-344-2345'
    }
  }
}
```

This is there the `pageProps` in `_app.js` comes from.

The other alternative is Server Side Rendering (SSR). In this scenario, there won't be HTML pages generated. Instead, the Next server will receive the request, will execute the JS code to get the necessary data and then will return the generated page. Since the server does this for every request, it's slower. The benefit is that it will always return the latest information.

The only thing we need to do is use `getServerSideProps` instead:

```js
export default function Contact(props) {
  return <div>Call me: {props.phoneNumber}</div>
}

export async function getServerSideProps() {
  // Here we could get information from a database, for example

  return {
    props: {
      phoneNumber: '213-344-2345'
    }
  }
}
```

There are a lot of options related to pre-rendering that we are not going to cover in this article. [The documetation](https://nextjs.org/docs/basic-features/data-fetching) covers all these options.

## Client side rendering

If for some reason pre-rendering doesn't work for our use case we can always fall-back to client-side rending. This means Next will deliver some empty HTML skeleton and our code will be executed in the user's browser to fetch the data needed to show that page.

Two main disadvantages of this approach are:

- Not SEO (Search Engine Optimization) friendly
- It takes longer for the user to see useful information

Client side rendering can be performed in many ways that are not specific to the Next framework. For example, we could detect when a component is rendered and fetch some data for it at that point.

## Client side routing

After we have sent the initial page to the user (The landing page), we don't need to do a full page refresh to transition between pages. We can link pages using the `Link` component:

```js
import Link from 'next/link'

export default function Contact(props) {
  return <div>
    <div>Call me: {props.phoneNumber}</div>
    <Link href="/">Go home</Link>
  </div>
}

export async function getServerSideProps() {
  // Here we could get information from a database, for example

  return {
    props: {
      phoneNumber: '213-344-2345'
    }
  }
}
```

When a `Link` is clicked, the framework fetches only what it needs to render the new page without refreshing the whole page.

## CSS

In Next we can include CSS files from within our JS files using `import`. Styles imported from `_app.js` become global styles that can be used by any page. Our `_app.js` is already importing a stylesheet:

```js
import '../styles/globals.css'

function MyApp({ Component, pageProps }) {
  return <Component {...pageProps} />
}

export default MyApp
```

The import path is relative to the current file.

Styles can also be included only for specific components. This approach allows us to style our components without having to worry about class name collisions. To style our `Contact` component, we will create a file named `styles/Contact.module.css` (Notice the naming convention: `<ComponentName>.module.css`):

```css
.red {
  color: #f00;
}
```

We can now use the new styles:

```js
import Link from 'next/link'
import styles from '../styles/Contact.module.css'

export default function Contact(props) {
  return <div>
    <div className={styles.red}>Call me: {props.phoneNumber}</div>
    <Link href="/">Go home</Link>
  </div>
}

export async function getServerSideProps() {
  // Here we could get information from a database, for example

  return {
    props: {
      phoneNumber: '213-344-2345'
    }
  }
}
```

To apply the styles to an element, we use `className={styles.red}`.

## Building for production

We have so far been running Next in "development" mode. To build a production version we can use:

```bash
npm run build
```

This command will create a `.next` folder with a production version of the app (Code minified, static pages generated, etc). We can then start the app:

```bash
npm run start
```

This way of running a Next app if good for scenarios that require Server Side Rendering for some pages.

If our application only needs static pages we can instead `export` it. We start by adding an `export` script to `package.json`:

```js
{
  // Code omitted for brevity
  "scripts": {
    // Code omitted for brevity
    "export": "next export"
  },
  // Code omitted for brevity
}
```

We can now run the script (`npm run build` has to be run before):

```bash
npm run export
```

A folder named `out` will be created. This folder can then be deployed to a static server or a CDN.

## Conclusion

Next seems like a nice tool to get started building a web application fast. It provides the necessary tooling out of the box, which is great for people who are not expert web developers.

On top of the ease of development, SSG and SSR helps with SEO and improve the user experience, which are usually problems people encounter when building web applications using React.
