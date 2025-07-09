---
title: Introduction to Tonic for gRPC in Rust
author: adrian.ancona
layout: post
# date: 2025-07-09
# permalink: /2025/07/introduction-to-tonic-for-grpc-in-rust/
tags:
  - architecture
  - programming
  - rust
  - server
---

A few years ago I wrote [an article explaining Protocol Buffers, gRPC, and showing how to use them with Java](/2021/10/introduction-to-protocol-buffers-and-grpc). In this article, I'm going to show how to build the same server and client, but this time with Rust.

## Project structure

There are going to be 3 parts for our example:

- Proto files
- Server
- Client

We'll have a root folder and then a folder for each part:

```
/
├── client
├── protos
└── server
```

<!--more-->

## Protos

Inside the `protos` folder we will create 2 files.

person.proto:

```proto
syntax = "proto3";

package example.protos;

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

server.proto:

```proto
syntax = "proto3";

package example.protos;

message GreetRequest {
  string name = 1;
}

message GreetResponse {
  string greeting = 1;
}

service BasicService {
  rpc Greet (GreetRequest) returns (GreetResponse) {}
}
```

## Server

Our server requires a compiled version of the proto files to work. For this reason, we will create a file named `build.rs` with this content:

```rust
use std::{
    fs,
    path::Path
};

fn collect_protos(dir: &Path) -> Vec<String> {
    let mut protos = Vec::new();
    for entry in fs::read_dir(dir).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();
        if path.is_dir() {
            protos.extend(collect_protos(&path));
        } else if path.extension().unwrap() == "proto" {
            protos.push(path.to_str().unwrap().to_string());
        }
    }
    protos
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root = Path::new("../protos");
    let protos = collect_protos(&root);
    tonic_build::configure().build_client(false).compile_protos(&protos, &[root])?;
    Ok(())
}
```

The `build.rs` file is automatically run by cargo before the project is built. The compiled version of our protos will be placed in `OUT_DIR/example.protos.rs`. To find the exact path to the generated file, we can use this command:

```bash
find ./target -name "example.protos.rs"
```

With our protos dependency generated, we can proceed to write the server code (`src/main.rs`):

```rust
use tonic::{transport::Server, Request, Response, Status};

use protos::{
    basic_service_server::{BasicService, BasicServiceServer},
    {GreetResponse, GreetRequest}
};

pub mod protos {
    tonic::include_proto!("example.protos");
}

#[derive(Debug, Default)]
pub struct BasicServiceImpl {}

#[tonic::async_trait]
impl BasicService for BasicServiceImpl {
    async fn greet(
        &self,
        request: Request<GreetRequest>,
    ) -> Result<Response<GreetResponse>, Status> {
        let reply = GreetResponse {
            greeting: format!(" Hi {}!", request.into_inner().name),
        };

        Ok(Response::new(reply))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "0.0.0.0:50051".parse()?;
    let service = BasicServiceImpl::default();

    Server::builder()
        .add_service(BasicServiceServer::new(service))
        .serve(addr)
        .await?;

    Ok(())
}
```

To include the dependencies on our generated code, we use this part:

```rust
use protos::{
    basic_service_server::{BasicService, BasicServiceServer},
    {GreetResponse, GreetRequest}
};

pub mod protos {
    tonic::include_proto!("example.protos");
}
```

Notice how we create a module named `protos` and there, we call `include_proto!`. Because we chose the name `protos`, we also use that name in dependency declaration: `use protos::`.

The code generator uses a few conventions when generating the code. In our proto file, we named our service: `BasicService`, this gets translated to a module named `basic_service_server` and the structs `BasicService` and `BasicServiceServer`.

We then proceed to implement the `BasiceService` trait. This is basically the code that implements each of our server's methods:

```rust
#[derive(Debug, Default)]
pub struct BasicServiceImpl {}

#[tonic::async_trait]
impl BasicService for BasicServiceImpl {
    async fn greet(
        &self,
        request: Request<GreetRequest>,
    ) -> Result<Response<GreetResponse>, Status> {
        let reply = GreetResponse {
            greeting: format!(" Hi {}!", request.into_inner().name),
        };

        Ok(Response::new(reply))
    }
}
```

Finally, we use tokio to actually start a server in a specific port:

```rust
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50051".parse()?;
    let service = BasicServiceImpl::default();

    Server::builder()
        .add_service(BasicServiceServer::new(service))
        .serve(addr)
        .await?;

    Ok(())
}
```

The only missing part is our Cargo.toml file, where we need to specify all our dependencies. Notice that we include `tonic-build` as a `build-dependency`, since it is used by `build.rs`:

```toml
[package]
name = "server"
version = "0.1.0"
edition = "2021"

[dependencies]
tonic = "0.13.1"

[build-dependencies]
tonic-build = "0.13.1"
```

## Client

To test our server, we'll build a client that calls the `greet` method.

As with the server, we'll use `build.rs` to auto-generate some code for us:

```rust
use std::{
    fs,
    path::Path
};

fn collect_protos(dir: &Path) -> Vec<String> {
    let mut protos = Vec::new();
    for entry in fs::read_dir(dir).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();
        if path.is_dir() {
            protos.extend(collect_protos(&path));
        } else if path.extension().unwrap() == "proto" {
            protos.push(path.to_str().unwrap().to_string());
        }
    }
    protos
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root = Path::new("../protos");
    let protos = collect_protos(&root);
    tonic_build::configure().build_server(false).compile_protos(&protos, &[root])?;
    Ok(())
}
```

We proceed to write `src/main.rs`:

```rust
use tonic::Request;

use protos::{
    basic_service_client::BasicServiceClient,
    GreetRequest
};

pub mod protos {
    tonic::include_proto!("example.protos");
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = BasicServiceClient::connect("http://tonic-server:50051").await?;

    let request = Request::new(GreetRequest {
        name: "Carlos".to_string()
    });

    let response = client.greet(request).await?;

    println!("The response message is: {:?}", response.get_ref());
    println!("The response metadata is: {:?}", response.metadata());
    println!("The response greeting is: {}", response.get_ref().greeting);

    Ok(())
}
```

The code is very simple. It starts by telling the client where to find the server:

```rust
let mut client = BasicServiceClient::connect("http://tonic-server:50051").await?;
```

Then, it builds the request and sends it to the `greet` method:

```rust
let request = Request::new(GreetRequest {
    name: "Carlos".to_string()
});
let response = client.greet(request).await?;
```

The response message can be retrieved with `response.get_ref()`. The metadata includes useful information such as the [gRPC status code](https://grpc.io/docs/guides/status-codes/).

## Conclusion

Tonic documentation includes an example server and client very similar to the one above, but it fails to explain a few details, such as where the code generated from the protos lives. This example should be all we need to start using tonic in larger projects.

As usual, a full working example can be found in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/introduction-to-tonic-for-grpc-in-rust).
