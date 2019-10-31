[![Build Status](https://travis-ci.com/soonick/soonick.github.io.svg?branch=master)](https://travis-ci.com/soonick/soonick.github.io)

My blog. You can find it at [ncona.com](https://ncona.com).

# Development

First install dependencies:

```
bundle install
```

To run locally:

```
bundle exec jekyll build && bundle exec jekyll s -DIl
```

To generate tag pages:

```
./_scripts/tag-generator.py
```
