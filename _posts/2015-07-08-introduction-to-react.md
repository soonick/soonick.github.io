---
id: 2999
title: Introduction to React
date: 2015-07-08T18:20:46+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2999
permalink: /2015/07/introduction-to-react/
tags:
  - javascript
  - programming
  - react
---
I&#8217;m again starting a new project with tools I am not familiar with, and it is exciting. This time I get to play with React. I&#8217;ve been wanting to play with React for a while but I got distracted by other technologies. I played a little with Polymer and I liked it so far. I&#8217;ve been using Angular for a while and it really annoys me that it is really difficult to componetize. I have heard a lot of good things about react, so I really want to put it to the test.

## What is React?

React is more similar to Polymer than to Angular. React Helps create UI components that are easy to reuse. It doesn&#8217;t provide a Router, Model or Controller, so you have to take care of those aspects yourself.

<!--more-->

## JSX

JSX is an extension to JavaScript that allows XML-like syntax. Facebook created this extension to make it easier for developers to create React components by interpolating JS and HTML in the same file. JSX is not understood by browsers, but is intended to be transpiled and converted to JavaScript before sending it to the browser.

This is how JSX looks like:

```js
var html =
  <ul>
    <li>One</li>
    <li>Two</li>
   </ul>;

console.log(html);
```

If you had to write the same with plain JavaScript, it would be a little more work:

```js
var html =
  '<ul>' +
    '<li>One</li>' +
    '<li>Two</li>' +
   '</ul>';

console.log(html);
```

Event though JSX is optional(You could use react without JSX), you will find most examples written with JSX, so it will probably be easier to embrace it since the begining.

## Using JSX

Since We are going to be using JXS, which the browser doesn&#8217;t understand, we need a way to transpile the code we write. There is a script that you can add to your HTML file that will teach your browser JSX, but it causes overhead and it&#8217;s slow. A better approach is to write code using JSX and then compile it to plain JavaScript. The tool for this job is available in the npm package react-tools:

```
npm install -g react-tools
```

Now you can have jsx watch for changes in your src directory and automatically compile files:

```
jsx --watch src/ build/
```

## Rendering a simple component

React has an interesting way for creating and rendering components. First you create a class with a render function. Then you assign it to a global variable named like the tag for your component. Finally, you tell React where you want to render your component:

```html
// Notice that this is a global variable. This is a little
// scary, but this is how it works. The name of this variable
// is important, because that is the identifier for this
// component. Every time react finds a tag called FancyButton
// inside JSX, it will try to find window.FancyButton
var FancyButton = React.createClass({
  render: function() {
    return (
      <button className="fancy-button">Fancy</button>
    );
  }
});

// Find #fancy-button and render a FancyButton inside of it
React.render(
  <FancyButton />,
  document.getElementById('fancy-button')
);
```

If you look closely, you will notice that the button we are rendering has a property called className. This is what the JSX documentation says about it:

> Since JSX is JavaScript, identifiers such as class and for are discouraged as XML attribute names. Instead, React DOM components expect DOM property names like className and htmlFor, respectively.

This file uses JSX, so you will have to compile it to JavaScript using the react jsx tool. After compiling it, you can use it in your browser:

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
  <head>
  </head>
  <body>
    <div id="fancy-button"></div>
    <script src="https://fb.me/react-0.13.3.js"></script>
    <script src="build/fancy-button.js"></script>
  </body>
</html>
```

## Passing properties to components

Components are not very useful if the user can&#8217;t configure them. In our previous example we created a button with a predefined text. Lets see how we can have the user change the caption of the button:

```js
var FancyButton = React.createClass({
  render: function() {
    return (
      <button className="fancy-button">{this.props.children}</button>
    );
  }
});

React.render(
  <FancyButton>Custom text</FancyButton>,
  document.getElementById('fancy-button')
);
```

This time we use {this.props.children} in our render function. Te curly braces inside the body of an element or as an attribute, tell JSX to interpret what is inside of the braces. The value for this.props.children will be whatever is inside the element that is being created. In this example, the text &#8220;Custom text&#8221;.

We can also access attributes of our component and react to them:

```js
var FancyButton = React.createClass({
  render: function() {
    var fancyClass = 'fancy-button';
    if (this.props.type === 'awesome') {
      fancyClass = 'awesome-button';
    }
    return (
      <button className={fancyClass}>{this.props.children}</button>
    );
  }
});

React.render(
  <FancyButton type="awesome">Custom text</FancyButton>,
  document.getElementById('fancy-button')
);
```

This time, I pass a type to FancyButton. If the type is &#8220;awesome&#8221;, we change the class applied to the resulting button. Something to notice here is that we need to write className={type} and not className=&#8221;{type}&#8221;. If you wrap the attribute in quotes, it will be interpreted as a string and won&#8217;t be parsed.

## Working with collections

It is common to have a component that will display multiple instances of another component. For example, lets say that we have a component called Ad, and we have a an AdList. The way we would make this work is by passing AdList an array of Ads, as data. It is easier to explain with some code:

```js
var Ad = React.createClass({
  render: function() {
    return (
      <div>{this.props.children}</div>
    );
  }
});

