---
title: Using Arduino Serial Monitor From Linux
author: adrian.ancona
layout: post
date: 2024-01-31
permalink: /2024/01/using-arduino-serial-monitor-from-linux
tags:
  - arduino
  - electronics
  - productivity
  - programming
---

Arduino Serial Monitor is a tool that can be used for debugging or interacting with our Arduino board. More specifically, it allows us to read and write data to a serial port.

For our sketch to be able to use the serial monitor, we need to use `Serial.begin` and specify a baud rate. For example:

```bash
Serial.begin(9600);
```

The valid baud rates vary depending on the board we are using. `9600` is a safe value that works on most boards.

## Reading

The first thing we want to do is [print](https://www.arduino.cc/reference/en/language/functions/communication/print/) to the serial port. For example:

```
Serial.println("Hello");
```

<!--more-->

This simple sketch shows how we can print a `Hello` message every 2 seconds:

```cpp
void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.println("Hello");
  delay(2000);
}
```

If we upload this sketch to our board and connect the board to our PC, we can use these commands to see the output of our sketch:

```bash
sudo chmod a+rw /dev/ttyACM0
sudo stty 9600 -F /dev/ttyACM0 raw -echo
sudo cat /dev/ttyACM0
```

Note that `9600` matches the baud rate specified in our sketch.

## Writing

We can also use our board's serial port to receive input from users. There are [multiple functions](https://www.arduino.cc/reference/en/language/functions/communication/serial/) available for reading data; I'll use `parseInt()` in my example, since it's very easy to use:

```cpp
int inputNumber;

void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.println("Enter a number:");

  while (Serial.available() == 0) {
    // Loop until there is data to be read
  }

  inputNumber = Serial.parseInt();
  Serial.print("You entered: ");
  Serial.println(inputNumber);
}
```

We use `Serial.available` to wait for the user to input some data. To input said data, we can use these commands:

```
sudo chmod a+rw /dev/ttyACM0
sudo stty 9600 -F /dev/ttyACM0 raw -echo
echo "45" > /dev/ttyACM0
```

## Conclusion

Arduino IDE includes a Serial Monitor that can be used to interact with a board's serial port. In Linux environments we can use commands available in most distributions to interact with the serial port even if Arduino IDE is not available.
