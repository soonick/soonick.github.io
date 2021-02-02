---
title: Google sign-in with Golang
author: adrian.ancona
layout: post
date: 2021-02-10
permalink: /2021/02/google-sign-in-with-golang
tags:
  - application_design
  - authentication
  - golang
  - google
  - programming
  - security
---

In this article we are going to explore how to implement Google sign-in on a Golang server.

## Google sign-in

When we talk about implementing Google Sign-in, we are referring to using the OpenID Connect protocol to verify a user is who they say they are.

I'm not going to go into the depths of the protocol, but in broad terms, these are the steps we care about:
- Client gets a JWT (usually with the help of a library provided by google)
- Client sends this JWT to our server
- Our server validates the JWT

In this post we are going to focus on the validation of the JWT.

## Validating the JWT

The `go-oidc` library implements all the hairy bits of the OpenID protocol for us. We need to start by creating a provider that will connect to Google's server:

```go
googleOidcProvider, err = oidc.NewProvider(ctx, "https://accounts.google.com")
if err != nil {
  fmt.Println("Failed to create provider")
}
```

The JWT is usually sent as part of an `Authorization` header on this format:

```bash
Authorization: Bearer <JWT data>
```

To get the JWT from the header:

```go
authHeader, ok := request.Header["Authorization"]
if !ok {
  fmt.Println("Authorization header not found")
}

// Headers are arrays, so we have to do this :(
authHeaderVal := authHeader[0]

// We expect the header to be "Bearer <JWT data>"
headerParts := strings.Split(authHeaderVal, " ")
if len(headerParts) != 2 {
  fmt.Println("Authorization header is malformed")
}

jwt := headerParts[1]
```

Now that we have the jwt, we only need to validate it:

```go
// GA_CLIENT_ID is the Oauth client id provided to our app by Google
// We can creat one following these instructions: https://support.google.com/cloud/answer/6158849
verifier := googleOidcProvider.Verifier(&oidc.Config{ClientID: os.Getenv("GA_CLIENT_ID")})

token, err := verifier.Verify(ctx, jwt)
if err != nil {
  fmt.Println("JWT is not valid")
}

fmt.Println("JWT is valid")
```

Once we know the JWT is valid, we can save the user in a database, give them access to some resources they own, or any other thing that makes sense for our application.

## Conclusion

Allowing users to sign into our server using JWT is very easy by using the right tools.
