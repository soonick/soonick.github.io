---
title: Building Google Cloud Storage Signed URLs
author: adrian.ancona
layout: post
# date: 2025-10-08
# permalink: /2025/10/building-google-cloud-storage-signed-urls/
tags:
  - gcp
  - programming
  - rust
---

Signed URLs can be used to allow temporary access to private objects stored in Google Cloud Storage. In this article, we are going to learn how to generate a signed URL using Rust, but the steps should be easily translatable to your language of choice.

## The final result

Google provides documentation on [how to generate a signed URL](https://cloud.google.com/storage/docs/access-control/signing-urls-manually), but even following those instructions, it took me a few tries to get it right, so I'm going to try to give an explanation here.

A signed URL looks like this:

```bash
https://storage.googleapis.com/<BUCKET_NAME>/<OBJECT_PATH>?<CANONICAL_QUERY_STRING>&X-Goog-Signature=<SIGNATURE>
```

<!--more-->

Where the values between &lt;&gt; should be replaced:

- BUCKET_NAME - The name of the bucket we are accessing
- OBJECT_PATH - The name of the object (full path, if it's inside folders)
- CANONICAL_QUERY_STRING - We'll cover this in the next section 
- SIGNATURE - We'll explain how to generate this later in the article

## Canonical query string

This is a list of query string parameters that specify a few things that will be used in our signed request. The minimal required parameters are:

- X-Goog-Algorithm - Must be either `GOOG4-RSA-SHA256` or `GOOG4-HMAC-SHA256`
- X-Goog-Credential - A URL encoded representation of the credentials and scope used to access the object (We look into this in more detail in the next section)
- X-Goog-Date - The date and time when the signed URL becomes valid
- X-Goog-Expires - Number of seconds after `X-Goog-Date` when the URL expires
- X-Goog-SignedHeaders -  List of headers that were used when generating the signature. In our case, this will always be set to `host`

One important thing to keep in mind is that the query string parameters must appear in alphabetical order.

## X-Goog-Credential

The `X-Goog-Credential` field must be set to a url encoded version of:

```bash
<SERVICE_ACCOUNT_EMAIL>/<SCOPE>
```

Where:

- SERVICE_ACCOUNT_EMAIL - The email for the service account. This can be seen in Google Cloud Console. Looks something like this: `my-user@project-name-32844.iam.gserviceaccount.com`
- SCOPE - `<CURRENT_DATE(%Y/m/d)>/auto/storage/goog4_request`. For example: `2025/9/26/auto/storage/goog4_request`

A full value for `X-Goog-Credential` looks like this:

```bash
my-user%40project-name-32844.iam.gserviceaccount.com%2F2025%2F9%2F26%2Fauto%2Fstorage%2Fgoog4_request%0A
```

## Canonical request

The signature is generated with the use of the service account's private key on a `canonical request`. The canonical request looks like this:

```bash
HTTP_VERB
PATH_TO_RESOURCE
CANONICAL_QUERY_STRING
CANONICAL_HEADERS

SIGNED_HEADERS
PAYLOAD
```

Some of them are self-explanatory, for the others, it's probably easier to look at a real world example:

```bash
GET
/bucket/object.jpg
X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=my-user%40project-name-32844.iam.gserviceaccount.com%2F2025%2F9%2F26%2Fauto%2Fstorage%2Fgoog4_request%0A&X-Goog-Date=20250926T13:03:23Z&X-Goog-Expires=3600&X-Goog-SignedHeaders=host
host:storage.googleapis.com

host
UNSIGNED-PAYLOAD
```

## Signing

There are a couple of ways to sign the request. In this example, we'll use the `signBlob` endpoint from `https://iamcredentials.googleapis.com`. This endpoint expects a post request with this body:

```json
{
    "payload": "SIGN_REQUEST_PAYLOAD"
}
```

Where SIGN_REQUEST_PAYLOAD is a Base 64 encoded version of the following:

```bash
GOOG4-RSA-SHA256
<Same as X-Goog-Date>
<Only the scope part of X-Goog-Credential>
<Hexadecimal representation of a hash (Using the algorithm specified in the first line) of the canonical request>
```

If this sounds a little confusing, the code, should make it more obvious.

## The code

There are quite a few steps, and some of them might be a little unclear, so lets look at each of them in code.

Canonical query string:

```rust
let now = Utc::now();
let now_iso = now.format("%Y%m%dT%H%M%SZ");

// There are a few ways we can get the service account email, but that's not very
// important for the generation of the signature. If you want to see one one way
// to do this, take a look at the full working example (link in the conclusion)
let email = get_service_account_email().await?

let credential_scope = format!("{}/auto/storage/goog4_request", now.format("%Y%m%d"));
let goog_credential = format!("{}/{}", email, credential_scope);
let encoded_credential: String =
    form_urlencoded::byte_serialize(goog_credential.as_bytes()).collect();
let canonical_query_string = format!(
    "X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential={}&X-Goog-Date={}&X-Goog-Expires={}&X-Goog-SignedHeaders=host",
    encoded_credential,
    now_iso,
    PUBLIC_URL_EXPIRATION_SECS,
);
```

The important things to remember here are that the query string parameters must be in alphabetical order, and we must URL-encode the `X-Goog-Credential`.

Once we have the canonical query string, generating the canonical request is easy:

```rust
let path_to_resource = format!("/{}/{}", BUCKET_NAME, OBJECT_PATH);
let canonical_request = format!(
    "GET\n{}\n{}\nhost:storage.googleapis.com\n\nhost\nUNSIGNED-PAYLOAD",
    path_to_resource, canonical_query_string,
);
```

Now, we generate the payload for the `signBlob` request:

```rust
let string_to_sign = format!(
    "GOOG4-RSA-SHA256\n{}\n{}\n{}",
    now_iso,
    credential_scope,
    hex::encode(Sha256::digest(canonical_request))
);
```

We proceed to call `signBlob`:

```rust
#[derive(Serialize)]
struct SignBlobRequest {
    payload: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct SignBlobResponse {
    signed_blob: String,
}

let sign_url = format!(
    "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/{}:signBlob",
    email
);

// You can see the implementation in the full example (link in the conclusion)
let token = get_oauth2_token().await?

let client = Client::new();
let sign_resp = client
    .post(&sign_url)
    .bearer_auth(&token)
    .json(&SignBlobRequest {
        payload: BASE64_STANDARD.encode(string_to_sign.as_bytes()),
    })
    .send()
    .await?

if !sign_resp.status().is_success() {
    panic!(
        "Sign blob request failed with status: {}. Response: {:?}",
        sign_resp.status(),
        sign_resp.text().await
    );
}

let sign_resp: SignBlobResponse = sign_resp.json().await?

let signature = hex::encode(BASE64_STANDARD.decode(&sign_resp.signed_blob)?);
```

And create the final signed URL:

```rust
let url = format!(
    "https://storage.googleapis.com/{}/{}?{}&X-Goog-Signature={}",
    BUCKET_NAME, OBJECT_PATH, canonical_query_string, signature
);
```

## Conclusion

Generating a signed URL shouldn't be very complicated, but there are quite a few steps, and it's hard to find where the mistakes are when things don't work. It took me a few tries to get mine to work, so I'm sharing my code with the hope it helps others.

As usual, you can find a working version of the code in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/building-google-cloud-storage-signed-urls).
