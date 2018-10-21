---
id: 3367
title: Testing Polymer components using Web Component Tester
date: 2015-12-24T01:07:55+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3367
permalink: /2015/12/testing-polymer-components-using-web-component-tester/
tags:
  - javascript
  - polymer
  - programming
  - testing
---
I have started writing some real life polymer components, and I feel really bad that I haven&#8217;t been writing tests for them. In this post I&#8217;m going to teach myself how to write and run tests for polymer components so I can stop being a slacker and do some proper TDD.

Lets start by creating a little project. You can leave the defaults for the questions asked by npm init:

```
mkdir ~/test
cd ~/test
npm init
```

Now, lets setup bower. You can again, leave the defaults:

```
npm install --save-dev bower
./node_modules/bower/bin/bower init
```

<!--more-->

Download polymer:

```
./node_modules/bower/bin/bower install --save polymer
```

I&#8217;m going to use the component I wrote in my [introduction to Polymer](http://ncona.com/2015/06/introduction-to-polymer/) as the component under test. I&#8217;m going to strip the styles just to make it smaller. Create a file called ncona-accordion.html and add this content:

```html
<link rel="import" href="bower_components/polymer/polymer.html">

<dom-module id="ncona-accordion">
  <template><content></content></template>
</dom-module>

<script>
  Polymer({
    is: 'ncona-accordion',
    properties: {
      nconaAllowAllClosed: Boolean
    },
    listeners: {
      click: 'handleClick'
    },
    handleClick: function(e) {
      if (e.target.tagName !== 'NCONA-TITLE') {
        return;
      }

      var elementStatus = e.target.parentNode.getAttribute('ncona-selected');

      var elements = this.querySelectorAll('ncona-element');
      for (var i = 0; i < elements.length; i++) {
      elements[i].removeAttribute('ncona-selected');
    }

    if (!this.nconaAllowAllClosed || elementStatus === null) {
      e.target.parentNode.setAttribute('ncona-selected', 'ncona-selected');
    }
  }
});
</script>
```

What I expect from this component, first is to set the ncona-selected attribute to the accordion item I click, and to unset it in all other items. But before we can write the tests, we have to do a little setup.

```
npm install --save-dev web-component-tester
```

Then create a config file called wct.conf.json:

```json
{
  "suites": ["test/"],
  "plugins": {
    "local": {
      "browsers": ["chrome"]
    }
  }
}
```

In this config file we are specifying that we want our tests to run in Chrome. You can change this to the browsers you want to test. PhantomJS is not supported at the moment. We also tell wct that our tests will live in the test/ folder. Lets create our test:

```
mkdir test
touch test/ncona-accordion-test.html
```

Lets create a dummy test just to verify that the setup went fine:

```html
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="../bower_components/webcomponentsjs/webcomponents.min.js"></script>
  <script src="../bower_components/web-component-tester/browser.js"></script>
  <link rel="import" href="../ncona-accordion.html">
</head>
<body>
  <script>
    suite('<ncona-accordion>', function() {
      test('dummy test', function() {
        assert.isTrue(false);
      });
    });
  </script>
</body>
</html>
```

To run the tests, just run:

```
./node_modules/web-component-tester/bin/wct
```

The test should run fine, but it will end with a failure. This is fine, we&#8217;ll write the correct test in a second. Before that, I actually like to have my JS files separated from my HTML so they are easier to lint and syntax highlighters have an easier time. Just create a new file called ncona-accordion-test.js and move the JS there:

```js
suite('<ncona-accordion>', function() {
  test('dummy test', function() {
    assert.isTrue(false);
  });
});
```

And change the HTML to reference this file:

```html
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="../bower_components/webcomponentsjs/webcomponents.min.js"></script>
  <script src="../bower_components/web-component-tester/browser.js"></script>
  <link rel="import" href="../ncona-accordion.html">
</head>
<body>
  <script src="ncona-accordion-test.js"></script>
</body>
</html>
```

You will also need to change your wct.config.json so it only runs html files as tests:

```json
{
  "suites": ["test/**/*.html"],
  "plugins": {
    "local": {
      "browsers": ["chrome"]
    }
  }
}
```

Tests will run exactly the same way.

It&#8217;s time to write the real test now. Lets start by putting our component in the page so we can test it:

