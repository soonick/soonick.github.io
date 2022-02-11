---
id: 2356
title: Project scaffolding with Yeoman
date: 2015-01-14T19:56:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2356
permalink: /2015/01/project-scaffolding-with-yeoman/
tags:
  - automation
  - javascript
  - productivity
  - programming
---
Every time I start a new project I go to old projects to review and copy my build steps and linting rules among other things. A good developer would have automated the creation of a new project instead of going back every time. I want to redeem myself so I&#8217;m taking a look a [Yeoman](http://yeoman.io "Yeoman").

Yeoman is a tool for scaffolding web apps. It basically allows you to create custom reusable app skeletons called generators.

## Install

```
npm install -g yo
```

<!--more-->

## Using a generator

There are many open source generators out there that you can use out of the box. You can try the Angular generator with these commands:

```
mkdir ~/angular-app
cd ~/angular-app
npm install -g generator-angular
yo angular
```

Then you will be asked a few questions about your project and a skeleton will be created for you.

## Creating a generator

There are many [generators already available](http://yeoman.io/generators/ "Generators available") but you might(like me) have a very specific way you like to do things, in which case you will need to create your own generator.

Lets start our generator project:

```
mkdir ~/generator-example-adrian
cd ~/generator-example-adrian
npm install -g generator-generator
yo generator
```

We just ran a generator to create our generator skeleton. Lets test it:

```
npm link
mkdir ~/some-project
cd ~/some-project
yo example-adrian
```

Since the generator we are working on is not yet available as a global npm module we had to use **npm link** to make it available for testing. Then we created a folder and ran our generator in that folder.

The generator we are going to create for this example will:

  * Create a README.md
  * Create .gitignore
  * Create Gruntfile.js
  * Add ESLint support

Lest start by creating our templates. There are some templates already in **app/templates**. Delete all but `_package.json`. We are also going to create the following templates and save them under that folder:

readme.md

```
This is just an example
```

gitignore

```
/node_modules/
```

gruntfile.js

```js
'use strict';

module.exports = function(grunt) {
  var config = {
    <%= eslint %>
  };

  grunt.initConfig(config);

  require('load-grunt-tasks')(grunt);
};
```

eslintrc

```js
{
  "env": {
    "node": true
  },
  "rules": {
    "quotes": [1, "single"],
    "brace-style": [2, "1tbs"],
    "no-spaced-func": [2, true],
    "valid-jsdoc": [0, true],
    "camelcase": [2, true],
    "space-in-brackets": [2, "never"],
    "space-infix-ops": [2, true],
    "space-after-keywords": [2, "always"]
  }
}
```

eslintGruntConfig

```js
eslint: {
  target: [
    'Gruntfile.js'
  ]
}
```

Now we need to modify our app/index.js file a little:

```js
'use strict';
var yeoman = require('yeoman-generator');
var chalk = require('chalk');
var yosay = require('yosay');

module.exports = yeoman.generators.Base.extend({
  // Say hi to the user
  greet: function() {
    this.log(yosay('Hello user'));
  },

  // Asks the user if they want to enable ESLint
  // and saves their answer for later use
  prompting: function() {
    var done = this.async();

    var prompts = [{
      type: 'confirm',
      name: 'eslint',
      message: 'Would you like to enable eslint?',
      default: true
    }];

    this.prompt(prompts, function(props) {
      this.eslint = props.eslint;

      done();
    }.bind(this));
  },

  // Generate files
  writing: {
    // Write the files that will be written
    // regardless of how the user responded
    // to our prompt
    common: function() {
      // README.md
      this.fs.copy(
        this.templatePath('readme.md'),
        this.destinationPath('README.md')
      );

      // .gitignore
      this.fs.copy(
        this.templatePath('gitignore'),
        this.destinationPath('.gitignore')
      );

      // package.json
      this.fs.copy(
        this.templatePath('_package.json'),
        this.destinationPath('package.json')
      );
    },

    // Gruntfile.js is rendered differently
    // if ESLint is enabled or not
    gruntfile: function() {
      var options = {
        eslint: ''
      };

      if (this.eslint) {
        options.eslint = this.fs.read(this.templatePath('eslintGruntConfig'));
      }

      this.fs.copyTpl(
        this.templatePath('gruntfile.js'),
        this.destinationPath('Gruntfile.js'),
        options
      );
    },

    // Write the .eslintrc file if user chose
    // to use ESLint
    eslint: function() {
      if (this.eslint) {
        this.fs.copy(
          this.templatePath('eslintrc'),
          this.destinationPath('.eslintrc')
        );
      }
    }
  },

  install: function() {
    // Only install grunt-eslint if necessary
    if (this.eslint) {
      this.npmInstall(['grunt-eslint'], {saveDev: true});
    }

    this.npmInstall(['grunt', 'load-grunt-tasks'], {saveDev: true});
  }
});
```

You can see in my example that I use a template to add the ESLint configuration to the Gruntfile. This is a **bad practice** that I only used to make this example simpler. There are [good practices for modifying gruntfiles](http://yeoman.io/authoring/gruntfile.html) available in the Yeoman documentation.

From now on, starting new projects will be a lot more efficient.
