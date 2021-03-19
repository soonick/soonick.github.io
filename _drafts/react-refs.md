---
title: React refs
author: adrian.ancona
layout: post
date: 2021-03-24
permalink: /2021/03/react-refs
tags:
  - javascript
  - programming
  - react
---

React was designed with the mentality that parent components interact with their children by sending them props. This works in most scenarios, but not all.

Changing a prop in a child component will make it render in a different way, but it doesn't allow us to tell the component to do something (trigger an event in a component). If we want to trigger an event in a component, we need to get a reference to it. Unfortunately, it's not always easy to do this.

## ref

The React documentation warns against the use of refs and suggests the use of props instead:

> For example, instead of exposing open() and close() methods on a Dialog component, pass an isOpen prop to it.

<!--more-->

But this doesn't really make sense in a lot of cases. If we want to have a toggle button, we want the button to hold its state and not have the parent worry about it.

We use `createRef` to create a reference variable. We can then attach this reference to a DOM element or React component.

Let's look at we can create a reference to an input field to get its value:

```js
class MyComponent extends React.Component {
  constructor(props) {
    super(props);

    this.fieldRef = React.createRef();
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    alert(this.fieldRef.current.value);
  }

  render() {
    return <div>
      <input ref={this.fieldRef} />
      <button onClick={this.handleClick}>Click me</button>
    </div>
  }
}
```

We can see in the example above that the reference has a `current` attribute that points to the element it references. From there we can get the textarea value, or do anything we want.

In the previous example our reference points to a DOM element, but we can also get references to React components.

```js
class MyComponent extends React.Component {
  constructor(props) {
    super(props);

    this.childRef = React.createRef();
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.childRef.current.sayHello();
  }

  render() {
    return <div>
      <ChildComponent ref={this.childRef} />
      <button onClick={this.handleClick}>Click me</button>
    </div>
  }
}

class ChildComponent extends React.Component {
  sayHello() {
    alert('Hello');
  }

  render() {
    return <div>I say hello</div>
  }
}
```

## Forwarding refs

There are two ways to create components with React: Classes and functions. The `ref` method described above doesn't work with function components because they don't create an instance of themselves.

If we are consuming a library that exposes components that were created using functions, we are out of luck. It's not possible to get a `ref` to them.

If we are creating components using functions, the best we can do is give our users the oportunity to reference a child element (A class component or a DOM element). For this, we need ref forwarding.

```js
const MyInput = React.forwardRef((props, ref) => (
  <div>
    <input ref={ref} />
  </div>
));

class MyComponent extends React.Component {
  constructor(props) {
    super(props);

    this.fieldRef = React.createRef();
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    alert(this.fieldRef.current.value);
  }

  render() {
    return <div>
      <MyInput ref={this.fieldRef} />
      <button onClick={this.handleClick}>Click me</button>
    </div>
  }
}
```

In the example above, `MyInput` is a function component that we created. We wrapped it with `React.forwardRef` to give users the ability to get a reference to a specific DOM element. After doing that, we can attach the reference as normal.

## Conclusion

I'm very surprised how hard it is to get a reference to a child in React. Since React has been moving lately in the direction of function components, we might be forced to use `forwardRef` more often.
