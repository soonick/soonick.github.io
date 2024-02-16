---
title: Sending HTTP requests with Arduino
author: adrian.ancona
layout: post
date: 2024-02-15
permalink: /2024/02/sending-http-requests-with-arduino
tags:
  - arduino
  - electronics
  - programming
---

To make HTTP and HTTPS requests from an Arduino board, we need to first install the `ArduinoHttpClient` library:

```
arduino-cli lib install ArduinoHttpClient
```

Once we have the library, we can use it to make requests:

<!--more-->

```cpp
#include <WiFiS3.h>
#include <ArduinoHttpClient.h>

const char SSID[] = "NETWORK_NAME";
const char PASS[] = "NETWORK_PASSWORD";
const char HOST_NAME[] = "echo.free.beeceptor.com";
const int HTTP_PORT = 443;

// Use WiFiSSLClient when using https and WiFiClient when using http
WiFiSSLClient wifi;
HttpClient client = HttpClient(wifi, HOST_NAME, HTTP_PORT);
int status = WL_IDLE_STATUS;

String PATH_NAME = "/";

void setup() {
  Serial.begin(9600);

  // Verify WiFi module is available
  while (WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi module failed!");
    delay(2000);
  }

  // Connect to WiFi
  while (status != WL_CONNECTED) {
    char buffer[50];
    sprintf(buffer, "Connecting to network: %s", SSID);
    Serial.println(buffer);

    status = WiFi.begin(SSID, PASS);

    // Give some time for connection to be stablished
    delay(5000);
  }

  Serial.println("Connected!");
}

void loop() {
  Serial.println("\n");
  Serial.println("Making request");
  client.get(PATH_NAME);

  // read the status code and body of the response
  int statusCode = client.responseStatusCode();
  String response = client.responseBody();

  char statusBuffer[30];
  sprintf(statusBuffer, "\nStatus code: %i", statusCode);
  Serial.println(statusBuffer);
  Serial.println("Response: ");
  Serial.println(response);

  Serial.println("\n");

  Serial.println("Waiting...");
  delay(20000);
}
```

We can upload the code to our board with:

```bash
sudo chmod a+rw /dev/ttyACM0 && arduino-cli compile --fqbn arduino:renesas_uno:unor4wifi . && arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:renesas_uno:unor4wifi .
```

The [full example can be found at Github](https://github.com/soonick/ncona-code-samples/tree/master/sending-http-requests-with-arduino).
