---
title: Internationalization (i18n) of Svelte Apps
author: adrian.ancona
layout: post
date: 2025-04-30
permalink: /2025/04/internationalization-of-svelte-apps/
tags:
  - javascript
  - programming
---

Internationalization is the process of making a website that is adaptable to different locales (regions or languages). Translation is a large part of it, but there are other aspects, like date formatting, for example.

There is no single standard way to do internationalization. In this article we'll learn the approach I chose, but there are other ways to achieve a similar result.

## URLs

To make an internationalized app SEO friendly, it's recommended to have locale-prefixed URLs. This means, if we have a `dashboard` page, the URL for it will be something like: `/<lang>/dashboard`.

This, of course, leaves the possibility of someone visiting our pages without a prefix, for example: `/dashboard`. In this scenario, we will use locale detection to redirect users to the correct page for their language.

<!--more-->

## Detecting the user's locale

We're going to build a web app that supports 2 locales: English and Spanish. So, we'll need a way to decide which of the two languages to show.

For a first time visitor, we can take advantage of the [Accept-Language](https://httpwg.org/specs/rfc9110.html#field.accept-language) request header. The browser automatically sends this header with each request, so we can inspect the value and decide which language to show.

The values for the header follow [RFC5646](https://datatracker.ietf.org/doc/html/rfc5646), which covers a lot of details, but for most scenarios can be summarized as a case-insensitive string that can be divided in sections separated by dashes (-). The first section usually specifies the main language, and the second section usually identifies a region. Some examples are:

- en-US - English as spoken in the US
- en-CA - English as spoken in Canada
- es-MX - Spanish as spoken in Mexico
- es-ES - Spanish as spoken in Spain

In our case, we will only look at the value before the first dash, and we will serve the Spanish version if it's equal to `es`. For any other locale, we will serve the English version.

## User chosen locale

It is possible that a user wants to visit a version of the website that doesn't match their browser's locale. For this kind of scenarios, we will also provide a way for users to choose their preferred language.

If a user selects a language we should redirect them to the current page, but in the chosen locale.

## Localized URLs with Svelte

Now, that we know what we want to do, we need to figure out how to do it. Let's say we are starting with a not-localized app with this folder structure:

```
project/
├ src/
│ ├ routes/
│ │ ├ +layout.svelte
│ │ ├ dashboard
│ │ │ └ +page.svelte
│ │ └ +page.svelte
│ ├ app.html
├ package.json
├ svelte.config.js
├ tsconfig.json
└ vite.config.js
```

This app contains only two pages: `/` and `/dashboard`.

In order to add a language prefix to all our URLs, we need to use an [optional parameter](https://svelte.dev/docs/kit/advanced-routing#Optional-parameters) at the beginning of all our routes. For this, we will change the structure of our `routes` directory:

```
routes/
├ [[lang]]
│ ├ +layout.svelte
│ ├ dashboard
│ │ └ +page.svelte
│ └ +page.svelte
```

To prevent the `/dashboard` page from being interpreted as the root page, with `lang=dashboard`, we need to use a parameter matcher. Matchers need to be created in the `src/params` folder.

We will create the file `src/params/lang.ts`:

```ts
import type { ParamMatcher } from '@sveltejs/kit';

export const match = ((param: string) => {
  return param === 'en' || param === 'es';
}) satisfies ParamMatcher;
```

The matcher we created is a very simple function that returns true, if the first part of the route is either `en` or `es`. We activate the matcher by updating the name of the parameter folder:

```
routes/
├ [[lang=lang]]
│ ├ +layout.svelte
│ ├ dashboard
│ │ └ +page.svelte
│ └ +page.svelte
```

At this point our app will render the root page when any of these URLs is visited:

- /
- /en
- /es

And the dashboard page, when these are visited:

- /dashboard
- /en/dashboard
- /es/dashboard

## Redirecting to user's locale

Currently, the user has access to routes that don't contain locale information (`/` and `/dashboard`). When they try to access any of these pages, we want to redirect them to the localized version based on the request's `Accept-Language` header.

For this, we are going to create `+layout.server.ts`:

```
routes/
├ [[lang=lang]]
│ ├ +layout.server.ts
│ ├ +layout.svelte
│ ├ dashboard
│ │ └ +page.svelte
│ └ +page.svelte
```

With this content:

```ts
import { redirect } from '@sveltejs/kit';

const supportedLangs = ['en', 'es'];

export const load = async ({ params, url, request }) => {
  if (!supportedLangs.includes(params.lang || '')) {
    const accept = request.headers.get('accept-language');
    let preferred = accept?.split(',')[0].split('-')[0] ?? 'en';
    preferred = supportedLangs.includes(preferred) ? preferred : 'en';
    throw redirect(302, `/${preferred}${url.pathname}`);
  }

  return {
    lang: params.lang
  };
};
```

The code checks if the `lang` parameter is set. If it is not, it checks for the `accept-language` header to figure out the user's preferred language. Finally, redirects the user to the corresponding localized URL.

## Localized links

Now that our app supports localized URLs, we need to make sure all the links in our app are localized. e.g. If the user is currently in `/es` and clicks on a link to the dashboard page, they should be directed to `/es/dashboard`.

To do this we will use the `page` store:

```html
<script lang="ts">
    import { page } from '$app/stores';
</script>

<a href={`/${$page.params.lang}/dashboard`}>Dashboard</a>
```

## Locale selector

We also want to allow the user to choose their preferred locale.

Since we only support 2 languages, we're going to show a button with the word `Español` when in the English version and a link with the word `English` when in the Spanish version. When the user clicks this link we'll simply direct them to the same page in the selected locale.

We'll use a component for this:

```html
<script lang="ts">
  import { page } from '$app/stores';

  let text = $state('');
  let link = $state('');

  $effect(() => {
    const parts = $page.url.pathname.split('/');
    if ($page.params.lang === 'es') {
      text = 'English';
      parts[1] = 'en';
    } else {
      text = 'Español';
      parts[1] = 'es';
    }
    link = parts.join('/');
  });
</script>

<a href={link}>{text}</a>
```

The component makes use of the `page` store to get information about the current URL. It uses [effect](https://svelte.dev/docs/svelte/$effect) to update the component whenever the `page` changes. This way, the link will always point to the current page in the alternative language.

## Translating

The last step in our journey is the actual translations. For this we're going to use [sveltekit-i18n](https://github.com/sveltekit-i18n/base).

We'll start by creating a configuration file:

```ts
import i18n from '@sveltekit-i18n/base';
import parser from '@sveltekit-i18n/parser-default';

const config = {
  parser: parser(),
  loaders: [
    {
      locale: 'en',
      key: 'common',
      loader: async () => (await import('$lib/translations/en/common.json')).default
    },
    {
      locale: 'es',
      key: 'common',
      loader: async () => (await import('$lib/translations/es/common.json')).default
    },
  ]
};

export const { t, locale, loadTranslations } = new i18n(config);
```

The most important part to understand here, are the `loaders`. For our example, we have two loaders, the first one specifies where the English translations (`en`) for the `common` namespace can be found. The other one does the same for the Spanish (`es`) language.

We can proceed to create the translation files.

English:

```json
{
  "dashboard_body": "Have fun!",
  "dashboard_link": "Dashboard",
  "dashboard_title": "Welcome to the dashboard",
  "homepage_body": "How are you doing?",
  "homepage_link": "Homepage",
  "homepage_title": "Welcome to the homepage"
}
```

Spanish:

```json
{
  "dashboard_body": "Divertete!",
  "dashboard_link": "Panel de control",
  "dashboard_title": "Bienvenido al panel de control!",
  "homepage_body": "Como estas?",
  "homepage_link": "Página principal",
  "homepage_title": "Bienvenido a la página principal!"
}
```

Finally, we can use the translations in our page like this:

```html
<script lang="ts">
  import { page } from '$app/stores';

  import LocalePicker from '$lib/components/LocalePicker.svelte';
  import { t, locale, loadTranslations } from '$lib/utils/Translations';

  let lang = $state($page.params.lang);
  locale.set($page.params.lang);
  $effect(() => {
    lang = $page.params.lang;
    locale.set(lang);
    loadTranslations(lang, 'common');
  });
</script>

<LocalePicker />
<h1>{$t('common.homepage_title')}</h1>
<p>{$t('common.homepage_body')}</p>
<a href={`/${$page.params.lang}/dashboard`}>{$t('common.dashboard_link')}</a>
```

Notice how we call `locale.set` every time the language changes. We also use `loadTranslations` to load the translations file needed for the current page. If we needed more translations files, we would load them the same way.

Then we use the `$t` function to load the translation string, starting with the file prefix.

## Conclusion

At the time of this writing, the documentation for `sveltekit-i18n` is not great, so I stumbled into problems loading the translation files. Now that it's all set up, adding new translations is straightforward.

As usual, you can find a full working example in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/internationalization-of-svelte-apps).
