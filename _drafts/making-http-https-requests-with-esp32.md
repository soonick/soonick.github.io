---
title: Making HTTP / HTTPS requests with ESP32
author: adrian.ancona
layout: post
# date: 2024-08-28
# permalink: /2024/09/making-http-https-requests-with-esp32/
tags:
  - c++
  - esp32
  - programming
---

I have in the past written an article explaining how to [send HTTP requests with Arduino](https://ncona.com/2024/02/sending-http-requests-with-arduino). This time we're going to learn how to do it using ESP-IDF.

This article is the result of my learnings from analyzing the [official ESP HTTP client example](https://github.com/espressif/esp-idf/blob/master/examples/protocols/esp_http_client/main/esp_http_client_example.c).

## [ESP-NETIF](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_netif.html)

ESP-NETIF is ESP32's abstraction for TCP/IP. It's not too complicated to use, but it's somewhat verbose. All applications that use it need to start by calling:

```cpp
esp_netif_init();
```

This function should be called only once, when the application starts.

<!--more-->

## [Event Loop Library](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/esp_event.html)

ESP-NETIF uses events heavily, so let's understand a little about them.

An `event` can be anything that happened, and we want to be notified about. To get notifications about `events` we attach `event handlers` to them. An `event loop` is the mechanism that takes care of executing `event handlers` when an `event` occurs.

An application can have multiple `event loops`, but, system events use the `default event loop`. This is where ESP-NETIF publishes events. The default event loop needs to be created manually, using:

```cpp
esp_event_loop_create_default();
```

This function should also be called only once, when the application starts.

## WiFi Configuration

A few steps are needed to configure our WiFi connection. The first one being, initializing the WiFi driver by calling `esp_wifi_init`. A minimal example looks like this:

```cpp
wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
cfg.nvs_enable = 0;
esp_wifi_init(&cfg);
```

Notice that we're using the default configuration except for `cfg.nvs_enable`, which we are setting to `0`. The reason we set this to `0` is because by default, WiFi settings are stored in non-volatile storage / NVS (flash memory). Since I want to keep my example code to minimal, I set it to `0` so I don't need to initialize NVS.

Next, we need to create a network interface in station mode (WiFi client, connecting to a WiFi network):

```cpp
esp_netif_inherent_config_t esp_netif_config =
  ESP_NETIF_INHERENT_DEFAULT_WIFI_STA();
esp_netif_create_wifi(WIFI_IF_STA, &esp_netif_config);
```

After configuring our network interface, we need to register its handlers in the default event loop. This can be done with:

```cpp
esp_wifi_set_default_wifi_sta_handlers();
```

I'm not quite sure why this is required, but we need to explicitly set `WIFI_STORAGE_RAM` and `WIFI_MODE_STA` before we start the WiFi driver:

```cpp
esp_wifi_set_storage(WIFI_STORAGE_RAM);
esp_wifi_set_mode(WIFI_MODE_STA);
esp_wifi_start();
```

The last step on this stage is to connect to the network. For that, we need to create a `wifi_config_t` with our credentials and then call `esp_wifi_connect`:

```cpp
wifi_config_t wifi_config = {
  .sta =
      {
          .ssid = SSID,
          .password = PASSWORD,
      },
};
esp_wifi_set_config(WIFI_IF_STA, &wifi_config);
esp_wifi_connect();
```

Completing the connection might take some time, but events will be triggered to notify us about the progress.

## Making requests

Requests also rely on event handlers, so we need to create an event handler that takes care of all the possible events. A minimal handler looks something like this:

```cpp
esp_err_t http_event_handler(esp_http_client_event_t *evt) {
  static char *output_buffer;
  static int output_len;
  switch (evt->event_id) {
  case HTTP_EVENT_ERROR:
    ESP_LOGI(TAG, "HTTP_EVENT_ERROR");
    break;
  case HTTP_EVENT_ON_CONNECTED:
    ESP_LOGI(TAG, "HTTP_EVENT_ON_CONNECTED");
    break;
  case HTTP_EVENT_HEADER_SENT:
    ESP_LOGI(TAG, "HTTP_EVENT_HEADER_SENT");
    break;
  case HTTP_EVENT_ON_HEADER:
    ESP_LOGI(TAG, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key,
             evt->header_value);
    break;
  case HTTP_EVENT_ON_DATA: {
    ESP_LOGI(TAG, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
    int copy_len = 0;
    int content_len = esp_http_client_get_content_length(evt->client);
    if (output_buffer == NULL) {
      // We initialize output_buffer with 0 because it is used by strlen() and
      // similar functions therefore should be null terminated.
      output_buffer = (char *)calloc(content_len + 1, sizeof(char));
      output_len = 0;
      if (output_buffer == NULL) {
        ESP_LOGE(TAG, "Failed to allocate memory for output buffer");
        return ESP_FAIL;
      }
    }
    copy_len = MIN(evt->data_len, (content_len - output_len));
    if (copy_len) {
      memcpy(output_buffer + output_len, evt->data, copy_len);
    }
    output_len += copy_len;
    break;
  }
  case HTTP_EVENT_ON_FINISH:
    ESP_LOGI(TAG, "HTTP_EVENT_ON_FINISH");
    if (output_buffer != NULL) {
      ESP_LOGI(TAG, "%s", output_buffer);
      free(output_buffer);
      output_buffer = NULL;
    }
    output_len = 0;
    break;
  case HTTP_EVENT_DISCONNECTED:
    ESP_LOGI(TAG, "HTTP_EVENT_DISCONNECTED");
    if (output_buffer != NULL) {
      free(output_buffer);
      output_buffer = NULL;
    }
    output_len = 0;
    break;
  case HTTP_EVENT_REDIRECT:
    ESP_LOGI(TAG, "HTTP_EVENT_REDIRECT");
    break;
  }
  return ESP_OK;
}
```

It's a good practice to cover all the possible cases, so this example does so, even when some cases only log the fact that the event was triggered. For `HTTP_EVENT_ON_HEADER` we also log the headers themselves.

The most interesting event is `HTTP_EVENT_ON_DATA`. This event might be triggered multiple times while getting a response. In the example above, we grab the information in `evt->data` and copy it to a buffer. Later, when `HTTP_EVENT_ON_FINISH` is triggered, we print this buffer, which by then contains the body of the response.

Now that we have the handler, we can go ahead and make the request.

```cpp
esp_http_client_config_t config = {
  .url = "https://ncona.com/about-me/",
  .event_handler = http_event_handler,
  .crt_bundle_attach = esp_crt_bundle_attach,
};
esp_http_client_handle_t client = esp_http_client_init(&config);
esp_err_t err = esp_http_client_perform(client);
```

We use the `url` property to specify the URL we want to hit, and we pass our previously created event handler to the `event_handler` property.

Since we are hitting an HTTPS endpoint, we need to also set `crt_bundle_attach`. We use `esp_crt_bundle_attach` to CA certificates that come with ESP-IDF.

## Putting everything together

I have uploaded a [working example to Github](https://github.com/soonick/ncona-code-samples/blob/master/making-http-https-requests-with-esp32/minimal-https/main/main.cpp).

One important thing to mention is that I have made a few compromises to keep the amount of code in the example as low as possible. In the following sections, I'll go over some things we should consider if we want to make our code a little more usable for production.

## Error handling

Most of the ESP functions we used in previous sections return an error code if there was a problem, or `ESP_OK` if they succeeded. A lot of times, the success of a function is a requirement for the program to run correctly. For that reason, it's recommended to use `ESP_ERROR_CHECK` to halt the program if a command fails.

For example, we won't be able to make HTTP requests if `esp_netif_init` fails, so we should do this:

```cpp
ESP_ERROR_CHECK(esp_netif_init());
```

The same is true for the majority of the commands we used in this article.

It's also a good idea to check the status code returned by `esp_http_client_perform`:

```cpp
esp_err_t err = esp_http_client_perform(client);

if (err == ESP_OK) {
  int status_code = esp_http_client_get_status_code(client);
  if (status_code != 200) {
    ESP_LOGI(TAG, "Got %d code", status_code);
  }
} else {
    ESP_LOGE(TAG, "Error with https request: %s", esp_err_to_name(err));
}
```

## Waiting for an IP address

In  the [minimal example](https://github.com/soonick/ncona-code-samples/blob/master/making-http-https-requests-with-esp32/minimal-https/main/main.cpp), we used a delay to wait for the network connection to be completed. A better way to do this is to use NETIF events to activate a semaphore when our WiFi driver is connected.

We can start by creating a static variable that will hold the semaphore:

```cpp
static SemaphoreHandle_t IP_SEMPH = NULL;
```

We'll use `NULL` when the semaphore hasn't been created because we haven't tried to connect to a network. We will create the semaphore just before we try to connect to the network:

```cpp
IP_SEMPH = xSemaphoreCreateBinary();
if (IP_SEMPH == NULL) {
  ESP_ERROR_CHECK(ESP_ERR_NO_MEM);
}
```

Notice how we make sure the semaphore was created correctly. The only reason we would get an error from `xSemaphoreCreateBinary()` is if there was no memory available, so we use `ESP_ERROR_CHECK` to raise that error.

Before we call `esp_wifi_connect` we want to register an event handler that will be notified when the `IP_EVENT_STA_GOT_IP` event is triggered:

```cpp
ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &got_ip_handler, NULL));
```

The only thing our event handler needs to do is release the semaphore:

```cpp
static void got_ip_handler(void *arg, esp_event_base_t event_base,
                           int32_t event_id, void *event_data) {
  xSemaphoreGive(IP_SEMPH);
}
```

We want to take the semaphore right after calling `esp_wifi_connect`, so we halt execution until we get an IP address. We can do that using this snippet:

```cpp
xSemaphoreTake(IP_SEMPH, portMAX_DELAY);
```

## FreeRTOS tasks

In our minimal example, we made our HTTP request in the main task. In a production application, we might want to start a task for each different function the application performs.

We can start a task that sends our HTTP requests with this code:

```cpp
xTaskCreate(&https_with_url, "https_with_url", 8192, NULL, 5, NULL);
```

## Clear resources allocated to client after use

In our minimal example, we make a request and our program ends afterwards. In a real world scenario our software will be constantly running, so we need to make sure we deallocate resources allocated for our client, once we stop using it.

We can use the following line to do that:

```cpp
ESP_ERROR_CHECK(esp_http_client_cleanup(client));
```

## Stopping WiFi to save battery

We might want to turn off our WiFi interface to save battery and only turn it on when we need it. We do this by following a few steps:

- Call `esp_wifi_stop` to disconnect from the network and stop WiFi scanning
- Call `esp_wifi_deinit` to free all resources associated with the WiFi driver
- Call `esp_wifi_clear_default_wifi_driver_and_handlers` to free all resources associated with the default WiFi driver and all associated handlers
- Call `esp_netif_destroy` to destroy a NETIF object created with `esp_netif_create_wifi`

The code looks something like this:

```cpp
static void stop_wifi() {
  ESP_ERROR_CHECK(esp_wifi_stop());
  ESP_ERROR_CHECK(esp_wifi_deinit());
  ESP_ERROR_CHECK(esp_wifi_clear_default_wifi_driver_and_handlers(wifi_if));
  esp_netif_destroy(wifi_if);
  wifi_if = NULL;
}
```

## Complete production example

You can find a version using these improvements in [my examples repo](https://github.com/soonick/ncona-code-samples/blob/master/making-http-https-requests-with-esp32/production-https/main/main.cpp).

## Conclusion

Making an HTTPS request using ESP-IDF requires a lot more code than [what's necessary with Arduino](https://ncona.com/2024/02/sending-http-requests-with-arduino), but I feel ESP-IDF provides more control. The use of callbacks makes it easy to understand what's happening and act accordingly.

As usual, you can find the working examples in [my example repo](https://github.com/soonick/ncona-code-samples/blob/master/making-http-https-requests-with-esp32).
