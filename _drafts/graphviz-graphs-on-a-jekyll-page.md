---
title: Graphviz graphs on a Jekyll page
author: adrian.ancona
layout: post
date: 2020-06-24
permalink: /2020/06/graphviz-graphs-on-a-jekyll-page/
tags:
  - automation
  - productivity
  - github
  - open_source
  - projects
---

### Graphviz is not a supported plugin, so this doesn't work :(

In a previous post I showed how to [create graphs using Graphviz](/2020/06/create-diagrams-with-code-using-graphviz/). In this post, I'm going to explore how we can embed graphs directly in a Jekyll page (such as this blog).

This blog is built with Jekyll and published by Github pages. To write Graphviz diagrams and have them rendered in a page, we need to use a plugin.

I decided to use [jekyll-graphviz](https://github.com/kui/jekyll-graphviz) since it seems to be currently the most popular.

To install, add this to the `Gemfile`:

```ruby
group :jekyll_plugins do
  gem 'jekyll-graphviz'
end
```

<!--more-->

We also need to update `_config.yml`:

```yaml
plugins:
  - jekyll-graphviz
```

And run `bundle` to install it.


To add graphs to a blog post, just wrap it in `graphviz` tags using this syntax:

```ruby
{% raw %}
{% graphviz %}
digraph MyGraph {
  begin [label="This is the beginning"]
  end [label="It ends here"]
  begin -> end
}
{% endgraphviz %}{% endraw %}
```

And it will be rendered as expected:

{% graphviz %}
digraph MyGraph {
  begin [label="This is the beginning"]
  end [label="It ends here"]
  begin -> end
}
{% endgraphviz %}
