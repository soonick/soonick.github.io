---
title: Implementing a Language Server Protocol client
author: adrian.ancona
layout: post
date: 2021-12-15
permalink: /2021/12/implementing-a-language-server-protocol-client
tags:
  - open_source
  - productivity
  - programming
---

There are a lot of IDEs out there that offer features like auto complete, go to definition, etc. Traditionally each IDE has logic for parsing and understanding code in a project, and plugs this understanding into its UI. How good the IDE's understanding of a particular language together with their user experience are their most powerful selling points.

In the past, different IDEs that supported the same language had their own proprietary code that gave them insights into a programming language.

[LSP](https://microsoft.github.io/language-server-protocol/) is an open source standard created by Microsoft. It defines a protocol for a program that understands a programming language to talk to another program (typically an IDE) that wants to take advantage of these features. This protocol allows anybody to build a server that understands a language and make it available to the world. Programmers can leverage these servers to provide powerful tools or IDEs.

## The server

The server takes care of understanding the structure of a program and implementing an API to share this understanding.

There are various [server implementations](https://microsoft.github.io/language-server-protocol/implementors/servers/) out there and they vary widely in the number of features they support.

<!--more-->

## The client

The client is usually an IDE. It provides users the ability to open and edit source code files. With help from the server it can provide things like code highlighting or a UI for autocompletion, among other things.

## Client-Server communication

The relationship between the client and the server can feel a little unintuitive at first, but it's well suited for the IDE use case.

Typically, users start their interaction with this ecosystem by opening their IDE. At this point, there are a few things that happen:

1. The IDE starts a server at some port (This is the client)
2. The IDE starts the Language Server and tells it to find the client at `localhost:<some port>`
3. The Language Server connects to the client
3. The client sends an `initialize` request to the server
4. The server responds to this request advertising its capabilities (The features it supports)
5. Client and Server communicate using LSP
6. Client sends `shutdown` message
7. Server reponds to `shutdown`
8. Client sends `exit` message
9. Server shuts down

At a high level that's how the system works, but to make it easier to visualize, we can use one of the available servers to see this in action.

## LSP in action

Now that we know at a high lever how LSP works, we can get a better understanding of it by using LSP to talk to a well known server implementation.

At the time of this writing, [Eclipse JDT Language Server](https://github.com/eclipse/eclipse.jdt.ls) is the most popular LSP implementation for Java. We can get their binaries from [Eclipse's downloads page](https://download.eclipse.org/jdtls/snapshots/). I'm going to be using [jdt-language-server-1.6.0-202111250302.tar.gz](https://download.eclipse.org/jdtls/snapshots/jdt-language-server-1.6.0-202111250302.tar.gz), but you can probably use the most recent version.

Once we have the tarball, we'll need to extract it:

```sh
mkdir jdt-server
tar -zxf jdt-language-server-1.6.0-202111250302.tar.gz -C jdt-server
```

In the previous section we mentioned that the first step is starting the client, so let's start by building a very simple Java program that will act as client:

```java
package example;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class LspClient {
  BufferedReader in;
  PrintWriter out;
  ServerSocket serverSocket;
  Socket clientSocket;

  LspClient() throws Exception {
    serverSocket = new ServerSocket(6666);

    System.out.println("Waiting for server to connect");
    clientSocket = serverSocket.accept();
    System.out.println("Server connected");

    in = new BufferedReader(
      new InputStreamReader(clientSocket.getInputStream())
    );
    out = new PrintWriter(clientSocket.getOutputStream(), true);
  }

  /**
   * Processes incoming messages from the server
   */
  private void processMessages() throws Exception {
    // All messages start with a header
    String header;
    while ((header = in.readLine()) != null) {
      // Read all the headers and extract the message content from them
      int contentLength = -1;
      while (!header.equals("")) {
        System.out.println("Header: " + header);
        if (isContentLengthHeader(header)) {
          contentLength = getContentLength(header);
        }
        header = in.readLine();
      }

      System.out.println("Reading body");
      // Read the body
      if (contentLength == -1) {
        throw new RuntimeException("Unexpected content length in message");
      }
      char[] messageChars = new char[contentLength];
      in.read(messageChars, 0, contentLength);
      System.out.println(messageChars);
    }
  }

  private boolean isContentLengthHeader(String header) {
    return header.toLowerCase().contains("content-length");
  }

  private int getContentLength(String header) {
    return Integer.parseInt(header.split(" ")[1]);
  }

  private void close() throws Exception {
    in.close();
    out.close();
    clientSocket.close();
    serverSocket.close();
  }

  public static void main(String[] args) throws Exception {
    LspClient lspClient = new LspClient();

    lspClient.processMessages();
    lspClient.close();
  }
}
```

Our client currently doesn't do anything other than opening a server in port `6666` and printing all the messages it receives.

The second step is starting our server. The main file we care about is `plugins/org.eclipse.equinox.launcher_...`. We can go to the `jdt-server` folder we created above and run this command:

```sh
java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.level=ALL \
  -DCLIENT_PORT=6666 \
  -noverify \
  -Xmx1G \
  -jar plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar \
  -configuration ./config_linux \
  -data ./data \
  --add-modules=ALL-SYSTEM \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.lang=ALL-UNNAMED
```

There are a few important things to mention about this command:

- `-DCLIENT_PORT=6666` - Tells the server that it can find the client at `localhost:6666`
- `-configuration ./config_linux` - I'm choosing the Linux config because I'm running on Linux. There are different folders available for different OS
- `-data ./data` - The server needs a folder where it will store information about the current session. Any empty folder will do

When I run this command and look at the client I see this output:

```sh
Waiting for server to connect
Server connected
Header: Content-Length: 126
Reading body
{"jsonrpc":"2.0","method":"window/logMessage","params":{"type":3,"message":"Nov 26, 2021, 3:15:32 PM Main thread is waiting"}}
```

Our code expects messages to follow the LSP format, which consists of a `header` and a `content`. Headers are very similar to HTTP headers and come in the format:

```sh
Header-Name: value
```

Each header must be followed by `\r\n`. After all headers there will be an additional `\r\n`. This means that after the last header there will be two sets of `\r\n`, followed by the `content`.

The `content` varies depending on the message, but always uses the [JSON_RPC](https://www.jsonrpc.org/specification) format and this general shape:

```json
{
  "jsonrpc": "2.0",
  "id": <some id for this message>,
  "method": "<some method name>",
  "params": <params object depending on the message>
}
```

A full mesage looks something like this:

```json
Content-Length: 127\r\n
\r\n
{
  "jsonrpc": "2.0",
  "id": <some id for this message>,
  "method": "<some method name>",
  "params": <params object depending on the message>
}
```

Knowing this, we can see that the server sent a message of type `window/logMessage`, which simply tells us that it's ready.

Following the protocol, the next step is for the client to send an [`initialize`](https://microsoft.github.io/language-server-protocol/specifications/specification-current/#initialize) message. We can add that step to our little client:

```java
package example;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class LspClient {
  BufferedReader in;
  PrintWriter out;
  ServerSocket serverSocket;
  Socket clientSocket;

  LspClient() throws Exception {
    serverSocket = new ServerSocket(6666);

    System.out.println("Waiting for server to connect");
    clientSocket = serverSocket.accept();
    System.out.println("Server connected");

    in = new BufferedReader(
      new InputStreamReader(clientSocket.getInputStream())
    );
    out = new PrintWriter(clientSocket.getOutputStream(), true);
  }

  /**
   * Processes incoming messages from the server
   */
  private void processMessages() throws Exception {
    // All messages start with a header
    String header;
    while ((header = in.readLine()) != null) {
      // Read all the headers and extract the message content from them
      int contentLength = -1;
      while (!header.equals("")) {
        System.out.println("Header: " + header);
        if (isContentLengthHeader(header)) {
          contentLength = getContentLength(header);
        }
        header = in.readLine();
      }

      System.out.println("Reading body");
      // Read the body
      if (contentLength == -1) {
        throw new RuntimeException("Unexpected content length in message");
      }
      char[] messageChars = new char[contentLength];
      in.read(messageChars, 0, contentLength);
      handleMessage(String.valueOf(messageChars));
    }
  }

  private void handleMessage(String message) {
    System.out.println("Message: " + message);

    if (message.contains("PM Main thread is waiting")) {
      System.out.println("Server is ready. Initializing");
      sendIntialize();
    }
  }

  private void sendIntialize() {
    System.out.println("Sending initialize message");

    String initializeMessage = "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"clientInfo\":{\"name\":\"MyTestClient\",\"version\":\"1\"}}}";
    sendMessage(initializeMessage);
  }

  private void sendMessage(String body) {
    String header = "Content-Length: " + body.getBytes().length + "\r\n";
    final String message = header + "\r\n" + body;
    out.println(message);
  }


  private boolean isContentLengthHeader(String header) {
    return header.toLowerCase().contains("content-length");
  }

  private int getContentLength(String header) {
    return Integer.parseInt(header.split(" ")[1]);
  }

  private void close() throws Exception {
    in.close();
    out.close();
    clientSocket.close();
    serverSocket.close();
  }

  public static void main(String[] args) throws Exception {
    LspClient lspClient = new LspClient();

    lspClient.processMessages();
    lspClient.close();
  }
}
```

If we run this client code and start the server, we'll get back a lot of messages, but the most important one is the response to our message:

```json
{
    "id": 1,
    "jsonrpc": "2.0",
    "result": {
        "capabilities": {
            "callHierarchyProvider": true,
            "codeActionProvider": true,
            "codeLensProvider": {
                "resolveProvider": true
            },
            "completionProvider": {
                "resolveProvider": true,
                "triggerCharacters": [
                    ".",
                    "@",
                    "#",
                    "*"
                ]
            },
            ...
        }
    }
}
```

The first thing to notice is the `id` field. This field is used to match responses to requests when multiple requests are sent to the server.

As part of the response, the server also advertises its capabilities, so the client knows which features it can provide.

## Conclusion

The goal of this article is to provide a short practical guide for LSP. The [Language Server Protocol Specification](https://microsoft.github.io/language-server-protocol/specifications/specification-current/) explains the whole protocol in detail, so we don't cover many examples.

Instead, this article focused on showing how we can create a very simple client that talks to an real world server implementation.
