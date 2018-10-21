---
id: 2113
title: Using ESLint to enforce JS coding conventions
date: 2014-05-22T04:19:37+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2113
permalink: /2014/05/using-eslint-to-enforce-js-coding-conventions/
tags:
  - automation
  - javascript
  - node
  - productivity
  - programming
---
I spend a decent amount of time reviewing code at work. After a while I get tired of reminding developers that the opening brace for an if statement goes in the same line. JSLint and JSHint do a good job of preventing developers from doing things that would break your code but it doesn&#8217;t really allow you to enforce coding conventions the way I wanted.

I was looking for a way to create custom rules for JSHint so I could enforce our team conventions but after some research I found that it is not possible and it is not something we should expect from the project. It seems like Nicholas Zakas wanted the same thing as me and he didn&#8217;t find it, so he built it. That is how ESLint was born. It is a relatively new project but I gave it a try and it seems to work very well.

You can use npm to install it globally:

```
npm i -g eslint
```

<!--more-->

To run it with the default rules you can do:

```
eslint file.js
```

If you want to have a configuration for your whole project you can create a file named .eslintrc in the root of your project and that file will be used as configuration automatically.

ESLint comes with a few rules that I wanted to start enforcing but are not on as default, so this is how my .eslintrc file looks:

```json
{
  "env": {
    "browser": true
  },
  "rules": {
    "quotes": "single", // Enforce single quotes
    "strict": false, // Don't require strict mode
    // Lets you have a literal at the left of and if
    // statement: if ('something' === variable) {
    "no-yoda": false,
    // Allow console.log
    "no-console": false,

    // Enforce this style:
    // if (something) {
    // } else {
    // }
    "brace-style": [2, "1tbs"],
    // this is not allowed function (){
    "no-spaced-func": [2, true],
    // Enforce a valid jsdoc
    "valid-jsdoc": [0, true],
    // Enforce all variables being camel case
    "camelcase": [2, true],
    // Don't allow [ "hello" ]
    "space-in-brackets": [2, "never"],
    // Don't allo0w 1+1
    "space-infix-ops": [2, true],
    // There can only be one var statement inside a function
    "one-var": [0, true],
    // There has to be a space after if:
    // if () {
    "space-after-keywords": [2, "always"]
  },
  "globals": {
    // Add your globals here
    "ActiveXObject": true,
    "console": true,
  }
}
```

This is very helpful but there are some very custom rules that I wanted to enforce. To create a custom rule I had to first setup the development environment:

```
git clone git://github.com/eslint/eslint.git
cd eslint
npm install
npm remove -g eslint
npm link
```

I wanted to create a rule to disallow empty lines after opening brackets so I created a file named no-blank-lines-between-brackets.js inside lib/rules. This is the content of my rule:

```js
module.exports = function(context) {

    "use strict";

    function reportEmptyLines(node) {
        // context.getSource(node) gives me the source code for
        // the current block statement. Then I split it by lines.
        var lines = context.getSource(node).split(/\r?\n/);

        // Check if first line after opening bracket is empty
        if (lines[1] === "") {
            context.report(
                node,
                {
                    line: node.loc.start.line + 1,
                    column: 0
                },
                "Remove empty line after opening bracket"
            );
        }

        // Check if line before closing bracket is empty
        if (lines[lines.length - 2] === "") {
            context.report(
                node,
                {
                    line: node.loc.start.line + 1,
                    column: 0
                },
                "Remove empty line before closing bracket"
            );
        }
    }

    return {
        // Execute reportEmptyLines every time the
        // parser finds a block statement (functions and
        // control statement blocks)
        "BlockStatement": reportEmptyLines
    };
};
```

Now you can add the rule &#8220;no-blank-lines-between-brackets&#8221; to .eslintjs and it will report blank lines.
