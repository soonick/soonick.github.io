---
id: 796
title: Zend Framework Authorization
date: 2013-01-17T02:47:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=796
permalink: /2013/01/zend-framework-authorization/
tags:
  - authentication
  - design_patterns
  - php
  - programming
---
Authorization is the process of specifying access to resources to different users based on defined roles. Zend Framework provides Zend_Acl to define and enforce an Access Control List (ACL).

## Resources

In Zend Framework context resources are usually actions you want to control access to. Zend provides the Zend\_Acl\_Resource class to create resources. Each resource should have a unique ID to identify it.

```php
new Zend_Acl_Resource('resourceId');
```

Then you can add the resource to Zend\_Acl using Zend\_Acl::add:

```php
Zend_Acl::add(new Zend_Acl_Resource('resourceId'));
```

<!--more-->

## Roles

In your application, roles are the different kind of users your application serves. Zend framework provides Zend\_Acl\_Role to create roles, and they work very similar to Resources:

```php
Zend_Acl::addRole(new Zend_Acl_Role('roleId'));
```

Since it is very usual to have roles in a hierarchical structure you can have roles that inherit from other roles. You only need to specify the role you want to inherit from as the second argument of Zend\_Acl\_Role constructor:

```php
new Zend_Acl_Role('roleId', 'parentRole');
```

## Rules

Rules are when we specify if a role has or not access to an specific resource. Zend\_Acl uses a white list approach by default, so you need to explicitly define each rule for your system. For giving permissions to a specif role to a resource you can use Zend\_Acl::allow:

```php
Zend_Acl::allow('guestId', 'resourceId');
```

## Putting it all together

To put this all together I like to have a model that controls all the rules:

```php
<?php
/**
 * ACL model
 */
class Application_Model_Acl extends Zend_Acl
{
    /**
     * Initialize authorization
     */
    public function __construct()
    {
        $this->createRoles();
        $this->createResources();
        $this->createRules();
    }

    /**
     * Create roles
     */
    protected function createRoles()
    {
        $this->addRole(new Zend_Acl_Role('guest'));
        $this->addRole(new Zend_Acl_Role('admin'), 'guest');
    }

    /**
     * Create resources
     */
    protected function createResources()
    {
        // Some Controller::Action keys
        $this->add(new Zend_Acl_Resource('error::error'));
        $this->add(new Zend_Acl_Resource('auth::login'));
        $this->add(new Zend_Acl_Resource('index::index'));
        $this->add(new Zend_Acl_Resource('auth::logout'));
        $this->add(new Zend_Acl_Resource('admin::index'));
    }

    /**
     * Create access rules
     */
    protected function createRules()
    {
        // Guest permissions
        $this->allow('guest', 'error::error');
        $this->allow('guest', 'auth::login');
        $this->allow('guest', 'index::index');

        // Admin permissions
        $this->allow('admin', 'auth::logout');
        $this->allow('admin', 'admin::index');
    }
}
```

Now we have a model that we can easily instantiate it to initialize our ACL. You can see that for the resource keys I used a combination of controller::key.

Because we want to activate our ACL with every request the best bet is to make a plugin to run it.

```php
<?php
/**
 * ACL Plugin
 */
class Application_Plugin_Acl extends Zend_Controller_Plugin_Abstract
{
    /**
     * Index of the role in the authentication storage
     * @const string
     */
    const ROLE_INDEX = 'role';

    /**
     * Default role for not logged users
     * @const string
     */
    const DEFAULT_ROLE = 'guest';

    /**
     * Verify if the logged user has access to the requested resource. If the
     * user does not have access they will be redirected to an authorization
     * page
     *
     * @param Zend_Controller_Request_Abstract $request
     */
    public function preDispatch(Zend_Controller_Request_Abstract $request)
    {
        // We get the current role from the Authentication object
        $auth = Zend_Auth::getInstance();
        $user = $auth->getIdentity();

        if (isset($user->{self::ROLE_INDEX})) {
            $role = $user->{self::ROLE_INDEX};
        } else {
            $role = self::DEFAULT_ROLE;
        }

        $acl = new Application_Model_Acl();
        if (
            !$acl->isAllowed(
                $role,
                $request->getControllerName() . '::' . $request->getActionName()
            )
        ) {
            // Redirect to login page
        }
    }
}
```

That&#8217;s it, we have our authorization system ready.
