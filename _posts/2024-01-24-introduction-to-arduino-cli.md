---
title: Introduction to Arduino CLI
author: adrian.ancona
layout: post
date: 2024-01-24
permalink: /2023/12/introduction-to-arduino-cli
tags:
  - arduino
  - electronics
  - programming
---

In my previous post, [Getting Started With Arduino UNO R4](https://ncona.com/2024/01/getting-started-with-arduino-uno-r4), I showed how we can upload a sketch into an Arduino board. In this article, we are going to do the same, but this time using the Arduino CLI.

## Why Arduino CLI?

I personally, use neovim for coding, which makes it a necessity for me to be able to compile and upload my code from my terminal.

If you prefer the IDE, this article might not be for you, but, understanding the CLI could be useful in the future to automate repetitive tasks or run things in a CI environment.

## Installation

We can install the Arduino CLI on our system with these command:

```bash
# Create a folder to install the CLI
mkdir ~/bin/arduino-cli

# Move to the folder we created
cd ~/bin/arduino-cli

# Install
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
```

<!--more-->

Then we need to add `arduino-cli` to our path. We can do this by adding this line to our `~/.bashrc` file:

```bash
export PATH="$PATH:/home/myself/bin/arduino-cli/bin"
```

And sourcing `~/.bashrc`:

```bash
. ~/.bashrc
```

If everything goes well, the following command will print the installed version:

```bash
arduino-cli version
```

## Creating a Sketch

We can create a sketch with this command:

```bash
arduino-cli sketch new NconaSketch
```

A new folder named `NconaSketch` will be created with a file `NconaSketch.ino` inside. The file will have this content:

```cpp
void setup() {
}

void loop() {
}
```

Let's replace the content with the code from my previous article:

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

## Uploading a sketch

Connect the board and use this command to verify it's recognized:

```bash
arduino-cli board list
```

The output looks like this for me:

```bash
Port         Protocol Type              Board Name          FQBN                          Core
/dev/ttyACM0 serial   Serial Port (USB) Arduino UNO R4 WiFi arduino:renesas_uno:unor4wifi arduino:renesas_uno
```

The part we care about is `arduino:renesas_uno`, which serves as the identifier for the board type. We can check if that board is installed by listing all the installed types:

```bash
arduino-cli board listall
```

If the board is not included in the output we can install it with this command:

```bash
arduino-cli core install arduino:renesas_uno
```

To compile the sketch, we can use this command:

```bash
arduino-cli compile --fqbn arduino:renesas_uno:unor4wifi NconaSketch
```

To upload it to the board:

```bash
arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:renesas_uno:unor4wifi NconaSketch
```

## Conclusion

In this article we learned how to compile and install a sketch without using the IDE. Using the CLI is useful for people that prefer to work from a terminal or for environments where a GUI is not available (like most CI environments).
