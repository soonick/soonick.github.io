---
id: 3151
title: UI components library with React and Radium
date: 2015-09-09T18:38:19+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3151
permalink: /2015/09/ui-components-library-with-react-and-radium/
categories:
  - Javascript
tags:
  - css
  - javascript
  - programming
  - react
---
Creating a UI component library is a common practice nowadays. There are many good examples out there, being [bootstrap](http://getbootstrap.com/) and [foundation](http://foundation.zurb.com/) some of the most popular as of this writing. Although those are good options for prototyping, there are some reasons while they might not work for big companies.

**They need customization to match your company image**; If you want to use them for your company you might end up tweaking it so much that it no longer look like the original library.

**They are bloated**; They are made to meet multiple needs so they include many components that you might not need. Even when you can create your custom build, the components themselves are made for flexibility so they will most likely include stuff you don&#8217;t need too.

**They are not components**; These libraries call themselves UI frameworks, so they are not really component libraries. They usually provide a plethora of useful classes that you can incorporate into your HTML, but there is no really way to say &#8220;I want this thing in my page&#8221;. You have to do it yourself. Some components they offer also need JavaScript, which means that to use the framework you need to include the CSS and JS and then add the correct classes to your HTML. In a lot of scenarios this is acceptable, but probably hard to scale.

<!--more-->

## A solution

I think the solution to all these problems is [web components](http://ncona.com/2015/04/web-components/). The problem, as it is usually on the web is that we can&#8217;t use it yet. In the meantime there are some options that give us similar functionality that we can use today.

React; A library for building user interfaces allows us to create &#8220;components&#8221; that we can use as building blocks of a page. The only problem is that the styling part is still not well defined.

Radium; Radium builds on top of react styling standards to provide styling inside of React components.

## Radium

Radium extends [React&#8217;s inline styling capabilities](https://facebook.github.io/react/tips/inline-styles.html) and provides solutions to some already know problems with this approach. They both use inline styles which removes some of the problems of CSS(Cascading and global state). Radium goes a little further by extending inline styles and giving users a way to use media queries and provides some help for dealing with selectors like :hover or :focus.

This gives us the functionality that we need but at the cost of performance. Since all elements have the styles inside of them the DOM tree becomes bigger. The creators of Radium have mentioned that they haven&#8217;t seen any significant differences in practice, but this might be something you want to keep in mind.

## Using Radium

Radium is pretty simple to use. Lets look at a simple example:

```js
import radium from 'radium';
import React from 'react';

const styles = {
  button: {
    color: '#fff',
    fontSize: '14px',
    height: '35px',
    backgroundColor: '#f00',
    borderBottom: '1px solid #0f0'
  },
  'button-disabled': {
    backgroundColor: '#ccc',
    borderBottom: '2px solid #666'
  }
}

// Usage:
// <MyButton>Click me</MyButton>
const MyButton = React.createClass({
  render: function() {
    return (
      <button style={[styles.button,
          this.props.disabled && styles['button-disabled']
          ]}>
        {this.props.children}
      </button>
    );
  }
});

export default radium(MyButton);
```

As you can see, styles are written as an object and using the JS property name instead of the CSS form(backgroundColor instead of background-color). You use the styles by adding them in your component as a style attribute. Another thing you may have noticed is that we check the disabled property for the component and if it is true, we also add the button-disabled styles. These styles will be merged with the button styles if they are present. Finally, you need to extend the component using the radium function.

Lets look at a little more complex example:

```js
import radium from 'radium';
import React from 'react';
import MyButton from './MyButton';

const styles = {
  container: {
    display: 'flex',
    width: '100%'
  },
  img: {
    height: '200px',
    width: '300px',
    flexShrink: 0,
    alignSelf: 'center'
  },
  myButton: {
    flexShrink: 0,
    alignSelf: 'center'
  },
  description: {
    flexGrow: 1,
    margin: '5px'
  },
  title: {
    margin: 0,
    padding: '0 0 10px 0',
    color: '#0ba'
  }
}

// Usage:
// <MyDetail>
//   <name>Something</name>
//   <img src="something.jpg">
//   <description>It is cool</description>
// </MyDetail>
const MyDetail = React.createClass({
  render: function() {
    let name;
    let img;
    let description;
    this.props.children.forEach(function(el) {
      switch (el.type) {
        case 'name':
          name = el;
          break;
        case 'img':
          img = React.cloneElement(el, {style: styles.img});
          break;
        case 'description':
          description = el;
      }
    });
    return (
      <div style={styles.container}>
        {img}
        <div style={styles.description}>
          <h2 style={styles.title}>{name}</h2>
          <p>{description}</p>
        </div>
        <div style={styles.myButton}>
          <MyButton>Money</MyButton>
        </div>
      </div>
    );
  }
});

export default radium(MyClinic);
```

Radium doesn&#8217;t get much complex, most of the complexity here is handled by React. Something to notice is the use this.props.children to get the parts of the component we are interested in and then add them to our template. You can also see that components can be nested easily. One caveat I found about this is that I had to wrap MyButton on a div so I could style it the way I wanted:

```html
<div style={styles.myButton}>
  <MyButton>Money</MyButton>
</div>
```

Applying the styles directly to MyButton doesn&#8217;t work. Styles are not passed down. I&#8217;m still not sure if this is good or bad. In this scenario it would have been easier for me to style MyButton directly, but maybe that would just be adding cascading all over again. In any case, if you needed that functionality it probably wouldn&#8217;t be very hard to implement.

When you build a page using this style of components, you can use one of React&#8217;s build tools to create bundles for your pages. The cool thing is that since HTML, CSS and JS are all in the same place and the dependency on them is declared in one place, you will end up loading only the things you need.