var AdList = React.createClass({
  render: function() {
    var ads = this.props.data.map(function(ad) {
      return (
        // I'm wrapping the Ad in a li because I'm going to insert it in a ul
        // React will complain if you don't add the key attribute. It uses
        // it to know what parts of the DOM to render when the model changes
        <li key={ad.key}><Ad>{ad.text}</Ad></li>
      );
    });
    return (
      <ul>
        {ads}
      </ul>
    );
  }
});

var adsData = [
  {text: 'Buy me', key: 1},
  {text: 'Rent me', key: 2}
];
React.render(
  <AdList data={adsData} />,
  document.getElementById('content')
);
```

## Changing state

The state of the component, dictates how it is going to be rendered. A component in a specific state should always result the same rendered result. You can set the initial state of your component from properties passed to it or hardcode it in the component. Here is how the two approaches would look:

```js
var MyButton = React.createClass({
  getInitialState: function() {
    return {
      enabled: false
    };
  },

  render: function() {
    return (
      <button className={!this.state.enabled ? 'disabled' : ''}>
          Superman</button>
    )
  }
});

var OtherButton = React.createClass({
  getInitialState: function() {
    return {
      enabled: this.props.flying && this.props.flying !== 'false'
    };
  },

  render: function() {
    return (
      <button className={!this.state.enabled ? 'disabled' : ''}>
          Superman</button>
    )
  }
});

// Render a disabled button
React.render(
  <MyButton />,
  document.getElementById('content')
);

// Render a disabled button
React.render(
  <OtherButton flying="false" />,
  document.getElementById('content')
);
```

This sets the initial state, but as the user interacts with your application, you will need the state to change. Doing this is easy by using setState:

```js
var OtherButton = React.createClass({
  getInitialState: function() {
    return {
      enabled: this.props.flying && this.props.flying !== 'false'
    };
  },

  componentDidMount: function() {
    setTimeout(function() {
      this.setState({enabled: true});
    }.bind(this), 5000);
  },

  render: function() {
    return (
      <button className={!this.state.enabled ? 'disabled' : ''}>
          Superman</button>
    )
  }
});

React.render(
  <OtherButton flying="false" />,
  document.getElementById('content')
);
```

In the example above, we change the state after 5 seconds. More common scenarios could be, changing the state when the user interacts with the component or when you get data from your server.

## Interacting with components

You will soon get to a point where you want your users to be able to interact with your component. The parts I consider important are getting events from the user and giving information to the user(in the form of callbacks). Lets build an simple accordion to demonstrate both scenarios. First, we are going to react to the user clicking on the titles of the accordion. Then, after the accordion has transitioned we will notify the user via a callback:

```js
var Accordion = React.createClass({
  componentDidMount: function() {
    var node = this.getDOMNode();
    node.getElementsByClassName('accordion-body')[0].style.display = 'block';
  },

  render: function() {
    return (
      <div className="accordion">
        {this.props.children}
      </div>
    );
  }
});

var AccordionSection = React.createClass({
  render: function() {
    return (
      <div className="accordion-section">
        {this.props.children}
      </div>
    );
  }
});

var AccordionTitle = React.createClass({
  handleClick: function(e) {
    // Code to hide all accordion-body's, but this one

    // We can execute functions passed to us via props
    if (this.props.whenActive) {
      this.props.whenActive();
    }
  },

  render: function() {
    return (
      <div className="accordion-title" onClick={this.handleClick}>
        {this.props.children}
      </div>
    );
  }
});

var AccordionBody = React.createClass({
  render: function() {
    return (
      <div className="accordion-body" style={{ "{{display: 'none'" }}}}>
        {this.props.children}
      </div>
    );
  }
});

React.render(
  <Accordion>
    <AccordionSection>
      <AccordionTitle>Title1</AccordionTitle>
      <AccordionBody>Body number 1</AccordionBody>
    </AccordionSection>
    <AccordionSection>
      <AccordionTitle whenActive={function() {alert('Number 2 active')}}>Title2</AccordionTitle>
      <AccordionBody>Body number 2</AccordionBody>
    </AccordionSection>
    <AccordionSection>
      <AccordionTitle>Title3</AccordionTitle>
      <AccordionBody>Body number 3</AccordionBody>
    </AccordionSection>
  </Accordion>,
  document.getElementById('content')
);
```

## XSS protection

One thing that I really like about React is that it makes it difficult to add XSS vulnerabilities to your app. By default it will escape all output:

```js
var Xss = React.createClass({
  render: function() {
    var a = '<img src="abc" onError="alert(3)" />';

    return <div>{a}</div>
  }
});
```

If you render this component you will see the value of variable a in the screen, as is. React automatically takes care of escaping it.

If for some reason you don&#8217;t want React to escape the output(because the server escapes it or because you trust the source, you can do it with a syntax that reminds you of the dangers of doing that:

```js
var Xss = React.createClass({
  render: function() {
    var a = {
      __html: '<img src="abc" onError="alert(3)" />'
    }

    return <div dangerouslySetInnerHTML={a}></div>
  }
});
```

In this scenario, the browser will try to render the image, but since it doesn&#8217;t exist it will execute the onError, and show an alert. There are two things to notice. First, we use dangerouslySetInnerHTML instead of just adding variable inside braces. Secondly, we modified a, so now it is an object with a key __html. dangerouslySetInnerHTML expects an object in this format. This makes may seem difficult, but it is all to remind you of the dangers of using this functionality.
