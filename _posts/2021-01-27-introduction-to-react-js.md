---
title: Introduction to React JS
author: adrian.ancona
layout: post
date: 2021-01-27
permalink: /2021/01/introduction-to-react-js
tags:
  - javascript
  - programming
  - react
---

React is without a doubt the most popular web component framework today. With the power of facebook backing it up, it has a lot of support and documentation behind it.

React by itself is not great for building web applications, but can be used with other tools or frameworks to build pretty much anything.

## Environment set-up

Before we can start writing React components we need a web page where we want to use them. We'll create a new folder for our project:

```sh
mkdir react
touch index.html
```

<!--more-->

And build the skeleton for our app in `index.html`:

```html
<html>
<head>
  <script src="https://unpkg.com/react@17/umd/react.production.min.js" crossorigin></script>
  <script src="https://unpkg.com/react-dom@17/umd/react-dom.production.min.js" crossorigin></script>
</head>
<body>
</body>
</html>
```

The most important thing to notice in the snippet above are the script tags:

```html
<script src="https://unpkg.com/react@17/umd/react.production.min.js" crossorigin></script>
<script src="https://unpkg.com/react-dom@17/umd/react-dom.production.min.js" crossorigin></script>
```

The first one is the React library used to create web components. The second provides helper functions that can be used to interact with the DOM.

We can now start using React. Let's create a simple web component in a file named `my-component.js`:

```js
'use strict';

class MyComponent extends React.Component {
  render() {
    return React.createElement('div', {}, 'Hello');
  }
}
```

And add it to our page:

```html
<html>
<head>
  <script src="https://unpkg.com/react@17/umd/react.production.min.js" crossorigin></script>
  <script src="https://unpkg.com/react-dom@17/umd/react-dom.production.min.js" crossorigin></script>
  <script src="my-component.js"></script>
</head>
<body>
  <div id="component-container"></div>
  <script>
    const domContainer = document.querySelector('#component-container');
    ReactDOM.render(React.createElement(MyComponent), domContainer);
  </script>
</body>
</html>
```

The things that changed:
- Included `my-component.js` on the head
- Added a div where our component will be inserted
- Added a script that will insert the component in that div

We can test our code by starting a static web server in our project folder. I usually use python for this:

```sh
python -m SimpleHTTPServer
```

And go to `http://localhost:8000`.

Before we start learning more about the different React features, it's good to get familiar with JSX.

## JSX

Most real world users of React, use it in conjunction with JSX, so it's important to get familiar with it.

JSX is an extension to JS that makes it easier for developers to write components. It allows us to combine HTML and JS in a single file.

To start using it, we need to add another script to our html page:

```html
<html>
<head>
  <!-- Not showing other scripts for brevity -->
  <script src="https://unpkg.com/babel-standalone@6/babel.min.js"></script>
</head>
<!-- Not showing body for brevity -->
```

We can now rewrite our component using JSX:

```js
'use strict';

class MyComponent extends React.Component {
  render() {
    return <div>Hello</div>
  }
}
```

Notice that `<div>Hello</div>` is not quoted. It not a string, but a JSX snippet. This will be compiled and transformed into the JS code necessary to build that snippet of HTML.

So far, it doesn't seem like a big improvement, but as we create more complex components, it quickly becomes a necessity.

## Nested components

Components can use other components to build more complex UIs. Let's start by creating a new component in a file named `user-info.js`:

```js
'use strict';

class UserInfo extends React.Component {
  render() {
    return <div>
      <strong>Name</strong>: Carlos<br />
      <strong>Age</strong>: 25<br />
    </div>
  }
}
```

We will need to add our new component to our html file:

```html
<script src="user-info.js" type="text/babel"></script>
```

Let's also modify `my-component.js`:

```js
'use strict';

class MyComponent extends React.Component {
  render() {
    return <div>
      Here is the info:
      <UserInfo />
    </div>
  }
}
```

Notice how `MyComponent` is not using `<UserInfo />`. A component can use multiple components and they can nest as deep as necessary.

## Props

Our `UserInfo` component has some hardcoded information about Carlos. It would be more useful if this information could be set by the caller. We can add attributes to the `UserInfo` tag that can be used inside the component as `props`. Let's first add the attributes:

```js
'use strict';

class MyComponent extends React.Component {
  render() {
    return <div>
      Here is the info:
      <UserInfo name="Jose" age="79" />
    </div>
  }
}
```

We added two properties to UserInfo: `name` and `age`. Let's see how we can access their values:

```js
'use strict';

class UserInfo extends React.Component {
  constructor(props) {
    super(props);
    this.name = props.name;
    this.age = props.age;
  }

  render() {
    return <div>
      <strong>Name</strong>: {this.name}<br />
      <strong>Age</strong>: {this.age}<br />
    </div>
  }
}
```

The first thing to notice is that we receive the attributes as `props` in the constructor. We then assign them to instance variables so we can access them from the `render` method:

```js
constructor(props) {
  super(props);
  this.name = props.name;
  this.age = props.age;
}
```

In the render method we use curly braces to get the value of a variable:

```js
<strong>Name</strong>: {this.name}<br />
```

## Interacting with components

Events can be attached to components as with other html elements. Let's add an event listener to `UserInfo`:

```js
'use strict';

class UserInfo extends React.Component {
  constructor(props) {
    super(props);
    this.name = props.name;
    this.age = props.age;
  }

  sayHello() {
    alert('hello');
  }

  render() {
    return <div onClick={this.sayHello}>
      <strong>Name</strong>: {this.name}<br />
      <strong>Age</strong>: {this.age}<br />
    </div>
  }
}
```

We added a click listener to our component that will call `sayHello`. The same syntax can be used to add listeners for other events.

## State

In our `UserInfo` component we use instance variables to define how it will be rendered. This works if our component state is only tied to `props`, but it breaks in other scenarios. Let's see what happens if we modify `this.name` when the component is clicked.

```js
'use strict';

class UserInfo extends React.Component {
  constructor(props) {
    super(props);
    this.name = props.name;
    this.age = props.age;
  }

  sayHello() {
    this.name = 'Carlos';
  }

  render() {
    return <div onClick={this.sayHello.bind(this)}>
      <strong>Name</strong>: {this.name}<br />
      <strong>Age</strong>: {this.age}<br />
    </div>
  }
}
```

One thing to notice is that we used bind so we can use `this` inside `sayHello`. If we click our component, we will notice that the name doesn't change.

The reason for this is that React only triggers the render method when `props` change or when the `state` changes. We can achieve the desired result by using state instead of regular variables:

```js
'use strict';

class UserInfo extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      name: props.name,
      age: props.age
    };
  }

  sayHello() {
    this.setState({
      name: 'Carlos'
    });
  }

  render() {
    return <div onClick={this.sayHello.bind(this)}>
      <strong>Name</strong>: {this.state.name}<br />
      <strong>Age</strong>: {this.state.age}<br />
    </div>
  }
}
```

The most important thing to notice here is that `sayHello` doesn't only assign the new value to `this.state.name`. Instead, it calls `this.setState`, which performs a shallow merge of the given object with `this.state` and then calls `render`.

## Conclusion

One of the challenges of learning React is the huge ecosystem around it and part of it is necessary to build maintainable and performant apps. In this article we learned only the basics, that have stayed the same regardless of how the ecosystem changes.

One important disclaimer is that using React in the way I used it in this article is a very bad practice. In a production scenario JSX compilation should be part of a build step that is performed before the components are sent to the user. There are also tools that help minify and bundle components so it's faster to send them over the internet.
