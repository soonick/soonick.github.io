---
title: Modularizing ESP32 Software
author: adrian.ancona
layout: post
# date: 2024-04-10
# permalink: /2024/04/asynchronous-programming-with-tokio/
tags:
  - c++
  - esp32
  - programming
---

In my ESP32 journey, I've come to a point, where I want to be able to split my code into libraries and consume third-party libraries. In this article, I'm going to explore how to do this.

## The project directory tree

ESP32 projects follow a folder structure:

```
project/
├─ components/
│  ├─ component1/
│  │  ├─ CMakeLists.txt
│  │  ├─ ...
│  ├─ component2/
│     ├─ CMakeLists.txt
│     ├─ ...
├─ main/
│  ├─ CMakeLists.txt
│  ├─ ...
├─ CMakeLists.txt
```

<!--more-->

The top level directory must contain a `CMakeLists.txt` file and should contain at least these lines:

```cmake
cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(project-name)
```

The `main` directory contains the main executable for the project. This will typically include your `app_main`. The `CMakeLists.txt` file in this folder must call `idf_component_register`:

```cmake
idf_component_register(SRCS "main.cpp"
                       INCLUDE_DIRS ".")
```

All folders inside the `components` directory will be automatically included in the project. They must also have a `CMakeLists.txt` file that calls `idf_component_register`, similar to the one on the `main` folder.

## Declaring dependencies

We already mentioned that we need to use `idf_component_register` to declare a component. In this function, we can also specify the dependencies of a component:

```cmake
idf_component_register(SRCS "main.cpp"
                       INCLUDE_DIRS "."
                       REQUIRES greeter
                       PRIV_REQUIRES printer)
```

- REQUIRES should be set to all components whose header files are #included from the public header files of this component
- PRIV_REQUIRES should be set to all components whose header files are #included from any source files in this component, unless already listed in REQUIRES

## Building a project

We are going to use a contrived example that shows the usage of both `REQUIRES` and `PRIV_REQUIRES`

Let's start with our folder structure:

```
project/
├── CMakeLists.txt
├── components/
│   ├── animal/
│   │   ├── animal.cpp
│   │   ├── CMakeLists.txt
│   │   └── include/
│   │       └── animal.hpp
│   ├── mylogger/
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   └── mylogger.hpp
│   │   └── mylogger.cpp
│   └── numbers/
│       ├── CMakeLists.txt
│       ├── include/
│       │   └── numbers.hpp
│       └── numbers.cpp
└── main/
    ├── CMakeLists.txt
    └── main.cpp
```

Our `mylogger` and `numbers` components won't have any dependencies (except for ESP-IDF libraries), so let's look at these first.

`mylogger` exposes a single `log` function.

`project/components/mylogger/include/mylogger.hpp`:

```cpp
#pragma once

void log(const char* in);
```

`project/components/mylogger/mylogger.cpp`:

```cpp
#include "mylogger.hpp"

#include "esp_log.h"

void log(const char* in) {
  esp_log_write(ESP_LOG_INFO, "ignored", "%s: %s\n", "tag", in);
}
```

`project/components/mylogger/CMakeLists.txt`:

```cmake
idf_component_register(SRCS "mylogger.cpp"
                       INCLUDE_DIRS "include")
```

`numbers` exposes an enum with some numbers:

`project/components/numbers/include/numbers.hpp`:

```cpp
#pragma once

enum number
{
  ZERO = 0,
  ONE = 1,
  TWO = 2,
  THREE = 3,
  FOUR = 4,
  FIVE= 5,
};

int one();
```

`project/components/numbers/numbers.cpp`:

```cpp
#include "numbers.hpp"

int one() {
  return 1;
}
```

`project/components/numbers/CMakeLists.txt`:

```cmake
idf_component_register(SRCS "numbers.cpp"
                       INCLUDE_DIRS "include")
```

The `animal` component depends on both `number` and `mylogger`, but `mylogger` is only required for the implementation.

`project/components/animal/include/animal.hpp`:

```cpp
#pragma once

#include "numbers.hpp"

class Animal {
  private:
   number legs;

  public:
   Animal(number legs);
   void talk();
};
```

`project/components/animal/animal.cpp`:

```cpp
#include "animal.hpp"

#include "mylogger.hpp"

Animal::Animal(number legs) {
  this->legs = legs;
}

void Animal::talk() {
  log("hello");
}
```

`project/components/animal/CMakeLists.txt`:

```
idf_component_register(SRCS "animal.cpp"
                       INCLUDE_DIRS "include"
                       REQUIRES numbers
                       PRIV_REQUIRES mylogger)
```

Above, we can see that `mylogger` uses `PRIV_REQUIRES` because it's not used in the public header file.

Finally, we can write an `app_main` that uses `animal` so we can test it in an actual ESP32:

`project/main/main.cpp`:

```cpp
#include "esp_log.h"
#include "freertos/FreeRTOS.h"

#include "animal.hpp"

extern "C" void app_main() {
  while (true) {
    Animal dog = Animal(number::ONE);
    dog.talk();
  }
}
```

`project/main/CMakeLists.txt`:

```
idf_component_register(SRCS "main.cpp"
                       INCLUDE_DIRS "."
                       PRIV_REQUIRES animal)
```

## Conclusion

ESP-IDF provides a very easy way to use and create libraries, and [the documentation does a very good job at explaining how this works](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html).

As usual, you can find an easy to run version of this code at [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/modularizing-esp32-software).
