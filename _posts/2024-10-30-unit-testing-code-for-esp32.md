---
title: Unit Testing Code for ESP32
author: adrian.ancona
layout: post
date: 2024-10-30
permalink: /2024/10/unit-testing-code-for-esp32/
tags:
  - esp32
  - programming
  - testing
---

In my previous article, we learned how to [build a stand-alone library for esp-idf](/2024/10/building-a-stand-alone-library-for-esp-idf/). In this article we are going to learn how to write unit tests for our code so we can have confidence it does what we want it to do.

There are a few ways we can go about unit testing code written for ESP32:

- Run tests directly on ESP32 board
- Run tests using an emulator
- Run tests on Linux host using mocks

We are going to learn how to write tests that can run on a Linux host, so it's easy to plug them to a CI system.

<!--more-->

## Testing framework

Since we are going to be running tests in a Linux host, we will need a whole different build for our test. We will use this folder structure:

```
library-root/
├── CMakeLists.txt
├── example
│   └── ...
├── include
│   └── ...
├── src
│   └── ...
└── test
    └── ...
```

We are going to use [Catch2](https://github.com/catchorg/Catch2) to run our unit tests because we just need to download a single file from Github. Copy the contents of [catch.hpp](https://github.com/catchorg/Catch2/blob/v2.x/single_include/catch2/catch.hpp) into `library-root/test/external/catch2/catch.hpp`.

We can create `library-root/test/CMakeLists.txt` to run our tests:

```cpp
cmake_minimum_required(VERSION 3.27.4)
project(LibraryTest
  VERSION 0.1.0
  LANGUAGES CXX)

include_directories(external/catch2)

set(TEST_TARGET_SRCS
  src/test-main.cpp
)

add_compile_options(-Wall -Wextra -Wpedantic -Werror)

add_executable(
  test
  ${TEST_TARGET_SRCS}
)
```

Notice that this file references `src/test-main.cpp`, so let's create it:

```cpp
#define CATCH_CONFIG_MAIN
#include <catch.hpp>

TEST_CASE("sample") {
  SECTION("test") {
    REQUIRE(1 == 1);
  }
}
```

We can verify that the test build is correctly configured like so:

```bash
mkdir -p library-root/test/build
cd library-root/test/build
cmake ..
make
./test
```

We should see a message similar to this one:

```
===============================================================================
All tests passed (1 assertion in 1 test case)
```

## Writing tests

Let's say we want to build a function that can parse a query string into a map.

First, we need `library-root/test/CMakeLists.txt` to include our files under test:

```cmake
cmake_minimum_required(VERSION 3.27.4)
project(LibraryTest
  VERSION 0.1.0
  LANGUAGES CXX)

include_directories(external/catch2)
include_directories(../include)

set(TESTING_SRCS
  ../src/library.cpp
)

set(TEST_TARGET_SRCS
  src/test-main.cpp
)

add_compile_options(-Wall -Wextra -Wpedantic -Werror)

add_executable(
  test
  ${TEST_TARGET_SRCS}
  ${TESTING_SRCS}
)
```

Here is an example test of the desired functionality:

```cpp
#define CATCH_CONFIG_MAIN
#include <catch.hpp>

TEST_CASE("parseQueryString") {
  SECTION("Multiple key values") {
    std::unordered_map<std::string, std::string> actual =
        parse_query_string("hello?abc=1&qwer=world&onemore=yesyes");
    REQUIRE(actual.size() == 3);
    REQUIRE(actual.at("abc") == "1");
    REQUIRE(actual.at("qwer") == "world");
    REQUIRE(actual.at("onemore") == "yesyes");
  }
}
```

If we compile and run our tests now, we will get an error, because we haven't defined `parse_query_string`:

```
/library-root/test/src/test-main.cpp: In function 'void C_A_T_C_H_T_E_S_T_0()':
/library-root/test/src/test-main.cpp:7:9: error: 'parse_query_string' was not declared in this scope
    7 |         parse_query_string("hello?abc=1&qwer=world&onemore=yesyes");
      |         ^~~~~~~~~~~~~~~~~~
```

We need to write our implementation. Let's start with `library-root/include/library.hpp`:

```cpp
#pragma once

#include <unordered_map>
#include <string>

std::unordered_map<std::string, std::string> parse_query_string(const std::string&);
```

Then, we have `library-root/src/library.cpp`:

```cpp
#include "library.hpp"

#include <iostream>

void replace(std::string &in, const char f, const char r) {
  for (long unsigned int i = 0; i < in.length(); i++) {
    if (in[i] == f) {
      in[i] = r;
    }
  }
}

std::unordered_map<std::string, std::string>
parse_query_string(const std::string &line) {
  std::unordered_map<std::string, std::string> dictionary;

  int start = line.find_first_of("?") + 1;
  int end = line.find_first_of(" ", start);
  std::string query_string = line.substr(start, end);
  replace(query_string, '+', ' ');

  long unsigned int current_start = 0;
  while (current_start < query_string.length()) {
    int current_end = query_string.find_first_of("&", current_start);
    if (current_end == -1) {
      current_end = query_string.length();
    }

    std::string current_pair =
        query_string.substr(current_start, current_end - current_start);
    int equalPos = current_pair.find_first_of("=");
    if (equalPos != -1) {
      // If there is no equal sign, we skip adding it to the result
      std::string key = current_pair.substr(0, equalPos);
      std::string value =
          current_pair.substr(equalPos + 1, current_pair.length());
      dictionary[key] = value;
    }

    current_start = current_end + 1;
  }

  return dictionary;
}
```

At this point, our library doesn't use any esp-idf specific functionality, but it can be used by esp-idf projects, and we already wrote a test for it.

## Mocking esp-idf

When our code depends on esp-idf, we will need to mock the functionality in order to test it.

Let's say we have this code in `library-root/src/library.hpp`:

```cpp
#pragma once

#include <esp_err.h>

esp_err_t event_loop();
```

And this in `library-root/src/library.cpp`:

```cpp
#include "library.hpp"

#include <esp_event.h>

esp_err_t event_loop() {
  return esp_event_loop_create_default();
}
```

We have introduced 2 ESP-IDF dependencies: `esp_err.h` and `esp_event.h`. To be able to write tests for this code, we will need to mock those dependencies.

We'll start by creating `library-root/test/mock/` folder. This will be the place where we'll add our mocks. We have the freedom to make our mocks do whatever we desire.

For this example, we'll keep them very simple.

library-root/test/mock/esp_err.h:

```cpp
#pragma once

#define ESP_OK 0

typedef int esp_err_t;
```

library-root/test/mock/esp_event.h:

```cpp
#pragma once

#include "esp_err.h"

esp_err_t esp_event_loop_create_default();
```

library-root/test/mock/esp_event.cpp:

```cpp
#include "esp_event.h"

esp_err_t esp_event_loop_create_default() {
  return ESP_OK;
}
```

We also need to update `library-root/test/CMakeLists.txt`, so it knows where to find the mocks:

```cpp
cmake_minimum_required(VERSION 3.27.4)
project(LibraryTest
  VERSION 0.1.0
  LANGUAGES CXX)

include_directories(external/catch2)
include_directories(../include)
include_directories(mock)

FILE(GLOB MOCK_SRCS mock/*.cpp)

set(TESTING_SRCS
  ../src/library.cpp
)

set(TEST_TARGET_SRCS
  src/test-main.cpp
)

add_compile_options(-Wall -Wextra -Wpedantic -Werror)

add_executable(
  test
  ${MOCK_SRCS}
  ${TEST_TARGET_SRCS}
  ${TESTING_SRCS}
)
```

Now, we can write a test:

```cpp
#define CATCH_CONFIG_MAIN
#include <catch.hpp>

#include "library.hpp"

TEST_CASE("event_loop") {
  SECTION("Returns ESP_OK") {
    REQUIRE(event_loop() == ESP_OK);
  }
}
```

## Conclusion

Writing tests for ESP-IDF is not very complicated once we know what to do. The biggest hurdle is probably writing the tests, which, depending on the amount of dependencies, might be a lot of work.

As usual, you can find a working example in [my examples' repo](https://github.com/soonick/ncona-code-samples/tree/master/unit-testing-code-for-esp32).
