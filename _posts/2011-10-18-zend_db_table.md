---
id: 408
title: Zend_Db_Table
date: 2011-10-18T23:56:22+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=408
permalink: /2011/10/zend_db_table/
tags:
  - php
  - zend_framework
---
Zend\_Db\_Table is an implementation of the Table Data Gateway design pattern provided by the Zend Framework. It provides a set of methods and attributes useful for interacting with a database table, but can also be extended to provide custom functionality for your application.

In the simplest case you will only want to use the functionality already provided by Zend\_Db\_Table:

```php
// PDO_MYSQL can be replaced for any of the databases supported by Zend Framework
$db = Zend_Db::factory('PDO_MYSQL', $options);

// Set the db adapter that will be used by default by instances of Zend_Db_Table
Zend_Db_Table::setDefaultAdapter($db);

// Create an instance that will work against a table named 'users'
// This is case sensitive and must match exactly the name of the table
$usersTable = new Zend_Db_Table('users');
```

<!--more-->

If you want to be able to add custom methods you would extend the class like this:

```php
class Users extends Zend_Db_Table_Abstract
{
    // This attribute specifies the name of the table this class will handle.
    // If this attribute is not present the name of the class will be used
    protected $_name = 'users';

    // This attribute should match the name of the primary key of the table.
    // If it is not provided, Zend_Db_Table will try to discover it
    protected $_primary = 'user';

    // The constructor of this class by defaults sets up the table. If you want
    // to execute some code when this class is instantiated the best way to do it
    // is using the init method that will be executed after all table metadata
    // is processed
    public function init()
    {
    }
}
```

## Inserting rows

To insert a new record you can use the insert method:

```php
$usersTable = new Users('users');

// The array keys are the names of the columns and the array values are the
// values that are going to be inserted.
// By default all values are taken literally, so if you want to use an expression
// Zend_Db_Expr needs to be used. These values are escaped automatically.

$data = array(
    'user'      => 'my_user',
    'name'      => 'Juanito',
    'password'  => new Zend_Db_Expr('SHA1("mypass")')
);

$usersTable->insert($data);
```

## Updating rows

```php
$usersTable = new Users('users');

$data = array(
    'user'      => 'changed_user',
    'name'      => 'Juanita'
);

// You should use quoteInto to avoid sql injection
$where = $usersTable->getAdapter()->quoteInto('user = ?', 'my_user');

$usersTable->update($data, $where);
```

## Selecting rows

You can use the find() method if you want to find records based on the primary key:

```php
$usersTable = new Users('users');

// Find a single record
$row = $usersTable->find('my_user');

// Find multiple records
$row = $usersTable->find(array ('my_user', 'your_user'));
```

The find() method always returns an object of type Zend\_Db\_Table\_Rowset\_Abstract.

To fetch a set of rows or a single row based on a column different than the primary key you can use fetchAll() and fetchRow().

```php
$usersTable = new Users('users');

// select() method returns a Zend_Db_Table_Select object that you can modify
// to add select criteria at your convenience
$select = $usersTable->select()->where('name = ?', 'Juanito');

$rows = $table->fetchAll($select);
```

fetchAll() method also returns a Zend\_Db\_Table\_Rowset\_Abstract object.

The Zend\_Db\_Table_Select object accepts not only a where clause, but there are other filters you can apply:

```php
$usersTable = new Users('users');

// select() method returns a Zend_Db_Table_Select object that you can modify
// to add select criteria at your convenience
$select = $usersTable->select()
        // Specify which columns to return. You can use aggregate functions.
        ->from($usersTable, array('user', 'name', 'COUNT(reported_by) as count'))
        // Column that will be used to order rows
        ->order('name')
        // The first value is the number of rows to return and the second the offset
        ->limit(50, 0)
        // You can join with another table
        ->join('books', 'books.user = users.user')
        ->where('books.name = ?', 'The best book')
        ->where('status = ?', 'active');

$rows = $table->fetchAll($select);
```

There is a lot more stuff that can be done with Zend\_Db\_Table but I think this is the most useful.
