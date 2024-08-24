---
title: ESP32 Non-Volatile Storage (NVS)
author: adrian.ancona
layout: post
# date: 2024-09-04
# permalink: /2024/09/esp32-non-volatile-storage-nvs/
tags:
  - c++
  - esp32
  - programming
---

In this article, we are going to learn how to use NVS to store key-value pairs that persist even if our board is restarted.

## What is NVS

NVS stands for Non-Volatile Storage. It's a library that allows us to store key-value pairs in flash memory.

ESP-IDF projects partition the boards flash into different sections. Among these partitions, there is one where our application code lives and there is another section we can use to store any data we want. This section is called the `data` partition, and that's what NVS uses for storage.

## Flash models

Different development boards might come with different models of flash memory. I bought a cheap development board from my local electronics shop, and it didn't include much information about the specs, so I didn't really know what flash it uses.

Luckily, ESP-IDF comes with a tool we can use to get information about our flash memory:

```bash
esptool.py --port /dev/ttyUSB0 flash_id
```

The output for my board included this:

```
Manufacturer: 5e
Device: 4016
Detected flash size: 4MB
```

<!--more-->

Which tells us the flash memory model is `5e 4016`, and it has `4MB` of storage.

## Data types

Keys are ASCII strings with a maximum length of 15 characters. Values can be `int` or `uint` from `8` to `64` bits (e.g. `int32_t`), 0 terminated strings, or blob.

## Cyclic Redundancy Checks

The NVS library automatically performs CRCs for us, so we don't need to do it ourselves.

## Initializing NVS

Before we can use NVS, we need to call `nvs_flash_init()`.

```cpp
esp_err_t err = nvs_flash_init();
if (err == ESP_ERR_NVS_NO_FREE_PAGES ||
    err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
  ESP_ERROR_CHECK(nvs_flash_erase());
  err = nvs_flash_init();
}
ESP_ERROR_CHECK(err);
```

It's possible that the first time we call `nvs_flash_init()`, it returns an error. In this case, it's common to want to erase all data in NVS and try to initialize it again.

## NVS handle

In order to perform operations on NVS, we need to first create a handle:

```cpp
std::unique_ptr<nvs::NVSHandle> handle =
    nvs::open_nvs_handle("my_namespace", NVS_READWRITE, &err);
ESP_ERROR_CHECK(err);
```

The first argument to `open_nvs_handle` is a namespace we want this handle to use.

In C++ it's recommended to wrap the handle in `std::unique_ptr` so it's automatically deleted when it goes out of scope.

## Working with integers

To get an integer from NVS, we use `get_item`, to write, we use `set_item`. Here is an example:

```cpp
uint32_t my_value = 0;
err = handle->get_item("my_key", my_value);
switch (err) {
case ESP_OK:
  ESP_LOGI(TAG, "value for my_key is: %" PRIu32, my_value);
  break;
case ESP_ERR_NVS_NOT_FOUND:
  ESP_LOGI(TAG, "Key my_key doesn't exist in NVS");
  break;
default:
  ESP_ERROR_CHECK(err);
}

my_value++;
err = handle->set_item("my_key", my_value);
ESP_ERROR_CHECK(err);
err = handle->commit();
ESP_ERROR_CHECK(err);
ESP_LOGI(TAG, "Value written to NVS");
```

Notice how `get_item` will return `ESP_ERR_NVS_NOT_FOUND` if the requested key has never been written. When writing data, keep in mind that it won't be saved until `commit()` is called.

## Working with strings

When working with strings, we can use `get_string` and `set_string`.

Getting a string is a little trickier than getting an int, because the length of strings can vary. We need to start by creating a buffer that will receive the string:

```cpp
std::unique_ptr<char[]> my_string = std::make_unique<char[]>(100);
```

When we call `get_string` we need to specify the size of the buffer:

```cpp
err = handle->get_string("my_string_key", my_string.get(), 100);
```

The rest is pretty much the same:

```cpp
std::unique_ptr<char[]> my_string = std::make_unique<char[]>(100);
err = handle->get_string("my_string_key", my_string.get(), 100);
switch (err) {
case ESP_OK:
  ESP_LOGI(TAG, "Value for my_string_key is: %s", my_string.get());
  break;
case ESP_ERR_NVS_NOT_FOUND:
  ESP_LOGI(TAG, "Key my_string_key doesn't exist in NVS");
  break;
default:
  ESP_ERROR_CHECK(err);
}

const char *new_string = "Hello world";
err = handle->set_string("my_string_key", new_string);
ESP_ERROR_CHECK(err);
err = handle->commit();
ESP_ERROR_CHECK(err);
ESP_LOGI(TAG, "String written to NVS");
```

## Conclusion

I found The NVS API makes it very easy to read and write data that survives restarts, even easier than Arduino's API.

As usual, you can find working examples in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/esp32-non-volatile-storage-nvs).
