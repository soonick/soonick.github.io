---
id: 4464
title: Google auth with Beego
date: 2017-10-26T02:52:58+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4464
permalink: /2017/10/google-auth-with-beego/
categories:
  - Go
tags:
  - authentication
  - golang
  - programming
  - security
---
As I move forward with my Beego project, I have reached a point where I need to authenticate my users. In the flow that I&#8217;m looking for, the client (web app, mobile app, etc&#8230;), will communicate directly with the Auth provider (Google, Facebook, etc&#8230;) and get a JWT. The only thing the server needs to do is validate the JWT. If the validation succeeds, it means the user is logged in.

If you are not familiar with JWT, you can read my previous article that explains [how JWT works](https://ncona.com/2015/02/consuming-a-google-id-token-from-a-server/).

## Authentication flow

Since the authentication with Google is going to happen entirely on the client, the server logic becomes a lot simpler. For my application, all endpoints will require the user to be logged in, so I will create a middleware to verify this. The middleware will expect a valid JWT in the Authorization header. If this requirement is not met, the server will return a 401.

<!--more-->

When a request comes with a valid JWT there are two possible scenarios: New user or existing user. To keep track of existing users we will need a database. In the simplest scenario we need three fields in the user table:

  * id &#8211; An internal id to be used inside the application
  * issuer &#8211; The name of the auth provider. In the case of Google, the value is: accounts.google.com
  * issuer_id &#8211; The id given to this user by the issuer

The id field should be a unique key on the user table and will be used for relationships with other tables. issuer\_id can be repeated, but the combination of issuer and issuer\_id are unique (A JWT with google id of 1234 will always resolve to the same user). 

Now that we have our user table ready, we can decide what to do when we receive a valid request. When we receive a request with a valid JWT, we will first query for a user by issuer and issuer_id (this information is in the JWT). If the user is found, you can just proceed using the correct access control for that user. If the user is not found, we add it to the database and then proceed normally.

## Creating a middleware

Middlewares in Beego are known as [Filters](https://beego.me/docs/mvc/controller/filter.md). We can add our filter in our main.go file for now. This is how the main function looks after adding the filter:

```go
func main() {
    if beego.BConfig.RunMode == "dev" {
        beego.BConfig.WebConfig.DirectoryIndex = true
        beego.BConfig.WebConfig.StaticDir["/swagger"] = "swagger"
    }

    var AuthFilter = func(ctx *context.Context) {
        // If token valid, continue, else return 401
    }

    beego.InsertFilter("/*", beego.BeforeRouter, AuthFilter)

    beego.Run()
}
```

If you get an error saying that context is not defined, you will need to add this to your imports:

```
"github.com/astaxie/beego/context"
```

For actually validating the JWT I&#8217;m going to use [coreos&#8217; go-oidc library](https://github.com/coreos/go-oidc). My AuthFilter function ended up looking something like this:

```go
var AuthFilter = func(ctx *context.Context) {
    // The Authorization header should come in this format: Bearer <jwt>
    // The first thing we do is check that the JWT exists
    header := strings.Split(ctx.Input.Header("Authorization"), " ")
    if len(header) != 2 || header[0] != "Bearer" {
        ctx.Abort(401, "Not authorized")
    }

    // I had to do something hacky here because beego uses its own
    // context instead of the standard one that most libraries use.
    // I imported context with the name netctx:
    // import netctx "context"
    // oidc uses the context to communicate with the auth provider.
    // I just created a new context to satisfy this requirement
    c := netctx.TODO()
    provider, err := oidc.NewProvider(c, "https://accounts.google.com")
    if err != nil {
        ctx.Abort(500, "Could not create google provider")
    }

    var verifier = provider.Verifier(&oidc.Config{ClientID: "<your-client-id>"})

    // Parse and verify ID Token payload.
    parsedToken, err := verifier.Verify(c, header[1])
    if err != nil {
        ctx.Abort(401, "Not authorized")
    }

    // User is valid. We use ReadOrCreate to create a new user or get
    // the id of the user that matches the issuer and issuer_id
    o := orm.NewOrm()
    user := models.User{
        Issuer: parsedToken.Issuer,
        IssuerId: parsedToken.Subject,
    }
    _, id, err := o.ReadOrCreate(&user, "Issuer", "IssuerId")
    if err != nil {
        ctx.Abort(500, "Error retrieving authenticated user from DB")
    }

    // User has been correctly authenticated. Add the id of the user to the
    // context so controllers can use it if neccesary
    ctx.Input.SetData("userId", id)
}
```

Since we are adding the user id to the context, we can then retrieve it from a controller if needed:

```go
controller.Ctx.Input.GetData("userId")
```

With just a few lines of code we have added authentication to our application.
