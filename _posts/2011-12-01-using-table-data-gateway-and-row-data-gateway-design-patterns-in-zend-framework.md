---
id: 480
title: Using Table Data Gateway and Row Data Gateway design patterns in Zend Framework
date: 2011-12-01T03:08:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=480
permalink: /2011/12/using-table-data-gateway-and-row-data-gateway-design-patterns-in-zend-framework/
tags:
  - design_patterns
  - php
  - zend_framework
---
Table Data Gateway and Row Data Gateway are two design patterns that are very closely related. The former specifies an object that acts as a gateway from our system to a table in a database. This means that it will give us the functionality necessary to execute all common operation to that table easily by providing methods to all the CRUD (Create, Read, Update, Delete) operations.
  
Row Data Gateway provides very similar functionality, but it lets you execute those operations in a single record of a table.

## The Zend implementation

Zend Framework provides us with Zend\_Db\_Table as an implementation of the Table Data Gateway pattern and Zend\_Db\_Table\_Row as an implementation of the Row Data Gateway pattern. The best way to use these implementations is by extending Zend\_Db\_Table\_Abstract and Zend\_Db\_Table\_Row\_Abstract respectively.

<!--more-->

Here is an example of how to do this:

```php
class Books extends Zend_Db_Table_Abstract
{
    // Table name
    protected $_name = 'books';
}
```

## Using the patterns in the real world

We will go over an example to explain how to use these patterns in a real Zend application.

Imagine we need to make an application for a books catalog. We would want to have a **books** class to represent a listing of books, and a **book** class to represent a single record of the books table.

Lets start by creating our Book class:

```php
// Extend Zend_Db_Table_Row_Abstract so we get all its functionality
class Book extends Zend_Db_Table_Row_Abstract
{
    /* We can add as many extra methods as we find necessary */

    // Function to get the publication date in an specific format
    public function getPublicationDate($format = 'd/m/Y')
    {
        $date = new DateTime($this->publication_date);

        return $date->format($format);
    }
}
```

And our Books table:

```php
class Books extends Zend_Db_Table_Abstract
{
    // Table name
    protected $_name = 'books';
    // Zend will automatically look for a Class named 'books' and make the rows
    // returned by any query to this table, instances of it. This way we will
    // have access to getPublicationDate method for all records
    protected $_rowClass = 'book';
}
```

As an example of how to use what we have done so far, we can make a function called **getOldestBooks** that will return the oldest books in our database:

```php
class BooksService
{
    public function getOldestBooks($quantity = 10)
    {
        // I am assuming autoload is configured and there is a default database
        // adapter already set up
        $books = new Books();
        $oldestBooks = $books->fetchAll(
            $books->select()->order('publication_date')->limit($quantity, 0)
        );

        // Then we could loop through the result like this
        // (Needless to say this is just a demonstration. You shouldn't echo
        // anything from a model.
        foreach ($books as $book)
        {
            echo $book->title.'('.$book->getPublicationDate().")<br />";
        }
    }
}
```

We used Zend\_Db\_Select to create a query without writing any SQL code. We can learn how to make more complex queries in [Zend\_Db\_Select documentation](http://framework.zend.com/manual/en/zend.db.select.html).
