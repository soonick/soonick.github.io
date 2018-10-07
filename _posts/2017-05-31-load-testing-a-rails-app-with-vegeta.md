---
id: 4251
title: Load testing a Rails app with Vegeta
date: 2017-05-31T13:35:44+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4251
permalink: /2017/05/load-testing-a-rails-app-with-vegeta/
categories:
  - Application Design
tags:
  - docker
  - programming
  - rails
  - ruby
  - testing
---
I&#8217;m building a very simple app using Rails. While looking for guidance for preparing it for production, I found a lot of articles suggesting to put Nginx in front of it. After talking to some people they explained some reasons why this is suggested:

  * _Ngingx can serve static assets_ &#8211; This appears to be the greatest and clearer advantage. You can configure Ngingx to directly serve static assets without having to hit Rails at all. This is very good because every request that comes to Rails will block all other request because Ruby is single threaded
  * _Nginx can do caching for you_ &#8211; Nginx can cache some of the static assets, which would give them a performance boost
  * _Nginx is multithreaded_ &#8211; Nginx can serve multiple static assets at the same time Rails is serving requests

These are definitely advantages (specially the first one), but having Nginx in front of my server also adds complexity to my deployment. To figure out if the added complexity worth it, I decided to run some load tests. Here I will explain how I did it and what were the results.

<!--more-->

## Vegeta

Vegeta is an HTTP load testing library written in Go that makes it easy to send a lot of concurrent requests to a service.

Installing Vegeta in Mac is very easy:

```
brew update && brew install vegeta
```

The other option they have in their documentation is compiling the source code. This can be a little time consuming so I tried to find something easier. I found a Dockerized version that turned out to be very easy to set up:

```
docker pull nlsun/vegeta
docker run -it nlsun/vegeta bash
```

From inside the container Vegeta is accessible.

Since my Rails application also runs in a container, there are two ways I can test it:

  * Link the containers together
  * Have the Vegeta container use the host network

I&#8217;m going to try both approaches to see if there is any difference in the results.

## Linked containers without Nginx

To start the Vegeta container linked to my app I ran this command:

```
docker run -it --link my-container:my-app nlsun/vegeta bash
```

Inside the container I tried this command first:

```
echo "GET http://my-app/the-url" | vegeta attack -duration=5s | tee results.bin | vegeta report
```

The first time I got this response:

```
Requests      [total, rate]            250, 50.20
Duration      [total, attack, wait]    34.98306796s, 4.979996105s, 30.003071855s
Latencies     [mean, 50, 95, 99, max]  27.419410301s, 30.002344256s, 30.003797859s, 30.004251691s, 30.011053948s
Bytes In      [total, mean]            52600, 210.40
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  0.00%
Status Codes  [code:count]             400:50  0:200
Error Set:
400 Bad Request
Get http://my-app/the-url: net/http: timeout awaiting response headers
```

Duration, Latencies and Status Codes are the ones that I find more interesting.

The duration tells you how much time the test took. Attack is the time Vegeta was sending requests. Wait, is the time Vegeta had to wait to get the last response.

Latencies are the the distribution of the times it took for each request to complete.

Status codes shows how many of the responses returned each of the status codes. In my test 50 requests returned 400 and 200 request returned 0 (A status code of 0 means the request timed out).

## Host network without Nginx

For the next test, I&#8217;m going to run Vegeta on the host network:

```
docker run -it --net=host nlsun/vegeta bash
```

This was the result:

```
Requests      [total, rate]            250, 50.20
Duration      [total, attack, wait]    34.98283338s, 4.979996404s, 30.002836976s
Latencies     [mean, 50, 95, 99, max]  26.592029755s, 30.003364317s, 30.005452751s, 30.005996499s, 30.007250597s
Bytes In      [total, mean]            63120, 252.48
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  0.00%
Status Codes  [code:count]             400:60  0:190
Error Set:
400 Bad Request
Get http://localhost/the-url: net/http: timeout awaiting response headers
```

## Linked containers with Nginx

I have different container with my application running with Nginx in front. This is the result I got from the same test:

```
Requests      [total, rate]            250, 50.20
Duration      [total, attack, wait]    34.985870507s, 4.979996504s, 30.005874003s
Latencies     [mean, 50, 95, 99, max]  26.507517716s, 30.00374546s, 30.005756032s, 30.006501318s, 30.011148688s
Bytes In      [total, mean]            63120, 252.48
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  0.00%
Status Codes  [code:count]             400:60  0:190
Error Set:
400 Bad Request
Get http://my-app/the-url: net/http: timeout awaiting response headers
```

Not really much difference than without Nginx.

## Host network with Nginx

```
Requests      [total, rate]            250, 50.20
Duration      [total, attack, wait]    34.982744556s, 4.979995605s, 30.002748951s
Latencies     [mean, 50, 95, 99, max]  26.126098148s, 30.00238745s, 30.003757005s, 30.004446339s, 30.010535079s
Bytes In      [total, mean]            68380, 273.52
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  0.00%
Status Codes  [code:count]             400:65  0:185
Error Set:
400 Bad Request
Get http://localhost/the-url: net/http: timeout awaiting response headers
```

## Finding the throughput

