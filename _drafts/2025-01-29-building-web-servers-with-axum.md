---
title: Building Web Servers with Axum
author: adrian.ancona
layout: post
date: 2025-01-29
permalink: /2025/01/building-web-servers-with-axum/
tags:
  - programming
  - rust
  - server
---

In a previous post, we learned about [asynchronous programming with Tokio](/2024/04/asynchronous-programming-with-tokio/). This time, we are going to use Axum to build a server that uses Tokio as runtime.

## Hello world

Creating a simple server with Axum only requires a few lines:

```rust
#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(|| async { "Hello, World!" }));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

If we run this code, we will see a `Hello, World!` message if we visit `http://localhost:3000`.

<!--more-->

We are going to focus on the creation of the router:

```rust
let app = Router::new().route("/", get(|| async { "Hello, World!" }));
```

Here, we define our routes and the handlers for those routes. In this case, we are defining a single route (`/`), with an inline handler (`|| async { "Hello, World!" }`). We wrap the handler with `axum::routing::get`, so the handler is only executed for `GET` requests.

## Handlers

Handlers are functions that receive extractors and return a response.

## Extractors

Extractors are how information is made available to handlers. They need to implement `FromRequest` or `FromRequestParts`. Axum includes various useful extractors, but it is often useful to create our own.

One important thing to keep in mind about extractors is that some of them consume the request body, which is an asynchronous stream that can only be consumed once.

For this reason, there can only be one argument that implements `FromRequest`, and this must be the last one in a handler's arguments list. The rest of the arguments must implement `FromRequestParts`.

## Response

The return argument of the handler must be a type that implements `IntoResponse`. Axum provides implementations for many common types.

In the example above, our handler returns a `&'static str`, which Axum automatically transforms into a `200` status code with `content-type: text/plain; charset=utf-8`.

## Using extractors

Most of the time, we will want our handlers to access information from the request. We can achieve this by using different extractors.

A common use case is receiving a JSON request and doing something with this data:

```rust
async fn post_handler(body: String) -> String {
    format!("Request body was: {}", body)
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", post(post_handler));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

This time we are using an external function, instead of an inline handler. We are also using `axum::routing::post`, since this request will contain a body with data.

If we run this server and use this curl request:

```bash
curl -X POST http://localhost:3000 -d "Tacos"
```

We will get this as response:

```
Request body was: Tacos
```

The handler is very simple, but it's important to notice that the `body` argument is provided by [an extractor](https://github.com/tokio-rs/axum/blob/687f0148751c793f0ecfa916e6d6ce24df5faca3/axum-core/src/extract/request_parts.rs#L116). 

## Multiple extractors

As mentioned before, a handler can receive multiple extractors:

```rust
async fn post_handler(
    method: Method,
    headers: HeaderMap,
    body: String) -> String {
    format!("Body: {}, Method: {:?}, Headers: {:?}", body, method, headers)
}
```

If we run this server and use this curl request:

```bash
curl -X POST "http://localhost:3000" \
     -d "Tacos" \
     -H "Authorization: my-secret-key"
```

We will get something like this:

```
Body: Tacos, Method: POST, Headers: {"host": "localhost:3000", "user-agent": "curl/8.9.1", "accept": "*/*", "authorization": "my-secret-key", "content-length": "5", "content-type": "application/x-www-form-urlencoded"}
```

It is important to point out that the `Method` and `HeaderMap` extractors implement `FromRequestParts`, since they don't need to consume the body. For that reason, they need to be before the `String` extractor.

If we changed the order of the extractors:

```rust
async fn post_handler(
    body: String,
    method: Method,
    headers: HeaderMap) -> String {
    format!("Body: {}, Method: {:?}, Headers: {:?}", body, method, headers)
}
```

We would get a somewhat confusing error:

```
error[E0277]: the trait bound `fn(String, Method, HeaderMap) -> impl Future<Output = String> {post_handler}: Handler<_, _>` is not satisfied
   --> src/main.rs:16:45
    |
