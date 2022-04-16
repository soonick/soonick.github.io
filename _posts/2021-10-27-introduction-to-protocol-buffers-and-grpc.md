---
title: Introduction to Protocol Buffers and gRPC
author: adrian.ancona
layout: post
date: 2021-10-27
permalink: /2021/10/introduction-to-protocol-buffers-and-grpc
tags:
  - architecture
  - java
  - programming
  - server
---

In the beginning of time RPC (Remote Procedure Calls) was the standard way of communicating between remote services. Some time passed and REST (REpresentational State Transfer) took over as the king.

REST and JSON became popular because they made it easy to understand the communication between clients and servers, since JSON is easy for humans to read.

With the rise of Microservices and systems that are increasingly chatty, JSON became a considerable overhead. Transmiting data in a human readable format, as well as serializing and deserializing this data turned out to be very slow. For this reason, different teams started working in more efficient serialization formats (e.g. protobuf, thrift, etc). As part of this revolution, gRPC was born.

gRPC is a recursive acronym that stands for gRPC Remote Procedure Call. It's a framework for that is supported by many programming languages and provides many features for advanced use-cases.

<!--more-->

## Protocol Buffers

By default gRPC uses [Protocol Buffers](https://developers.google.com/protocol-buffers/docs/proto3) as its Interface Definition Language (IDL) as well as the transport format.

When working with Protocol Buffers, we start by defining messages in `.proto` files. Example:

```proto
syntax = "proto3";

message Person {
  string name = 1;
  int32 age = 2;
}
```

We can think of a message as a struct or a plain object. In the example above, the name of the message is `Person` and it has two fields. The field `name` is a `string` and the field `age` is a 32 bit integer.

We can also see that after each field we have something like `= <number>`. This is an identifier for the field that helps the compiler encode and decode messages. These `<number>`s must be different for each field in a message and and must never change.

In the example above, each field has a single value, but we can also have fields that can receive a list of values, by using the `repeated` keyword:

```proto
syntax = "proto3";

message Person {
  string name = 1;
  int32 age = 2;
  repeated string friends = 3;
}
```

The `friends` field can contain multiple names.

Messages can also contain other messages:

```proto
syntax = "proto3";

message Name {
  string first_name = 1;
  string last_name = 2;
}

message Person {
  Name name = 1;
  int32 age = 2;
  repeated string friends = 3;
}
```

Notice how the `name` field of `Person` is itself a `Name`.

Another useful construct are `enums`, which allows us to limit the possible values of a field:

```proto
syntax = "proto3";

enum Gender {
  UNSPECIFIED = 0;
  MALE = 1;
  FEMALE = 2;
}

message Person {
  string name = 1;
  int32 age = 2;
  repeated string friends = 3;
  Gender gender = 4;
}
```

There are many more things we can do with Protocol Buffers DIL, but we're not going to cover everything here. This should be enough to get started.

## Using Protocol Buffers in Java

For a proto definition to be useful in a specific language it needs to be compiled and generate the language specific files. The name of the program that does this is the `protoc` compiler. To try the compiler we need to first download it and install it.

We can find the latest version in [the releases page](https://github.com/protocolbuffers/protobuf/releases/tag/v3.18.1).

Once it's installed, let's create a file named `person.proto`, with this content:

```proto
syntax = "proto3";

message Name {
  string first_name = 1;
  string last_name = 2;
}

enum Gender {
  UNSPECIFIED = 0;
  MALE = 1;
  FEMALE = 2;
}

message Person {
  Name name = 1;
  int32 age = 2;
  repeated string friends = 3;
  Gender gender = 4;
}
```

We can navigate to that folder in a terminal and use this command to compile the proto file to Java:

```bash
/path/to/protoc ./person.proto --java_out=.
```

Replace `/path/to/protoc` with the location of your `protoc` binary. The result is a single file named `PersonOuterClass.java`. This file contains a lot of code that might not be super clear. The important thing is that we have a `Person` class that follows the same structure as the message we defined in the `proto` file.

A not obvious detail about the generated classes is that they are immutable, which means that once an object is created, it can't be modified. The way new instances of the class are created is by using a Builder (which is also part of the generated code). To generate a person, we would do something like this:

```java
Person adrian = Person.newBuilder().setAge(35).build();
```

I omitted a lot most of the fields for brevity, but that's the main idea.

Although we can compile `proto` files using `protoc` like we did above, it would be time consuming and error prone to expect people to do this manually every time a `proto` file is changed. For this reason there are tools that allow us to add this compilation step as part of our build.

## Compiling proto files in Bazel

Bazel is just one of the build tools that allows us to automatically compile `proto` files into Java. If you are not familiar with Bazel, you can look at my [introduction to Bazel](https://ncona.com/2021/08/introduction-to-bazel) to get started.

To be able to compile proto files we need to install `rules_proto`. We can do it by adding this code to our `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Loads rules required to compile proto files
http_archive(
    name = "rules_proto_grpc",
    sha256 = "28724736b7ff49a48cb4b2b8cfa373f89edfcb9e8e492a8d5ab60aa3459314c8",
    strip_prefix = "rules_proto_grpc-4.0.1",
    urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/archive/4.0.1.tar.gz"],
)

load("@rules_proto_grpc//:repositories.bzl", "rules_proto_grpc_toolchains", "rules_proto_grpc_repos")
rules_proto_grpc_toolchains()
rules_proto_grpc_repos()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
rules_proto_dependencies()
rules_proto_toolchains()

# Loads rules required to generate java files based on compiled proto files
load("@rules_proto_grpc//java:repositories.bzl", rules_proto_grpc_java_repos = "java_repos")
rules_proto_grpc_java_repos()
```

In our `BUILD` file we need to use `proto_library` to compile our proto files and a `java_proto_library` to generate the java files:

```python
load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_proto_grpc//java:defs.bzl", "java_proto_library")

java_proto_library(
    name = "person_java_proto",
    protos = [":person_proto"],
)

proto_library(
    name = "person_proto",
    srcs = ["person.proto"],
)

java_binary(
    name = 'main',
    srcs = [
      'Main.java'
    ],
    deps = [":person_java_proto"],
    main_class = 'example.Main',
)
```

Note that we also defined a `java_binary` that has `person_java_proto` as a dependency. Before we look at the binary, let's look at our `person.proto` file:

```proto
syntax = "proto3";

package example.protos;

option java_multiple_files = true;

message Name {
  string first_name = 1;
  string last_name = 2;
}

enum Gender {
  UNSPECIFIED = 0;
  MALE = 1;
  FEMALE = 2;
}

message Person {
  Name name = 1;
  int32 age = 2;
  repeated string friends = 3;
  Gender gender = 4;
}
```

We added some options that we didnt' have before. Namely, the `package` is needed so we can reference our generated java classes. The `java_multiple_files` option makes it so a file is generated for each message. This allows us to refer to the generated `Person` class as `example.protos.Person`.

Let's now look at the our binary:

```java
package example;

import example.protos.Person;

public class Main {
  public static void main(String args[]) {
    final Person adrian = Person.newBuilder().setAge(35).build();
    System.out.println("Adrian's age is: " + adrian.getAge());
  }
}
```

And that's it. Every time we modify our proto file, the new messages will be available in our java code.

The full working [protocol buffers example can be found in github](https://github.com/soonick/ncona-code-samples/tree/master/protobuf-grpc/protobuf)

## Getting started with gRPC

So far we have learned how to use Protocol Buffers, but we haven't looked very much into gRPC. In this section we're going to see how these two work together.

First of all, gRPC servers are defined using the Protocol Buffers language. Let's create a file named `server.proto` with this content:

```proto
syntax = "proto3";

package example.protos;

option java_multiple_files = true;

message GreetRequest {
  string name = 1;
}

message GreetResponse {
  string greeting = 1;
}

service MyServer {
  rpc Greet (GreetRequest) returns (GreetResponse) {}
}
```

Most of the file should be familiar at this point. The new part is:

```proto
service MyServer {
  rpc Greet (GreetRequest) returns (GreetResponse) {}
}
```

As we can probably guess, the `service` keyword allows us to define a service. In this case, we named our service `MyServer`. This service contains a single method called `Greet`. This method takes a message as input (`GreetRequest`) and returns another message (`GreetResponse`).

This file works as the API definition for our service, that will be shared by clients and servers, but we haven't created any client or server yet.

To create a gRPC server the proto definition isn't enough, we also need the gRPC code generator. As with the `proto` compiler, this step can be integrated into most build systems, but I'm just going to show how to do it for Bazel.

We will need to modify our `WORKSPACE` file to look like this:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Loads rules required to compile proto files
http_archive(
    name = "rules_proto_grpc",
    sha256 = "28724736b7ff49a48cb4b2b8cfa373f89edfcb9e8e492a8d5ab60aa3459314c8",
    strip_prefix = "rules_proto_grpc-4.0.1",
    urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/archive/4.0.1.tar.gz"],
)

load("@rules_proto_grpc//:repositories.bzl", "rules_proto_grpc_toolchains", "rules_proto_grpc_repos")
rules_proto_grpc_toolchains()
rules_proto_grpc_repos()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
rules_proto_dependencies()
rules_proto_toolchains()

# Loads rules required to generate java files based on compiled proto files
load("@rules_proto_grpc//java:repositories.bzl", rules_proto_grpc_java_repos = "java_repos")
rules_proto_grpc_java_repos()

# Load rules required to generate java gRPC files
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@io_grpc_grpc_java//:repositories.bzl", "IO_GRPC_GRPC_JAVA_ARTIFACTS", "IO_GRPC_GRPC_JAVA_OVERRIDE_TARGETS", "grpc_java_repositories")

maven_install(
    artifacts = IO_GRPC_GRPC_JAVA_ARTIFACTS,
    generate_compat_repositories = True,
    override_targets = IO_GRPC_GRPC_JAVA_OVERRIDE_TARGETS,
    repositories = [
        "https://repo.maven.apache.org/maven2/",
    ],
)

load("@maven//:compat.bzl", "compat_repositories")
compat_repositories()
grpc_java_repositories()
```

We also need to add a `java_grpc_library` to our `BUILD` file:

```python
load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_proto_grpc//java:defs.bzl", "java_grpc_library")
load("@rules_proto_grpc//java:defs.bzl", "java_proto_library")

java_proto_library(
    name = "server_java_proto",
    protos = [":server_proto"],
)

proto_library(
    name = "server_proto",
    srcs = ["server.proto"],
)

java_grpc_library(
    name = "server_java_grpc",
    protos = [":server_proto"],
)

java_binary(
    name = 'main',
    srcs = [
      'Main.java'
    ],
    deps = [
      ":server_java_proto",
      ":server_java_grpc",
    ],
    main_class = 'example.Main',
)
```

For our binary to have access to the generated files, it needs to depend on `server_java_grpc`.

Finally, we need to modify our `Main.java`:

```java
import java.io.IOException;

public class Main {
  public static void main(String args[]) throws IOException, InterruptedException {
    final int port = 9876;
    final Server server = ServerBuilder.forPort(port)
        .addService(new MyServerImpl())
        .build()
        .start();
    System.out.println("Server started on port: " + port);
    server.awaitTermination();
  }

  static class MyServerImpl extends MyServerGrpc.MyServerImplBase {
    @Override
    public void greet(GreetRequest req, StreamObserver<GreetResponse> responseObserver) {
      GreetResponse resp = GreetResponse.newBuilder()
          .setGreeting("Hi " + req.getName())
          .build();
      responseObserver.onNext(resp);
      responseObserver.onCompleted();
    }
  }
}
```

The first interesting part is the `MyServerImpl` class:

```java
static class MyServerImpl extends MyServerGrpc.MyServerImplBase {
  @Override
  public void greet(GreetRequest req, StreamObserver<GreetResponse> responseObserver) {
    GreetResponse resp = GreetResponse.newBuilder()
        .setGreeting("Hi " + req.getName())
        .build();
    responseObserver.onNext(resp);
    responseObserver.onCompleted();
  }
}
```

`MyServerGrpc` is one of the classes generated by `java_grpc_library`. As we can see, we can extend it to provide implementations for our methods. For this example, we provide a very simple implementation where we reply with `Hi <name>`.

The next interesting part is when we actually start the server:

```java
final int port = 9876;
final Server server = ServerBuilder.forPort(port)
    .addService(new MyServerImpl())
    .build()
    .start();
System.out.println("Server started on port: " + port);
server.awaitTermination();
```

We use a `ServerBuilder` to start our `MyServerImpl` in the specified port. Later, we use `awaitTermination` so our server waits for requests until it's terminated.

## gRPC Clients

Now that we have our server, we need a client so we can talk to it. In the gRPC world, clients are referered as [stubs](https://en.wikipedia.org/wiki/Stub_(distributed_computing)). Let's look at an example stub for our server:

```java
package example;

import example.protos.GreetRequest;
import example.protos.GreetResponse;
import example.protos.MyServerGrpc;
import io.grpc.Channel;
import io.grpc.ManagedChannelBuilder;

public class ClientMain {
  public static void main(String args[]) {
    final String target = "localhost:9876";
    final Channel channel = ManagedChannelBuilder.forTarget(target)
        // Channels use SSL by default. This disables SSL since our server doesn't
        // support it
        .usePlaintext()
        .build();
    final MyServerGrpc.MyServerBlockingStub stub = MyServerGrpc.newBlockingStub(channel);
    final GreetRequest request = GreetRequest.newBuilder().setName("Carlos").build();
    final GreetResponse response = stub.greet(request);
    System.out.println("Response: " + response.getGreeting());
  }
}
```

We start by creating a `channel`, which basically is the configuration for the connection with the server:

```java
final Channel channel = ManagedChannelBuilder.forTarget(target)
    // Channels use SSL by default. This disables SSL since our server doesn't
    // support it
    .usePlaintext()
    .build();
```

The next step is to create a stub. In this case we create a blocking stub, which allows us to call remote methods and wait for a response synchronously:

```java
final MyServerGrpc.MyServerBlockingStub stub = MyServerGrpc.newBlockingStub(channel);
```

Finally, we make the request and get the response:

```java
final GreetRequest request = GreetRequest.newBuilder().setName("Carlos").build();
final GreetResponse response = stub.greet(request);
System.out.println("Response: " + response.getGreeting());
```

The full [grpc server and client example can be found in github](https://github.com/soonick/ncona-code-samples/tree/master/protobuf-grpc/grpc)

## Conclusion

Getting started with gRPC takes a little more effort than communicating with services with HTTP and JSON, but it comes with some advantages, the most important ones being performance and type safety.

In this article we learned how to set up the necesary tooling to get started with gRPC and also learned how to build a basic server and client. There is a lot more to learn, but this should serve as a foundation for the next steps.
