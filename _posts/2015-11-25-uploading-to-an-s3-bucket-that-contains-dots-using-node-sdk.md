---
id: 3335
title: Uploading to an S3 bucket that contains dots using node SDK
date: 2015-11-25T07:29:28+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3335
permalink: /2015/11/uploading-to-an-s3-bucket-that-contains-dots-using-node-sdk/
categories:
  - Javascript
tags:
  - aws
  - javascript
  - node
  - programming
---
I&#8217;m trying to host a static site in S3 using AWS. The problem is that for it to work with a custom domain, the bucket needs to be named like the domain. Domain names contains dots and for some reason they are not supported out of the box in the SDK. I was trying to something like this:

```js
var fs = require('fs');
var aws = require('aws-sdk');
var bucket = 'my.domain.com';

var bucketParams = {
  params: {
    Bucket: bucket
  }
}
var bucket = new aws.S3(bucketParams);

var uploadData = {
  ACL: 'public-read',
  CacheControl: 'max-age=31556926',
  Key: 'somefile.txt',
  ContentType: 'text/plain'
};
uploadData.Body = fs.createReadStream('somefile.txt');
bucket.upload(uploadData).send();
```

<!--more-->

And it was simply not working. Similar code has worked previously with a bucket name that didn&#8217;t contain dots, so I did some research and found the solution. For some reason AWS doesn&#8217;t allow by default bucket names with dots. To walk around the issue, you have to add **s3ForcePathStyle** and **region** when creating the S3 object:

```js
var fs = require('fs');
var aws = require('aws-sdk');
var bucket = 'my.domain.com';

var bucketParams = {
  params: {
    Bucket: bucket
  },
  s3ForcePathStyle: true,
  region: 'eu-west-1'
}
var bucket = new aws.S3(bucketParams);

var uploadData = {
  ACL: 'public-read',
  CacheControl: 'max-age=31556926',
  Key: 'somefile.txt',
  ContentType: 'text/plain'
};
uploadData.Body = fs.createReadStream('somefile.txt');
bucket.upload(uploadData).send();
```

And that fixes the problem.
