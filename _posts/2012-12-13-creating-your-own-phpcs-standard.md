---
id: 947
title: Creating your own PHPCS standard
date: 2012-12-13T03:23:24+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=947
permalink: /2012/12/creating-your-own-phpcs-standard/
tags:
  - automation
  - css
  - php
  - programming
  - testing
---
PHPCS is a great tool to help you make sure the correct coding style is being followed within a project. The problem is that some times the build in standards don&#8217;t cover all your needs so it is necessary to build custom rules. I will walk through the process I followed to create my own coding standard based on the build-in Zend standard.

## Creating your work environment

In Ubuntu all PHPCS standards are stored in /usr/share/php/PHP/CodeSniffer/Standards/. There is a folder for each standard named after the standard name. I will call my standard Soonick, so I will create a folder with that name.

<!--more-->

```
cd /usr/share/php/PHP/CodeSniffer/Standards/
sudo mkdir Soonick
sudo chmod 777 Soonick
```

Now we can start working.

## Extending a standard

Create a ruleset.xml file inside your standard folder. I want my standard to extend the Zend standard so to get started I will do just that.

```xml
<?xml version="1.0"?>
<ruleset name="Soonick">
    <description>Coding standard based on Zend with some additions.</description>

     <!-- Include the whole Zend standard -->
    <rule ref="Zend"/>
</ruleset>
```

Once you have your ruleset.xml file in place, the standard you created will be recognized by phpcs:

```
phpcs -i
The installed coding standards are PSR2, MySource, PSR1, Squiz, PHPCS, Zend, PEAR and Soonick
```

And you can use it as any other standard:

```
phpcs --standard=Soonick /file/or/folder
```

Currently it will show the exact same warnings as the Zend standard would.

## Adding specific rules from other standards

There are rules that already exist in other standards that I would like to include in my custom standard. Doing so is also very easy:

```xml
<?xml version="1.0"?>
<ruleset name="Soonick">
    <description>Coding standard based on Zend with some additions.</description>

     <!-- Include the whole Zend standard -->
    <rule ref="Zend"/>

    <!-- Include some CSS rules I want to enforce -->
    <rule ref='Squiz.CSS.ClassDefinitionClosingBraceSpace'/>
    <rule ref='Squiz.CSS.ClassDefinitionNameSpacing'/>
    <rule ref='Squiz.CSS.ClassDefinitionOpeningBraceSpace'/>
    <rule ref='Squiz.CSS.ColonSpacing'/>
    <rule ref='Squiz.CSS.ColourDefinition'/>
    <rule ref='Squiz.CSS.DuplicateStyleDefinition'/>
    <rule ref='Squiz.CSS.EmptyClassDefinition'/>
    <rule ref='Squiz.CSS.Indentation'/>
    <rule ref='Squiz.CSS.SemicolonSpacing'/>
</ruleset>
```

## Creating custom sniffs

The sniffs that come packaged with PHPCS cover most of the common scenarios and currently cover all my requirements. Anyway I will create an example sniff just for the sake of understanding how they work.

All the the sniffs we create for our custom standard must be inside a folder named **Sniffs** inside our standard folder (/usr/share/php/PHP/CodeSniffer/Standards/Soonick). It is also standard to create folders to categorize our sniffs. I just call this folder **Examples** for now.

Since I don&#8217;t currently have a specific need to implement I will just create a very silly example. It will check if a variable with the name $badVariable exists and if it does it will fail.

The name of our sniff should be descriptive and end with Sniff.php, so we will call it NoBadVariablesSniff.php. All ours sniffs should also implement PHP\_CodeSniffer\_Sniff which has two abstract methods register() and process() that must be defined by us.

For the creation of sniffs PHPCS divides the code in tokens that your code can process. The **register** method will tell PHPCS which tokens your custom sniff is interested on. You can see a list of the available tokens at /usr/share/php/PHP/CodeSniffer/Tokens.php.

The **process** method receives two arguments automatically: The file being parsed and the position where the token was found in the stack. Lets see how everything looks together:

```php
<?php
class Soonick_Sniffs_Examples_NoBadVariablesSniff implements PHP_CodeSniffer_Sniff
{
    /**
     * Returns the token types that this sniff is interested in.
     *
     * @return array(int)
     */
    public function register()
    {
        return array(T_VARIABLE);
    }

    /**
     * Processes the tokens that this sniff is interested in.
     *
     * @param PHP_CodeSniffer_File $phpcsFile The file where the token was found
     * @param int $stackPtr The position in the stack where the token was found
     */
    public function process(PHP_CodeSniffer_File $phpcsFile, $stackPtr)
    {
        $tokens = $phpcsFile->getTokens();
        if ('$badVariable' === $tokens[$stackPtr]['content']) {
            $phpcsFile->addError(
                'No bad variables. Found ' . $tokens[$stackPtr]['content'],
                $stackPtr
            );
        }
    }
}
```

If a file with the name $badVariable is found on a sniffed file, an error will be thrown.