```html
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="../bower_components/webcomponentsjs/webcomponents.min.js"></script>
  <script src="../bower_components/web-component-tester/browser.js"></script>
  <link rel="import" href="../ncona-accordion.html">
</head>
<body>
  <ncona-accordion id="accordion">
    <ncona-element>
      <ncona-title>Something</ncona-title>
      <ncona-content>Some content</ncona-content>
    </ncona-element>
    <ncona-element ncona-selected>
      <ncona-title>Something</ncona-title>
      <ncona-content>Some content</ncona-content>
    </ncona-element>
  </ncona-accordion>

  <script src="ncona-accordion-test.js"></script>
</body>
</html>
```

And now the JS:

```js
suite('<ncona-accordion>', function() {
  test('clicking title selects it', function() {
    var accordion = document.getElementById('accordion');
    var title = accordion.getElementsByTagName('ncona-title')[0];

    title.click();

    var attributeValue  = title.parentNode.getAttribute('ncona-selected');
    assert.equal(attributeValue, 'ncona-selected');
  });
});
```

Now we have a real test that passes, but there is a problem with it. It doesn&#8217;t clean after itself. We can verify that this is true by writing another test:

```js
suite('<ncona-accordion>', function() {
  test('clicking title selects it', function() {
    var accordion = document.getElementById('accordion');
    var title = accordion.getElementsByTagName('ncona-title')[0];

    title.click();

    var attributeValue  = title.parentNode.getAttribute('ncona-selected');

    assert.equal(attributeValue, 'ncona-selected');
  });

  test('initially selected', function() {
    var accordion = document.getElementById('accordion');
    var title = accordion.getElementsByTagName('ncona-title')[1];

    var attributeValue  = title.parentNode.getAttribute('ncona-selected');
    assert.isNotNull(attributeValue, 'ncona-selected');
  });
});
```

This test will fail, because the first test is ran first. To avoid this problem we can use fixtures. We need to first modify our HTML a little:

```html
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="../bower_components/webcomponentsjs/webcomponents.min.js"></script>
  <script src="../bower_components/web-component-tester/browser.js"></script>
  <link rel="import" href="../ncona-accordion.html">
</head>
<body>
  <test-fixture id="fixture">
    <template>
      <ncona-accordion id="accordion">
        <ncona-element>
          <ncona-title>Something</ncona-title>
          <ncona-content>Some content</ncona-content>
        </ncona-element>
        <ncona-element ncona-selected>
          <ncona-title>Something</ncona-title>
          <ncona-content>Some content</ncona-content>
        </ncona-element>
      </ncona-accordion>
    </template>
  <test-fixture>

  <script src="ncona-accordion-test.js"></script>
</body>
</html>
```

And also our JS tests:

```js
suite('<ncona-accordion>', function() {
  setup(function() {
    document.getElementById('fixture').create();
  });

  test('clicking title selects it', function() {
    var accordion = document.getElementById('accordion');
    var title = accordion.getElementsByTagName('ncona-title')[0];

    title.click();

    var attributeValue  = title.parentNode.getAttribute('ncona-selected');

    assert.equal(attributeValue, 'ncona-selected');
  });

  test('initially selected', function() {
    var accordion = document.getElementById('accordion');
    var title = accordion.getElementsByTagName('ncona-title')[1];

    var attributeValue  = title.parentNode.getAttribute('ncona-selected');
    assert.isNotNull(attributeValue, 'ncona-selected');
  });
});
```

I really got used to using BDD syntax for writing tests, so I&#8217;m going to change the syntax of my file a little:

```js
describe('<ncona-accordion>', function() {
  beforeEach(function() {
    document.getElementById('fixture').create();
  });

  it('selects element after clicking title', function() {
    var accordion = document.getElementById('accordion');
    var title = accordion.getElementsByTagName('ncona-title')[0];

    title.click();

    var attributeValue  = title.parentNode.getAttribute('ncona-selected');

    assert.equal(attributeValue, 'ncona-selected');
  });

  it('sets initially selected item', function() {
    var accordion = document.getElementById('accordion');
    var title = accordion.getElementsByTagName('ncona-title')[1];

    var attributeValue  = title.parentNode.getAttribute('ncona-selected');
    assert.isNotNull(attributeValue, 'ncona-selected');
  });
});
```

Now, everything is ready to do some TDD component building. One useful thing to know is that if you ever want to debug a test you are writing you can use the -p flag to keep the browser open after the execution and debug from there:

```
./node_modules/web-component-tester/bin/wct -p
```
