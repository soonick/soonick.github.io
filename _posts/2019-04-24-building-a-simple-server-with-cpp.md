---
title: Building a simple server with C++
author: adrian.ancona
layout: post
date: 2019-04-24
permalink: /2019/04/building-a-simple-server-with-cpp/
tags:
  - c++
  - programming
  - linux
  - networking
  - server
---

In this article, I'm going to explain how to create a very simple server with C++. The server will receive a single message, send a response and then quit. For network programming in C++, we need to use some low level C functions that translate directly to syscalls.

Let's explore the syscalls we'll need.

## socket

We'll use the [socket](http://man7.org/linux/man-pages/man2/socket.2.html) function to create a socket. A socket can be seeen as a file descriptor that can be used for communication.

This is the signature of the function:

```cpp
int socket(int domain, int type, int protocol);
```

<!--more-->

The function returns -1 if there was an error. Otherwise, it will return the file descriptor assigned to the socket.

`domain` refers to the protocol the socket will use for communication. Some possible values are:

- `AF_UNIX, AF_LOCAL` - Local communication
- `AF_INET` - IPv4 Internet protocols
- `AF_INET6` - IPv6 Internet protocols
- `AF_IPX` - IPX Novell protocols

`type` specifies if the communication will be conectionless, or persistent. Not all `types` are compatible with all `domains`. Some examples are:

- `SOCK_STREAM` - Two-way reliable communication (TCP)
- `SOCK_DGRAM` - Connectionless, unreliable (UDP)

Normally there is only one `protocol` available for each `type`, so the value `0` can be used.

## bind

Once we have the socket, we need to use [bind](http://man7.org/linux/man-pages/man2/bind.2.html) to assign an IP address and port to the socket.

The signature of the `bind` function is:

```cpp
int bind(int sockfd, const sockaddr *addr, socklen_t addrlen);
```

Similar to `socket`, the function returns -1 in case of error. In case of success, it returns 0.

`sockfd` refers to the file descriptor we want to assign an address to. For us, it will be the file descriptor returned by `socket`.

`addr` is a struct used to specify the address we want to assign to the socket. The exact struct that needs to be used to define the address, varies by protocol. Since we are going to use IP for this server, we will use [sockaddr_in](http://man7.org/linux/man-pages/man7/ip.7.html):

```cpp
struct sockaddr_in {
   sa_family_t    sin_family; /* address family: AF_INET */
   in_port_t      sin_port;   /* port in network byte order */
   struct in_addr sin_addr;   /* internet address */
};
```

`addrlen` is just the `size()` of `addr`.

## listen

[listen](http://man7.org/linux/man-pages/man2/listen.2.html) marks a socket as passive. i.e. The socket will be used to accept connections. The signature is:

```cpp
int listen(int sockfd, int backlog);
```

Returns -1 in case of error. In case of success, it returns 0.

`sockfd` is the file descriptor of the socket.

`backlog` is the maximum number of connections that will be queued before connections start being refused.

## accept

[accept](http://man7.org/linux/man-pages/man2/accept.2.html) extracts an element from a queue of connections (The queue created by `listen`) for a socket. The signature is:

```cpp
int accept(int sockfd, sockaddr *addr, socklen_t *addrlen);
```

The function will return -1 if there is an error. On success, it will return a file descriptor for the connection.

The argument list is similar to the one for `bind`, with one difference. `addrlen` is now a value-result argument. It expects a pointer to an int that will be the size of `addr`. After the function is executed, the int refered by `addrlen` will be set to the size of the peer address.

Let's now put this in action.

## Putting it all together

```cpp
#include <sys/socket.h> // For socket functions
#include <netinet/in.h> // For sockaddr_in
#include <cstdlib> // For exit() and EXIT_FAILURE
#include <iostream> // For cout
#include <unistd.h> // For read

int main() {
  // Create a socket (IPv4, TCP)
  int sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd == 0) {
    std::cout << "Failed to create socket. errno: " << errno << std::endl;
    exit(EXIT_FAILURE);
  }

  // Listen to port 9999 on any address
  sockaddr_in sockaddr;
  sockaddr.sin_family = AF_INET;
  sockaddr.sin_addr.s_addr = INADDR_ANY;
  sockaddr.sin_port = htons(9999); // htons is necessary to convert a number to
                                   // network byte order
  if (bind(sockfd, (struct sockaddr*)&sockaddr, sizeof(sockaddr)) < 0) {
    std::cout << "Failed to bind to port 9999. errno: " << errno << std::endl;
    exit(EXIT_FAILURE);
  }

  // Start listening. Hold at most 10 connections in the queue
  if (listen(sockfd, 10) < 0) {
    std::cout << "Failed to listen on socket. errno: " << errno << std::endl;
    exit(EXIT_FAILURE);
  }

  // Grab a connection from the queue
  auto addrlen = sizeof(sockaddr);
  int connection = accept(sockfd, (struct sockaddr*)&sockaddr, (socklen_t*)&addrlen);
  if (connection < 0) {
    std::cout << "Failed to grab connection. errno: " << errno << std::endl;
    exit(EXIT_FAILURE);
  }

  // Read from the connection
  char buffer[100];
  auto bytesRead = read(connection, buffer, 100);
  std::cout << "The message was: " << buffer;

  // Send a message to the connection
  std::string response = "Good talking to you\n";
  send(connection, response.c_str(), response.size(), 0);

  // Close the connections
  close(connection);
  close(sockfd);
}
```

This program can now be compiled and run:

```bash
g++ server.cpp -o server
./server
```

We can test the server using telnet:

```bash
telnet localhost 9999
```

We can then type anything and it will be sent to our server. I typed: `Who is there?`. This is the output from the server:

```bash
$ ./server
The message was: Who is there?
```

The telnet session looks like this:

```bash
$ telnet localhost 9999
Trying ::1...
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Who is there?
Good talking to you
Connection closed by foreign host.
```

One thing I discovered while creating this server is that when I did this and tried to restart the server right away, I got an error:

```
$ ./server
Failed to bind to port 9999. errno: 98
```

To find what 98 means, you can use the `errno` program. To install it:

```
sudo apt install moreutils
```

To find what the error code means:

```
$ errno 98
EADDRINUSE 98 Address already in use
```

After some research, I found that even after we call `close`, the tcp connection is not immediately freed. This is part of the TCP protocol definition. Before being closed, a socket transitions to TIME_WAIT state. This is done to give time to the socket to cleanly shutdown. After some time, the address will be released by the OS. There are ways to work around this issue, but I'm not going to cover them in this article.
