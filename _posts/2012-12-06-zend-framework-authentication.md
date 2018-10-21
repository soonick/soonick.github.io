---
id: 794
title: Zend Framework Authentication
date: 2012-12-06T04:00:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=794
permalink: /2012/12/zend-framework-authentication/
tags:
  - authentication
  - php
  - programming
  - zend_framework
---
Authentication is the process of confirming that a person is who they say they are. In software the most common method of authentication is the use of a password that only the person knows.

## Zend_Auth

Zend framework provides Zend\_Auth as an interface to authenticate a user against different back-ends (Database, LDAP, etc&#8230;). Since all adapters that use Zend\_Auth share the same interface you can use any of them with almost no changes in the code.

Authentication is sometimes confused with authorization (the process of verifying if a person has access to a resource), and although they do different things they are related because you have to know the identity of the user before you can check if they have permission to a resource.

<!--more-->

Because it wouldn&#8217;t make sense to ask the user for a password for every requested page, there needs to be a way to persist the identity of a user. Zend_Auth uses sessions by default to let your system know who is currently logged to the system. All of this is better shown in an example.

## An example

We will use the database adapter so we will need a database to authenticate against. This is the table we will use for authentication (this is MySQL code):

```sql
CREATE TABLE `system_users` (
    `username` VARCHAR(150) NOT NULL,
    -- This is 40 characters because we will store a SHA1 hash
    `password` CHAR(40) NOT NULL
);
```

For this example we will have a controller that will handle a login request from the user. The request will contain the user and password for the user

```php
<?php
class IndexController extends Zend_Controller_Action
{
    public function indexAction()
    {
        $request = $this->getRequest();

        if ($request->isPost()) {
            // I am assuming the DB connection is in the registry
            $database = Zend_Registry::get('db');

            $auth = new Zend_Auth_Adapter_DbTable(
                $database, // Database connection
                'system_users', // Users table
                'username', // User credential
                'password' // User secret (password)
            );
            $auth->setIdentity($request->getParam('user')) // Pass the user from the request
                // Pass the password. Note that I have to manually create the password hash
                ->setCredential(sha1($request->getParam('password')));
            $result = $auth->authenticate();
            if (!$result->isValid()) {
                // Handle invalid login atempt
            } else {
                // Persist the credentials
                // Get the configured storage for Zend_Auth. By default this is
                // a session
                $storage = Zend_Auth::getInstance()->getStorage();

                // For my example I am only writing the username but
                // getResultRowObject will return all the fields from the users
                // table so you could save more information about the user if
                // you think you will need it in your system
                $storage->write($auth->getResultRowObject(array('username')));

                // Now you can redirect or do whatever you want
            }
        }
    }
}
```

The comments explain what each part of the code is doing. The next thing your system probably wants to do related with authentication is retrieve the persisted information in following requests. This can easily be done with these lines of code:

```php
$auth = Zend_Auth::getInstance();
$user = $auth->getIdentity();
```

Now the user variable has all the information you persisted about the user. Since this was stored in a session the duration of those credentials will depend on your server configuration (By default 30 minutes).
