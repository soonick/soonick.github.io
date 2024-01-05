---
title: Getting Started With Arduino UNO R4
author: adrian.ancona
layout: post
# date: 2023-12-27
# permalink: /2023/12/introduction-to-kicad-for-circuit-design
tags:
  - electronics
---

In this article, I'm going to show how to write a simple program for Arduino UNO R4. I expect most of the steps I follow here can be used for other models of Arduino, but I'm going to be using the LED Matrix that come in the board and will only test on this model.

## Installing the IDE

In order to compile and install our programs into our Arduino, we need to download the Arduino IDE. We can get it from the [Arduino Software Page](https://www.arduino.cc/en/software).

The installation instructions might vary depending on your OS. I use Ubuntu, so I downloaded the `AppImage` file.

In order to run `AppImage` files we need FUSE:

```bash
sudo add-apt-repository universe
sudo apt install libfuse2
```

Then we can just run the `AppImage` file:

```bash
chmod +x arduino-ide_2.2.1_Linux_64bit.AppImage
./arduino-ide_2.2.1_Linux_64bit.AppImage
```

<!--more-->

The IDE will open:

[<img src="/images/posts/arduino-ide.png" alt="Arduino IDE" />](/images/posts/arduino-ide.png)

## Creating a Sketch

Arduino programs are called `sketches`. In this section we are going to take advantage of the LED matrix included in Arduino UNO R4 to create our first sketch.

Our sketch will simply turn on all the LEDs in the matrix 1 by 1 and then turn them off 1 by 1. The code we are going to use is the following:

```cpp
#include "Arduino_LED_Matrix.h"

ArduinoLEDMatrix matrix;

// Each byte with value different to 0 will turn on the corresponding LED
byte Time[8][12] = {
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

void setup() {
  matrix.begin();
}

void loop() {
  // We loop all rows and all columns
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 12; j++) {
      // Toggle the LED state
      if (Time[i][j] == 0) {
        Time[i][j] = 1;
      } else {
        Time[i][j] = 0;
      }

      // Re-render the matrix
      matrix.renderBitmap(Time, 8, 12);

      // Sleep for 100 miliseconds
      delay(100);
    }
  }
}
```

The first step is to copy this code on our IDE:

[<img src="/images/posts/arduino-ide-with-code.png" alt="Arduino IDE With Code" />](/images/posts/arduino-ide-with-code.png)

Then we need to connect our Arduino board to our computer using a USB cable, and select it on our IDE:

[<img src="/images/posts/arduino-ide-select-board.png" alt="Arduino IDE Select Board" />](/images/posts/arduino-ide-select-board.png)

Finally, click the `Upload` button:

[<img src="/images/posts/arduino-ide-upload-button.png" alt="Arduino IDE Upload Button" />](/images/posts/arduino-ide-upload-button.png)

If you encounter any issues at this step, look at the `troubleshooting` section below.

It's possible that we get a message asking us to install a board:

[<img src="/images/posts/arduino-ide-install-board.png" alt="Arduino IDE Install Board" />](/images/posts/arduino-ide-install-board.png)

We just need to click `yes`.

If everything goes well, we will get a message saying that the upload is done:

[<img src="/images/posts/arduino-ide-upload-done.png" alt="Arduino IDE Upload Done" />](/images/posts/arduino-ide-upload-done.png)

As soon as this happens, our Arduino will start running the program:

[<img src="/images/posts/arduino-running-program.jpg" alt="Arduino Running Program" />](/images/posts/arduino-running-program.jpg)

## Troubleshooting

### Permission denied on /dev/ttyACM0

I got this error when I tried to upload my sketch into my Arduino. I was able to fix it with this command:

```
sudo chmod a+rw /dev/ttyACM0
```

### avrdude: stk500_recv(): programmer is not responding

This error means that there is some problem communicating with the Arduino board. To fix it, try disconnecting the USB cable and connecting it again. If that doesn't work, using a different cable might help.

## Conclusion

In this article we learned how to use the Arduino IDE to write a program, upload it to our board and have the board run it.
