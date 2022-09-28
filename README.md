[![Build Status](https://travis-ci.com/soonick/soonick.github.io.svg?branch=master)](https://travis-ci.com/soonick/soonick.github.io)

My blog. You can find it at [ncona.com](https://ncona.com).

# Development

Create the docker image:

```
docker build -t ncona-blog .
```

To run:

```
docker run -it -p 4000:4000 ncona-blog
```