In the tests above we can see that it doesn&#8217;t matter if I use Nginx or not, most of the requests are timing out. This is most likely happening because the load is just too much for the single server I&#8217;m testing. What I&#8217;m going to do now is tune the test values to figure out the throughput with and without Ngingx.

In my tests above I was using this command: _vegeta attack -duration=5s_. There are a few important default settings that are being used that are greatly affecting those tests. The first setting affecting our test is the _timeout_. If you look at the Max latency for the tests above, you will see that they are all around 30 seconds. This is indeed the default timeout Vegeta uses. In the tests above, most requests are timing out. The Other important setting is the _rate_. The first line of the output indicates how many requests were sent in total and the number of requests sent per second. The default value for rate is 50 requests per second.

I&#8217;m going to play around with the rate value until I find a value where requests don&#8217;t timeout. I will also change the timeout value to 10 seconds.

With Nginx the best rate I could get without errors was 6 requests per second:

```
$ echo "GET http://localhost/the-url" | vegeta attack -duration=5s -timeout 10s -rate=6 | tee results.bin | vegeta report
Requests      [total, rate]            30, 6.21
Duration      [total, attack, wait]    12.96665195s, 4.833312638s, 8.133339312s
Latencies     [mean, 50, 95, 99, max]  5.098532163s, 4.50104335s, 8.134160062s, 8.141433414s, 8.15678815s
Bytes In      [total, mean]            31560, 1052.00
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  0.00%
Status Codes  [code:count]             400:30
Error Set:
400 Bad Request
```

Without Nginx the highest rate I could get was also 6 requests per second, but latency was higher in this case:

```
$ echo "GET http://localhost/the-url" | vegeta attack -duration=5s -timeout 10s -rate=6 | tee results.bin | vegeta report
Requests      [total, rate]            30, 6.21
Duration      [total, attack, wait]    13.9413419s, 4.833329918s, 9.108011982s
Latencies     [mean, 50, 95, 99, max]  5.495428202s, 6.310275066s, 9.674004881s, 9.688399531s, 9.774678646s
Bytes In      [total, mean]            31560, 1052.00
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  0.00%
Status Codes  [code:count]             400:30
Error Set:
400 Bad Request
```

## Letting Nginx shine

In the previous section we could already see that Nginx was doing considerably better. But the truth is that we are not testing a very realistic scenario. One of the greatest benefits of using Nginx is that it can serve static assets for you without even hitting Rails. In this test I&#8217;m going to run a little more realistic test where I make a request to Rails followed by a few static assets (kind of how it would happen in a browser).

First of all I created a file with this content:

```
GET http://localhost/the-url
GET http://localhost/assets/styles-aec9a551d3a420b1d8cca0e163a65a9889fe2e6b8f4b683654991565364102d8.css
GET http://localhost/assets/logo-ec626ab1211178d338cc156cf49d0c63f575e9d62bf1db1b593d99dcbf5b2e08.png
GET http://localhost/assets/image-b90e37811d04809daab35290a24ad883d5f4aeadea2f6348cde178b35d04dd8b.png
```

And used this command:

```
vegeta attack -duration=5s -timeout 10s -rate=7 -targets=the-file-name | tee results.bin | vegeta report
```

Interestingly even without Nginx I was able to get a much better request rate on this experiment (I was able to send 20 requests per second without timeouts). Most likely because requests for static assets are served much faster:

```
Requests      [total, rate]            100, 20.20
Duration      [total, attack, wait]    13.861634185s, 4.949996005s, 8.91163818s
Latencies     [mean, 50, 95, 99, max]  3.379640684s, 2.011261903s, 8.251704207s, 9.279792508s, 9.66163818s
Bytes In      [total, mean]            721825, 7218.25
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  75.00%
Status Codes  [code:count]             400:25  200:75
Error Set:
400 Bad Request
```

With the same rate the Nginx results were better:

```
Requests      [total, rate]            100, 20.20
Duration      [total, attack, wait]    10.856156663s, 4.949996105s, 5.906160558s
Latencies     [mean, 50, 95, 99, max]  1.010866864s, 2.886086ms, 5.051267323s, 6.057474288s, 6.061682921s
Bytes In      [total, mean]            721825, 7218.25
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  75.00%
Status Codes  [code:count]             200:75  400:25
Error Set:
400 Bad Request
```

You can see that the wait time and the latencies were considerably lower with Nginx. Nginx also allowed us to have a considerably higher throughput:

```
$ vegeta attack -duration=5s -timeout 10s -rate=28 -targets=targets | tee results.bin | vegeta report
Requests      [total, rate]            140, 28.20
Duration      [total, attack, wait]    14.636395769s, 4.964282419s, 9.67211335s
Latencies     [mean, 50, 95, 99, max]  1.475985874s, 3.054979ms, 8.486611471s, 9.782391512s, 9.786797663s
Bytes In      [total, mean]            1010555, 7218.25
Bytes Out     [total, mean]            0, 0.00
Success       [ratio]                  75.00%
Status Codes  [code:count]             200:105  400:35
Error Set:
400 Bad Request
```

## Conclusion

Based on the results of my not very thorough tests I can conclude that adding Nginx in front of Rails is definitely a good idea. You can serve almost 50% more traffic just by doing this. Even if throughput is not a concern, response times are around 30% faster just by using Nginx (in the higher percentiles).
