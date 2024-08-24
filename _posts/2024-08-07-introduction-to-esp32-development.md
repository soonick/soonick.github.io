---
title: Introduction to ESP32 development
author: adrian.ancona
layout: post
date: 2024-08-07
permalink: /2024/08/introduction-to-esp32-development/
tags:
  - arduino
  - c++
  - esp32
  - programming
  - electronics
---

A few months ago, I started learning [Arduino](/tag/arduino/), and recently I finished my first small project. After finishing the project, I was wondering if I could build the same thing for cheaper, and that's when I stumbled into ESP32.

[ESP32](https://en.wikipedia.org/wiki/ESP32) is an MCU (Micro Controller Unit) that got very popular because it has integrated WiFi, Bluetooth, very good documentation and is relatively cheap for what it does. Interestingly, the [Arduino UNO R4 WiFi](https://docs.arduino.cc/hardware/uno-r4-wifi/) contains two MCU and one of them is an ESP32.

## Getting an ESP32

The easiest way to get started with ESP32 is to buy a [development board](https://www.espressif.com/en/products/devkits). While you can find some in Espressif's website (The manufacturer of ESP32), you can also get clones from many places around the world.

I'm currently in Cape Town, so got [mine](https://www.communica.co.za/products/hkd-esp-32-wifi-b-t-dev-board) from [Communica](https://www.communica.co.za/). I ended up paying $7.50 USD for it. Depending on where you live and how long you are willing to wait to get one, you might be able to get it for considerably cheaper.

[<img src="/images/posts/esp32-dev-board.jpg" alt="ESP32 dev board" />](/images/posts/esp32-dev-board.png)

<!--more-->

## Espressif IoT Development Framework (ESP-IDF)

To develop software for ESP32, we need ESP-IDF. The [official documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html) is the best place to find the most up-to-date installation instructions. At the time of this writing, these are the steps I followed.

Install dependencies:

```
sudo apt-get install git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0
```

Clone the repo:

```
git clone -b v5.3 --recursive https://github.com/espressif/esp-idf.git
```

Install tools used by ESP32 (Compiler, debugger, etc):

```
./install.sh esp32
```

## Hello World

ESP-IDF uses an Operating System based on [FreeRTOS](https://www.freertos.org/). We don't need to know much about the OS for getting started, other than our entry point will be `void app_main(void)`. A minimum runnable program looks like this:

```cpp
#include "esp_log.h"

void app_main(void) {
  ESP_LOGI("test", "Hello World!");
}
```

This program will print `Hello World!` to the serial monitor and then exit.

Note that we make use of [ESP-IDF logging library](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/log.html) to print the message.

When writing firmware we usually want our program to execute continuously. We can achieve this with a simple loop:

```cpp
#include "esp_log.h"

void app_main(void) {
  while (1) {
    ESP_LOGI("test", "Hello World!");
  }
}
```

This program will print `Hello World!` to the serial monitor forever.

# Blinking an LED

Some development boards (like the one I bought) include a built-in LED connected to pin 2. We can turn that LED on and off using this code:

```cpp
#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"

static const char *TAG = "blink";

#define BLINK_GPIO GPIO_NUM_2

static uint8_t s_led_state = 0;

void app_main(void) {
  gpio_reset_pin(BLINK_GPIO);
  gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);

  while (1) {
    ESP_LOGI(TAG, "Turning the LED %s!", s_led_state == true ? "ON" : "OFF");
    gpio_set_level(BLINK_GPIO, s_led_state);
    s_led_state = !s_led_state;
    vTaskDelay(3000 / portTICK_PERIOD_MS); // Blink every 3 seconds
  }
}
```

Let's go over what the program does.

```cpp
static const char *TAG = "blink";
```

Here we are simply creating a tag that will be used in our logs.

```cpp
#define BLINK_GPIO GPIO_NUM_2
```

We define a friendly name for pin 2 (`GPIO_NUM_2`). `GPIO_NUM_2` is defined in `driver/gpio.h`, so we need to include that header.

```cpp
static uint8_t s_led_state = 0;
```

We are going to be toggling the LED on and OFF. We use this variable to save the current state of the LED. `1` means on, `0` means off.

```cpp
gpio_reset_pin(BLINK_GPIO);
gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);
```

These functions are also defined in `driver/gpio.h`. `gpio_reset_pin` simply resets any previously set configuration on that pin to their default value. `gpio_set_direction` is used to configure the pin to be in output mode.

```cpp
ESP_LOGI(TAG, "Turning the LED %s!", s_led_state == true ? "ON" : "OFF");
```

Log a message to the serial monitor indicating if we are turning the LED on or off.

```cpp
gpio_set_level(BLINK_GPIO, s_led_state);
```

Another function coming from `driver/gpio.h`. Here, we set the output of `BLINK_GPIO` to the value of `s_led_state`. `0` means low (off), `1` means high (on).

```cpp
s_led_state = !s_led_state;
```

Toggles the value so in the next run the state of the LED is reversed.

```cpp
vTaskDelay(3000 / portTICK_PERIOD_MS); // Blink every 3 seconds
```

`vTaskDelay` is defined in `freertos/FreeRTOS.h`. This function works similar to `delay` in Arduino or `sleep` in other languages. The difference is that the value it takes as an argument is the number of ticks it will wait. To delay for a specified number of seconds, we can use a constant like `portTICK_PERIOD_MS` (also defined in `freertos/FreeRTOS.h`), which we can use to translate ticks to milliseconds.

## Building and flashing

ESP-IDF suggests CMake as build system. Let's start by creating the folders and files we need for our project.

```bash
mkdir ~/blink
touch ~/blink/CMakeLists.txt
mkdir ~/blink/main
touch ~/blink/main/CMakeLists.txt
touch ~/blink/main/main.c
```

Add the following content to `~/blink/CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.16)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(blink)
```

Add the following content to `~/blink/main/CMakeLists.txt`:

```cmake
idf_component_register(SRCS "main.c"
                       INCLUDE_DIRS ".")
```

Add the code for blinking an LED to `~/blink/main/main.c`.

With those files in place, it's time to see our code in action.

Before we can compile our code, we need to start a `virtual environment`. To do this we need to run (replace `path-to-esp-idf` with the path of your esp-idf folder):

```bash
. /path-to-esp-idf/export.sh
```

Then we need to configure our target chip:

```bash
idf.py set-target esp32
```

We can now compile our code:

```bash
idf.py build
```

To flash (upload) the code to our dev board:

```bash
idf.py -p /dev/ttyUSB0 flash
```

Notice that my device is connected to `/dev/ttyUSB0`, your device might appear in a different port.

We can inspect the serial monitor with this command:

```bash
idf.py -p /dev/ttyUSB0 monitor
```

## Errors flashing device

I often encounter errors flashing my code to my board. I have found that the following commands solve the issue for me:

```bash
sudo adduser $USER dialout
sudo chmod a+rw /dev/ttyUSB0
```

## Conclusion

Although getting started with ESP32 was slightly harder than getting started with Arduino, I feel that the difference wasn't very large.

I find Espressif's official documentation to be better structured, clearer and more thorough than Arduino's. I also love the fact that it uses CMake by default, which makes it easier to integrate into my preferred editor (Neovim).

I expect to encounter some non-trivial difficulties migrating my code from Arduino to ESP32, but so far, the experience has been mostly satisfactory.

As usual, you can find a working example in my [examples repo](https://github.com/soonick/ncona-code-samples/tree/master/introduction-to-esp32-development).
