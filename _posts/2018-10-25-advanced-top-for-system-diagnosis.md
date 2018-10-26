---
title: Advanced top for system diagnosis
date: 2018-10-25
author: adrian.ancona
layout: post
permalink: /2018/10/advanced-top-for-system-diagnosis/
tags:
  - debugging
  - linux
---

In a previous post I went over the <a href="https://ncona.com/2018/10/introduction-to-top-for-system-diagnosis/">basics of top</a>. In this post I'm going over some more advanced features that can be used to diagnose problems.

Top will by default refresh every 3 seconds. If this is too often for you, you can specify how many seconds to wait between each refresh:

```
top -d 10
```

`d` stands for delay.

Another useful option is to hide idle tasks:

```
top -i
```

The letter `i` can also by used to toggle idle tasks while top is running.

If you are interested in processes belonging to a specific user:

```
top -u adrian
```

<!--more-->

Or type the letter `u` while top is running. A prompt will appear to enter a user:

[<img src="/images/posts/top-filter-by-user.png" />](/images/posts/top-filter-by-user.png)

Another userful option is `V`. It can be used to see the processes as a tree (see which process is a child of which):

[<img src="/images/posts/top-tree-view.png" />](/images/posts/top-tree-view.png)

Sometimes besides seeing the processing running on your system you might want to kill them. You can use `k` to kill a process. You will be prompted for the PID and signal:

[<img src="/images/posts/top-send-signal.png" />](/images/posts/top-send-signal.png)


## Working with columns

Another useful tool for finding what you are looking for is to work with the columns. While on top, use `x` to turn on column highlighting. This shows the currently selected column:

[<img src="/images/posts/top-column-highlight.png" />](/images/posts/top-column-highlight.png)

You can move between columns using `<` and `>` for left and right respectively. The task list will be sorted by the selected column. You can invert the sorting by using `R`. There are some bookmarks you can use to navigate between columns faster:

- `M` - %MEM
- `N` - PID
- `P` - %CPU

You can search for a string in the highlighted column using `L`:

[<img src="/images/posts/top-locate.png" />](/images/posts/top-locate.png)

You can also filter the tasks based on a column. To start filtering enter `o` and enter a filter. An example filter can be: `COMMAND=fire`, which will only show commands containing the word fire. You can also find the processes using more than certain amount of memory: `%MEM>1.0`

[<img src="/images/posts/top-filter.png" />](/images/posts/top-filter.png)

This are the parts I found most interesting about top. If you know any trick I didn't cover, please let me know.
