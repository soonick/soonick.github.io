---
title: Add Watermark to Images From The Browser
author: adrian.ancona
layout: post
# date: 2025-10-01
# permalink: /2025/10/add-watermark-to-images-from-the-browser/
tags:
  - javascript
  - programming
---

We start by drawing the image into a canvas. To do this, we need to make sure the image has been loaded by the browser, which we can do with this function:

```js
async function loadImage(url) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = reject;
    img.src = url;
  });
}
```

<!--more-->

This function creates a new `img` element and returns a `Promise` that will be resolved to the `img` or rejected if there is a problem loading it.

We can now draw the image in a canvas:

```js
const canvas = document.createElement('canvas');
const ctx = canvas.getContext('2d');
const image = await loadImage(URL.createObjectURL(file));
canvas.width = image.width;
canvas.height = image.height;
ctx.drawImage(image, 0, 0);
```

Here, we are using `createElement` to build the canvas, but we could also select a canvas that is already in our document by using `getElementById` or another selector.

We can add the watermark by drawing a different image with low opacity:

```js
const watermark = await loadImage(WatermarkUrl);

const canvasRatio = canvas.width / canvas.height;
const watermarkRatio = watermark.width / watermark.height;
let watermarkWidth;
let watermarkHeight;
let left = 0;
let top = 0;
if (watermarkRatio > canvasRatio) {
  watermarkWidth = canvas.width;
  watermarkHeight = watermarkWidth / watermarkRatio;
  top = (canvas.height - watermarkHeight) / 2;
} else {
  watermarkHeight = canvas.height;
  watermarkWidth = watermarkHeight * watermarkRatio;
  left = (canvas.width - watermarkWidth) / 2;
}

ctx.imageSmoothingEnabled = true;
ctx.imageSmoothingQuality = 'high';
ctx.globalAlpha = 0.2;
ctx.drawImage(watermark, left, top, watermarkSize, watermarkSize);
ctx.globalAlpha = 1.0;
```

In the example above, we are making the watermark as big as possible, keeping its aspect ratio and centering it in the canvas. This can be modified to any desired size and position.

We set a couple of properties on `ctx` to preserve the quality of the watermark and set the opacity to `0.2`. After drawing the watermark, we reset the opacity, so future operations are not affected.

After this, we can add the canvas to our document:

```js
document.body.appendChild(canvas);
```

We can get a data URL that we can use in an image:

```js
const url = canvas.toDataURL('image/jpeg', 0.9);
```

Or we can get a blob representation that we can use to post the image to a backend:

```js
async function getBlob(canvas) {
  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => {
        if (!blob) {
          reject();
          return;
        }

        resolve(blob);
      },
      'image/jpeg',
      0.9
    );
  });
}

const blob = getBlob(canvas);
await fetch(uploadUrl, {
  method: 'POST',
  headers: {
    'Content-Type': 'image/jpeg'
  },
  body: blob
});
```

## Conclusion

Adding a watermark to an image requires only a bit of knowledge about canvas. As usual, you can find a working version of the code in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/add-watermark-to-images-from-the-browser).
