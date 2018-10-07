---
id: 278
title: Run PHP unit tests automatically using git hooks
date: 2011-08-07T16:00:14+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=278
permalink: /2011/08/run-php-unit-tests-automatically-using-git-hooks/
categories:
  - PHP
tags:
  - Git
  - linux
  - php
---
## Git hooks

From git documentation:

> Hooks are little scripts you can place in $GIT_DIR/hooks directory to trigger action at certain points. When git-init is run, a handful example hooks are copied in the hooks directory of the new repository, but by default they are all disabled. To enable a hook, make it executable with chmod +x.

If you take a look at your .git/hooks folder you will probably see a bunch of hooks created by default. In my current version of git all my hooks have a **.sample** extension. To make a hook executable you must remove .sample and make it executable. If you don&#8217;t want to remove the default example you can create a new file without **.sample**.

<!--more-->

## What will our hook do

We want our hook to run all our unit tests before a commit is made. If any test fails then the commit will not be applied and the commiter will be notified about what happened.

Hooks are usually written in shell but they can be written in any language. We are going to use PHP for our hook.

## How will our hook do it

To run our hook before commiting we will use the pre-commit hook. We need to create a file and name it pre-commit in our .git/hooks folder and make it executable.

In this example it is assumed that you are using PHPUnit with a test suite file for your project.

This is going to be the content of our file:

```php
#!/usr/bin/php
<?php
// Hook configuration
$project = 'My Project';
$testSuiteFile = '/home/myself/www/project/tests/My_Project.php';

// Tell the commiter what the hook is doing
echo PHP_EOL;
echo '>> Starting unit tests'.PHP_EOL;

// Execute project unit tests
exec('phpunit '.$testSuiteFile, $output, $returnCode);

// if the build failed, output a summary and fail
if ($returnCode !== 0)
{
    // find the line with the summary; this might not be the last
    while (($minimalTestSummary = array_pop($output)) !== null)
    {
        if (strpos($minimalTestSummary, 'Tests:') !== false)
        {
            break;
        }
    }

    // output the status and abort the commit
    echo '>> Test suite for '.$project.' failed:'.PHP_EOL;
    echo $minimalTestSummary;
    echo chr(27).'[0m'.PHP_EOL; // disable colors and add a line break
    echo PHP_EOL;
    exit(1);
}

echo '>> All tests for '.$project.' passed.'.PHP_EOL;
echo PHP_EOL;
exit(0);
```

This example is strongly based on Mike&#8217;s gist on github: https://gist.github.com/975252.
