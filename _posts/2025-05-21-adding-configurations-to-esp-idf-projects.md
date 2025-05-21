---
title: Adding Configurations to ESP-IDF projects
author: adrian.ancona
layout: post
date: 2025-05-21
permalink: /2025/05/adding-configurations-to-esp-idf-projects/
tags:
  - c++
  - programming
  - esp32
---

In this article, we are going to learn how to write software that uses configuration files using [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/index.html).

## [Kconfig](https://docs.kernel.org/kbuild/kconfig-language.html)

[Kconfig](https://docs.kernel.org/kbuild/kconfig-language.html) is the configuration system used by the Linux kernel and by ESP-IDF. It allows management of project settings through a structured and hierarchical menu system.

It allows developers to write configuration files that specify the available configuration options for a piece of software. 

<!--more-->

## sdkconfig

When an ESP-IDF project is built, a file named `sdkconfig` is automatically generated. This file contains configurations used by the framework, as well as user defined configurations.

Here is a snippet of an `sdkconfig` file to give an idea of the format:

```ini
...
CONFIG_IDF_TARGET_ARCH_XTENSA=y
CONFIG_IDF_TARGET_ARCH="xtensa"
CONFIG_IDF_TARGET="esp32"
CONFIG_IDF_INIT_VERSION="5.2.2"
CONFIG_IDF_TARGET_ESP32=y
...
```

These configurations are automatically made globally available throughout the project. Most of them are used by ESP-IDF, but all configurations are globally available.

For example, the following code prints the value of the `CONFIG_IDF_TARGET_ARCH` configuration:

```cpp
#include "esp_log.h"
#include "freertos/FreeRTOS.h"

static const char *TAG = "project";

void app_main(void) {
  while (1) {
    ESP_LOGI(TAG, "Architecture: %s!", CONFIG_IDF_TARGET_ARCH);
    vTaskDelay(3000 / portTICK_PERIOD_MS); // Print every 3 seconds
  }
}
```

To update a configuration value, we can use:

```bash
idf.py menuconfig
```

This will open the config editor:

[<img src="/images/posts/esp-idf-menuconfig.png" alt="ESP-IDF menuconfig" />](/images/posts/esp-idf-menuconfig.png)

Let's modify a configuration to see the change take effect. Use the arrow keys to navigate to `Component config` and press `Enter`:

[<img src="/images/posts/esp-idf-component-config.png" alt="ESP-IDF menuconfig - component config" />](/images/posts/esp-idf-component-config.png)

Navigate to `Bluetooth` and press `Enter`:

[<img src="/images/posts/esp-idf-bluetooth-config.png" alt="ESP-IDF menuconfig - bluetooth config" />](/images/posts/esp-idf-bluetooth-config.png)

Toggle the `Bluetooth` option and press `S` to save the configuration:

[<img src="/images/posts/esp-idf-activate-bluetooth.png" alt="ESP-IDF menuconfig - bluetooth activated" />](/images/posts/esp-idf-activate-bluetooth.png)

Use the `Q` key to quit menuconfig.

If we inspect our `sdkconfig` file, we will see that a new configuration was added:

```ini
CONFIG_BT_ENABLED=y
```

Some configurations (`CONFIG_BT_ENABLED` is an example) are only present when they are enabled. i.e. `CONFIG_BT_ENABLED` is either `y` or not present at all. This means, we can't write code like this:

```cpp
if (CONFIG_BT_ENABLED) {
  ...
} else {
  ...
}
```

Because the variable `CONFIG_BT_ENABLED` would be undefined if it's not in the configuration. If we want to do something based on the existence of a configuration, we can use the preprocessor:

```cpp
#ifdef CONFIG_BT_ENABLED
  ESP_LOGI(TAG, "BT enabled: %i", CONFIG_BT_ENABLED);
#else
  ESP_LOGI(TAG, "BT enabled: 0");
#endif
```

## Custom configurations

To add custom configurations to our project, we need to first define the configuration. We can do this in the file `main/Kconfig.projbuild`.

Here is a simple example with a single definition:

```python
menu "Project config"
config PERSON_NAME
        string "Person Name"
        default "Jose"
        help
            The code will greet this person
endmenu
```

This will add a new top-level section to our menuconfig:

[<img src="/images/posts/esp-idf-top-level-config.png" alt="ESP-IDF menuconfig - new top level" />](/images/posts/esp-idf-top-level-config.png)

Inside that section we will see our new configuration:

[<img src="/images/posts/esp-idf-new-configuration.png" alt="ESP-IDF menuconfig - new configuration" />](/images/posts/esp-idf-new-configuration.png)

## Override defaults

We can use menuconfig to set configuration values, but I find it easier to edit files manually. The `sdkconfig` file is generated automatically, so it shouldn't be modified by hand. Instead, we can create a file named `sdkconfig.defaults` where we can set our desired configuration values.

To set a value for `PERSON_NAME`, we can use this content:

```ini
CONFIG_PERSON_NAME="Adrian"
```

Next time the project is compiled, `sdkconfig` will be regenerated using this value.

## Conclusion

[The project configuration documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/kconfig.html) for ESP-IDF is extensive, but doesn't do a great job at showing how to quickly get things working. This article is a simple step-by-step guide to get you started.

As usual, you can find a full working example in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/adding-configurations-to-esp-idf-projects).
