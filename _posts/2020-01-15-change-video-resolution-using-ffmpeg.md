---
title: Change video resolution using ffmpeg
author: adrian.ancona
layout: post
date: 2020-01-15
permalink: /2020/01/change-video-resolution-using-ffmpeg/
tags:
  - linux
  - automation
---

I have some videos that I recorded in very high quality and ended up being too heavy. To save some space I decided to resize them and I found this can be easily done with ffmpeg.

To install ffmpeg:

```sh
sudo apt install ffmpeg
```

Then, we just need one command to change the resolution of a video:

```sh
ffmpeg -i input.mp4 -vf scale=-1:720 output.mp4
```

The scale argument means the output video will have a width of 720px and the height will be set based on the ratio of the original video.
