---
id: 464
title: Using AJAX with Zend Framework
date: 2011-11-24T02:42:10+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=464
permalink: /2011/11/using-ajax-with-zend-framework/
tags:
  - php
  - zend_framework
---
When I first read something like &#8220;AJAX and Zend Framework&#8221; I thought it didn&#8217;t make any sense. If AJAX is an HTTP request made by JavaScript then Zend Framework shouldn&#8217;t care how the request arrived.

This is kind of true; except when we are using layouts in our views. When we use layouts we don&#8217;t just deliver the content of the current action, but also other components that are common among all pages. This is a problem when we want to make an AJAX request that returns a JSON because it would return other pieces of code that would make very difficult to parse the response.

We could create a layout that is specific for AJAX requests that only prints the content of the current action, and that would work correctly. But there is another option that helps us easily switch from different types of replies with little configuration.

<!--more-->

## Context switching

Context switching is an action helper that allows us to easily change the format of one response. This way we could have one action that can return it&#8217;s response as JSON, XML or HTML with little configuration.

The contextSwitch action helper does some specific tasks to make this process easy:

  * Disable layouts, if enabled. 
  * Set an alternate view suffix, effectively requiring a separate view script for the context. 
  * Send appropriate response headers for the context desired. 
  * Optionally, call specified callbacks to setup the context and/or perform post-processing. 

## Example

Probably the best way to understand how this works is with an example, so that is what we are going to do. We are going to start with one controller and one action, lets say we are going to visit this url: http://example.dev/controller1/action1. So the controller would be controller1 and the action would be action1. Out controller class would be Controller1Controller.php and would look something like this:

```php
<?php

class Controller1Controller extends Zend_Controller_Action
{
    public function action1Action()
    {
        $this->view->assign('title', 'This is the title');
    }
}
```

Now lets create a view script for this action. It would be action1.phtml in our views/scripts/controller1/ folder:

```html
<h1><?php echo $this->escape($this->title); ?></h1>
```

This should work correctly and show us the title between h1 tags.

Now we are going to make this same action return content in different formats by changing the context. First we are going to modify our controller:

```php
<?php

class Controller1Controller extends Zend_Controller_Action
{
    public function init()
    {
        // Get the context switcher helper
        $contextSwitch = $this->_helper->getHelper('contextSwitch');
        // We want to have a json and an xml context available for action1
        $contextSwitch->addActionContext('action1', array ('xml', 'json'))
                ->initContext();
    }

    public function action1Action()
    {
        $this->view->assign('title', 'This is the action');
    }
}
```

Now, without moving anything else in the controller we can create one view file for each context we added for the action.

views/scripts/controller1/action1.json.phtml:

```php
<?php
    echo get_object_vars($this);
?>
```

views/scripts/controller1/action1.xml.phtml:

```php
<?php echo '<?xml version="1.0" encoding="UTF-8" ?>'; ?>
<vars>
    <title><?php echo $this->escape($this->title); ?></title>
</vars>
```

At this point we have everything ready to serve three versions of the same action. To get the default version we would go to: http://example.dev/controller1/action1, to get the JSON version: http://example.dev/controller1/action1/format/json and for the XML version: http://example.dev/controller1/action1/format/xml.
