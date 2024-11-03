---
title: Handling Interrupts With ESP-IDF
author: adrian.ancona
layout: post
date: 2024-11-13
permalink: /2024/11/handling-interrupts-with-esp-idf/
tags:
  - esp32
  - programming
---

## Interrupts

Interrupts are a way to achieve [concurrency](https://ncona.com/2022/01/concurrency-in-computer-systems) when working with microcontrollers.

An interrupt allows us to "interrupt" the current execution of a program in order to do a different task. This is usually achieved by instructing the microcontroller to look for level changes (From high to low or from low to high) on a GPIO pin and executing a function when that happens.

## Interrupt Service Routines (ISR)

ISRs are callback functions that are executed when an interrupt is triggered. They should be made very fast and simple, because they block the execution of other parts of the system.

They are special in that they can't block execution waiting for a lock and then resume when the lock is available. If we try to hold a mutex within an ISR, the program will crash. For this reason, many ESP-IDF functions (e.g. `ESP_LOG` functions) can't be used inside an ISR.

<!--more-->

## [Queues](https://www.freertos.org/Documentation/02-Kernel/02-Kernel-features/02-Queues-mutexes-and-semaphores/01-Queues)

Due to all restrictions on ISRs, it's common for ISRs to simply put a message in a queue and let another task take care of processing the message.

We can create a queue like this:

```cpp
static QueueHandle_t queue;

extern "C" void app_main() {
  queue = xQueueCreate(10, sizeof(char));
}
```

In this case, we are creating a queue that can hold up to `10` variables of type `char`.

We can then have a task that processes messages from the queue:

```cpp
void queue_task(void *params) {
  char c;
  while (true) {
    if (xQueueReceive(queue, &c, portMAX_DELAY)) {
      // In this scenario we are ignoring `c` and just logging a message. We
      // could do anything here
      ESP_LOGI(TAG, "Interrupt triggered");
    }
  }
}

extern "C" void app_main() {
  ...

  xTaskCreate(queue_task, "queue_task", 2048, NULL, 10, NULL);

  ...
}
```

## Configuring interrupts

To configure an interrupt, we need to know which pin will listen for interrupts, and when we want interrupts to trigger: rising, falling, or both.

```cpp
#define INTERRUPT_PIN GPIO_NUM_19

static void interrupt_handler(void *args) {
  char c = 1;
  xQueueSendFromISR(queue, &c, nullptr);
}

extern "C" void app_main() {
  ...

  gpio_config_t interrupt_config = {
    .pin_bit_mask = 1ULL << INTERRUPT_PIN,
    .mode = GPIO_MODE_INPUT,
    .pull_up_en = GPIO_PULLUP_ENABLE,
    .pull_down_en = GPIO_PULLDOWN_DISABLE,
    .intr_type = GPIO_INTR_ANYEDGE,
  };
  gpio_config(&interrupt_config);

  gpio_install_isr_service(0);
  gpio_isr_handler_add(INTERRUPT_PIN, interrupt_handler, nullptr);

  ...
}
```

The code above, configures pin `19` to trigger `interrupt_handler`, every time it notices a level change (GPIO_INTR_ANYEDGE).

## Conclusion

The trickiest part of interrupts is the restrictions inside the ISRs. Luckily, most of the problems around that can be mitigated by using a queue. Experimentation and memory constraints will need to be taken into account when choosing the size of the queue.

As usual, you can find a full working example in [my examples' repo](https://github.com/soonick/ncona-code-samples/tree/master/handling-interrupts-with-esp-idf).