16  |     let app = Router::new().route("/", post(post_handler));
    |                                        ---- ^^^^^^^^^^^^ the trait `Handler<_, _>` is not implemented for fn item `fn(String, Method, HeaderMap) -> impl Future<Output = String> {post_handler}`
    |                                        |
    |                                        required by a bound introduced by this call
    |
    = note: Consider using `#[axum::debug_handler]` to improve the error message
``` 

This error doesn't really tell us, much, but it does suggest using `#[axum::debug_handler]`, which we can do like this:

```rust
#[axum::debug_handler]
async fn post_handler(
    body: String,
    method: Method,
    headers: HeaderMap) -> String {
    format!("Body: {}, Method: {:?}, Headers: {:?}", body, method, headers)
}
```

This time, we get a more useful error message:

```
error: `String` consumes the request body and thus must be the last argument to the handler function
 --> src/main.rs:9:11
  |
9 |     body: String,
  |           ^^^^^^
```

## JSON requests and responses

A common use case for Axum is creating REST APIs that use the JSON format for requests and responses. This can be easily done with Serde:

```rust
#[derive(Deserialize, Serialize)]
struct TheRequest {
    name: String,
}

#[derive(Deserialize, Serialize)]
struct TheResponse {
    greeting: String,
}

#[axum::debug_handler]
async fn post_handler(Json(req): Json<TheRequest>) -> Json<TheResponse> {
    Json(TheResponse {
        greeting: format!("Hello {}", req.name)
    })
}
```

If we run this server and issue this request:

```bash
curl -X POST "http://localhost:3000" \
     -d '{"name":"Jose"}' \
     -H 'Content-Type: application/json'
```

We will get this back:

```
{"greeting":"Hello Jose"}
```

Notice how we use `Json`, to get the data from the request:

```rust
post_handler(Json(req): Json<TheRequest>)
```

And to return the response:

```rust
Json(TheResponse {
    greeting: format!("Hello {}", req.name)
})
```

## Errors

So far, we have returned a `200` code for all requests, but in the real world, we will often encounter errors. Take this handler, as an example:

```rust
async fn handler() {
    panic!("Some error");
}
```

If a client calls this handler, they will get an empty response with no status code. This is not a good user experience, so we could instead have a handler that returns a status code:

```rust
async fn internal_error() -> StatusCode {
    StatusCode::INTERNAL_SERVER_ERROR
}
```

It is important to understand that this works because `StatusCode` implements [IntoResponse](https://docs.rs/axum/latest/axum/response/trait.IntoResponse.html).

Most of the time we will have endpoints that sometimes succeed and sometimes fail, so it's common to return a result:

```rust
async fn with_result() -> Result<String, StatusCode> {
    Err(StatusCode::INTERNAL_SERVER_ERROR)
}
```

In these cases, we have to remember the `IntoResponse` implementation for the internal types will be used, if the response is `Ok` or `Err`. That means, the previous example will return a `500` status code, but the following example will return a `200` regardless of the use of `Err`:

```rust
async fn with_result() -> Result<String, StatusCode> {
    Err(StatusCode::OK)
}
```

If we want more control over our responses, we might want to use our own type, that implements `IntoResponse`.

```rust
pub enum AppError {
    ServerError(String),
    ClientError(Vec<String>),
}

#[derive(Serialize)]
struct ErrorResponse {
    data: Vec<String>,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        match self {

            AppError::ServerError(msg) => {
                return (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(ErrorResponse {
                        data: vec!(msg),
                    }),
                ).into_response();
            }
            AppError::ClientError(messages) => {
                return (
                    StatusCode::BAD_REQUEST,
                    Json(ErrorResponse {
                        data: messages,
                    }),
                ).into_response();
            }
        };
    }
}
```

We created an `AppError` enum that returns a different status code based on the value of the enum. The `ErrorResponse` struct gives more information to the clients about the error.

Now, we can create a handler that uses this type. For example:

```rust
async fn custom_server_error() -> Result<String, AppError> {
    Err(AppError::ServerError("Our system is down".to_string()))
}
```

## Conclusion

In this article, we learned about the most important building blocks of an Axum server. With this knowledge, we will be able to build a variety of HTTP servers to accomplish multiple tasks.

As usual, you can find full code samples in [my examples' repo](https://github.com/soonick/ncona-code-samples/tree/master/building-web-servers-with-axum).
