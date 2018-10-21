---
id: 4357
title: Dependency management with golang/dep
date: 2017-09-27T11:10:16+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4357
permalink: /2017/09/dependency-management-with-golangdep/
tags:
  - docker
  - golang
  - programming
---
It has been more than a year since I wrote an article about [dependency management with Glide](https://ncona.com/2016/05/golang-sane-dependency-management-with-glide/). It seems like things have changed a little since then. An [official package manager](https://github.com/golang/dep) has been started by the community, which hopefully will make things easier for developers.

## Install

For go applications more than with any other language (because of the necessity of GOPATH), I highly recommend using docker. This is a minimal Dockerfile I&#8217;m using that includes both Go and Dep:

<!--more-->

```docker
FROM golang:1.9.0-alpine3.6

RUN apk update \
  && apk add ca-certificates wget unzip git \
  && update-ca-certificates

# Install golang/dep
WORKDIR /root
RUN wget https://github.com/golang/dep/releases/download/v0.3.0/dep-linux-amd64.zip
RUN unzip dep-linux-amd64.zip -d bin
ENV PATH="/root/bin:${PATH}"

WORKDIR /go/src/app
COPY . .

CMD ["go-wrapper", "run"]
```

You can use this command to build the image:

```
docker build -t go-dep .
```

And to get a terminal:

```
docker run --rm -it --name go-dep-container -v $(pwd):/go/src/app go-dep sh
```

## Managing dependencies

We can now start using dep from within the container:

```
dep init
```

This creates a vendor folder where dependencies will be installed, a Gopkg.toml file that will contain the project dependencies&#8217; constraints and a Gopkg.lock that will lock the dependencies&#8217; versions.

Since this is a new project, all the generated files are empty. We can use _dep ensure_ to install our first dependency:

```
dep ensure -add github.com/astaxie/beego
```

Running this command gives a warning message:

```
"github.com/astaxie/beego" is not imported by your project, and has been temporarily added to Gopkg.lock and vendor/.
If you run "dep ensure" again before actually importing it, it will disappear from Gopkg.lock and vendor/.
```

As stated in the message Gopkg.lock and the vendor folder are updated, but Gopkg.toml is not. The reason Gopkg.toml is not updated is because there is no need to do it unless there is a version constraint specified. If no version constraint is specified then _dep_ will look at the imports in your code to figure out which libraries to download and will add the latest version to Gopkg.lock.

If you want to specify a constraint you can use this command instead:

```
dep ensure -add github.com/astaxie/beego@=v1.8.0
```

Note that I used an _=_ sign after the _@_, to specify that I want exactly that version. If you did not include the _=_ sign:

```
dep ensure -add github.com/astaxie/beego@v1.8.0
```

It would be interpreted as a major range (^). There are [other operands you can use to specify a version range](https://github.com/Masterminds/semver), but I recommend pinning to a specific version to avoid surprises.

If you want to update the version of a dependency the best way to do it is by modifying the version in Gopkg.toml:

```toml
[[constraint]]
  name = "github.com/astaxie/beego"
  version = "=1.9.0"
```

And run:

```
dep ensure
```

To update Gopkg.lock and the vendor folder.

## Conclusion

Seems like dependency management has evolved in a good direction since last time I looked at it. Although I would like a way to update the version of a dependency from the command line, it was still easy enough to just update Gopkg.toml with the new version. I think with the current state of Dep, it is possible to have dependency management that makes sense for Go projects and we can finally start focusing on building software.
