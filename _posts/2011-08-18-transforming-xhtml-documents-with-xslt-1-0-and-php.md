---
id: 331
title: Transforming XHTML documents with XSLT 1.0 and PHP
date: 2011-08-18T00:42:33+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=331
permalink: /2011/08/transforming-xhtml-documents-with-xslt-1-0-and-php/
tags:
  - php
  - xml
---
**XSLT (Extensible Stylesheet Language Transformations)** is a language used to transform XML documents. It is mostly used to transform an XML document into a different XML document with a different XML Schema.

**XHTML (eXtensible HyperText Markup Language)** is an XML version of the HTML markup language. It was created so websites could be parsed using standard XML processors instead of having to depend on specific HTML processors.

## The problem

So far everything sounds good, but there are some problems. Following the standard you should be able (as a matter of fact you must) to send an XHTML document to the browser with a mime type of **&#8220;application/xhtml+xml&#8221;**. The problem here is that some browsers (IE) don&#8217;t understand that mime type and thus don&#8217;t render your document.

<!--more-->

What most sites currently do is serve XHTML documents with a mime type of &#8220;text/html&#8221; and it almost works flawlessly. The problem here is that this is not a completely valid XML file, it is a mix of HTML and XML with some weird exceptions that we have to deal with.

In an XML document these two tags are exactly the same:

```
<br></br>
```

and

```
<br/>
```

They both represent **one** line break. The only difference is that the first example uses an opening and closing tag and the second uses a self-closing tag. Most browsers when instructed to render a document as &#8220;text/html&#8221; they will interpret the first example as two line breaks, and that could lead to some problems in our document structure.

The previous is just one example but there are a bunch of specific cases that are similar.

## My solution

For solving this problem I took a look at the XHTML doctype and found out all the elements that can(must) be self closed in XHTML. Here is the list I found:

```
area
base
basefont
br
col
frame
hr
img
input
link
meta
param
```

Knowing this, what I want to do is: If I find an empty element that is in the previous list, that element must be self-closed. Every other element must have an opening and closing tag.

## Implementing the solution

Finding a way to achieve this, was not the easiest thing to do. Mostly because I am new with XSLT and because I didn&#8217;t know how it worked.

If you are starting with XSLT I recomend you a lot reading <http://www.xmlplease.com/xsltidentity> to find how the identity template works. After reading that article everything else was a lot easier.

This template takes an XHTML parses it, and then gives the same document as output. This sounds pretty useless, but modifying this template you can modify XHTML documents with out worring about the issues I mentioned earlier:

```xml
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="no" />
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test=". = \'\'">
                <xsl:comment>Empty</xsl:comment>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="meta|link|br|img|hr|input|area|base|basefont|col|frame|param">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
```

The first **xsl:template** tag is a common identity template that takes one element and copies it to the output including any name-spaces and attributes, but it one difference compared to a common identity template. The **xsl:if** tag verifies if the element that is being parsed is empty, and if it is a comment is added inside it.

If we had:

```xml
<script type="text/javascript" src="myfile.js"></script>
```

It would be transformed to:

```xml
<script type="text/javascript" src="myfile.js"><!--Empty--></script>
```

The second **xsl:template** tag only matches our known self-closing tags. Since in XSLT the last template that matches an element overwrites the previous one, this last template overwrites the last rule that applies for everything else. This rule copies the element exactly as it is without adding a comment, this way we avoid a self closing tag to be divided in two.

If we had:

```xml
<br/>
```

It would be transformed to:

```xml
<br/>
```

So our resulting document would be XHTML valid.

## Using XSLT from PHP

Finally I will show how to use the XSLT processor included in PHP to parse an XML document.

```php
$xml = new DOMDocument;

// Here I assume $original contains the XML/XHTML document you want to transform
if (@$xml->loadXML($original))
{
    $xsl = new DOMDocument;

    // Here I assume $template is a string with the XSLT template
    $xsl->loadXML($template);
    $proc = new XSLTProcessor;
    $proc->importStyleSheet($xsl);

    // Now result is a string with the result of the transformation
    $result = $proc->transformToXML($xml);
}
```
