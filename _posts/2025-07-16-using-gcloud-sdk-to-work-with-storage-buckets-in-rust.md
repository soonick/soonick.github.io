---
title: Using gcloud-sdk to Work with Storage Buckets in Rust
author: adrian.ancona
layout: post
date: 2025-07-16
permalink: /2025/07/using-gcloud-sdk-to-work-with-storage-buckets-in-rust/
tags:
  - gcp
  - programming
  - rust
---

## gcloud-sdk

At the time of this writing, there is no official Google Cloud library for rust. Google started working on [google-cloud-rust](https://github.com/googleapis/google-cloud-rust), but it's still under development.

The most popular alternative seems to be [gcloud-sdk](https://github.com/abdolence/gcloud-sdk-rs), so that's what we'll be using. This SDK uses [tonic](https://github.com/hyperium/tonic) to build the gRPC clients, so [a little familiarity with tonic](/2025/07/introduction-to-tonic-for-grpc-in-rust/), might be helpful.

Since we are going to focus on the Storage API, we need to add this dependency to our `Cargo.toml` file:

```toml
gcloud-sdk = { version = "0.27", features = ["google-storage-v2" ] }
```

<!--more-->

## Storage API

Google stores their official gRPC APIs in the [googleapis repo](https://github.com/googleapis/googleapis). We are interested in v2 of the Storage API, which is [defined here](https://github.com/googleapis/googleapis/blob/master/google/storage/v2/storage.proto).

We'll only cover some of the methods, to get familiar with the API.

## Building the client

Before making requests, we need to create a client that handles auth correctly. For this, we will first need to create a JSON API key with the correct permissions for the operations we want to perform.

Generate one from the Google Cloud Console and save it to: `/keys/key.json`, we will need to set the environment variable `GOOGLE_APPLICATION_CREDENTIALS` to this value.

```
GOOGLE_APPLICATION_CREDENTIALS=/keys/key.json
```

To create the client:

```rust
let gcs : GoogleApi<StorageClient<GoogleAuthMiddleware>> =
        match GoogleApi::from_function(StorageClient::new, "https://storage.googleapis.com", None).await {
    Ok(c) => c,
    Err(_) => panic!("Oh no!")
};
```

The client will automatically load the file specified by `GOOGLE_APPLICATION_CREDENTIALS` and use it for authentication.

Note how we specify which service we want to connect to, by using the `StorageClient` type, as well as by pointing to the correct URL for the service: `https://storage.googleapis.com`.

## Working with buckets

To create a bucket, we need the ID of the project where we want to create it, as well as a name for the bucket. Bucket names need to be unique among all google projects in the world, so we need to choose a distinctive name.

```rust
let bucket_id = "some-random-bucket-name-582";
let bucket = Bucket {
    project : format!("projects/{}", PROJECT_ID),
    ..Default::default()
};
let mut request = Request::new(CreateBucketRequest {
    parent: "projects/_".to_string(),
    bucket_id: bucket_id.clone(),
    bucket: Some(bucket),
    ..Default::default()
});

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}", PROJECT_ID)).unwrap(),
);

match gcs
    .get()
    .create_bucket(request)
    .await {
        Ok(_) => {
            println!("Bucket {} created succesfully", bucket_id);
        },
        Err(e) => {
            panic!("Error creating bucket. Code: {} Full response: {:?}", e.code(), e)
        }
    };
```

The code is not very complicated, but there are some things worth mentioning.

```rust
let bucket = Bucket {
    project : format!("projects/{}", PROJECT_ID),
    ..Default::default()
};
```
When we create the `Bucket` struct, we need to specify the project. `..Default::default()` can be used to populate the default values for the fields not defined when creating a struct.

```rust
let mut request = Request::new(CreateBucketRequest {
    parent: "projects/_".to_string(),
    bucket_id: bucket_id.clone(),
    bucket: Some(bucket),
    ..Default::default()
});
```

The `parent` field must be set to exactly: `projects/_`. The `bucket_id` is used to specify the name of the bucket. The `name` field of the `Bucket` struct must be left empty.

```rust
request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}", PROJECT_ID)).unwrap(),
);
```

All the APIs we are going to be using require us to set `x-goog-request-params` header. What it needs to be set to varies depending on the API. The easiest way to figure it out is to read the error messages in the response.

To list all buckets:

```rust
let mut request = Request::new(ListBucketsRequest {
    parent: format!("projects/{}", PROJECT_ID),
    ..Default::default()
});

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}", PROJECT_ID)).unwrap(),
);

match gcs
    .get()
    .list_buckets(request)
    .await {
        Ok(r) => {
            println!("Buckets:");
            for b in r.get_ref().buckets.clone() {
                println!("{}", b.name);
            }
        },
        Err(e) => {
            panic!("Error listing buckets. Code: {} Full response: {:?}", e.code(), e)
        }

    };
```

To get a specific bucket:

```rust
let mut request = Request::new(GetBucketRequest {
    name: bucket_id.clone(),
    ..Default::default()
});

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}", PROJECT_ID)).unwrap(),
);

match gcs
    .get()
    .get_bucket(request)
    .await {
        Ok(r) => {
            println!("Bucket retrieved: {:?}", r);
        },
        Err(e) => {
            panic!("Error getting bucket. Code: {} Full response: {:?}", e.code(), e)
        }
    };
```

To delete an empty bucket:

```rust
let mut request = Request::new(DeleteBucketRequest {
    name: format!("projects/_/buckets/{}", bucket_id),
    ..Default::default()
});

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}", PROJECT_ID)).unwrap(),
);

match gcs
    .get()
    .delete_bucket(request)
    .await {
        Ok(r) => {
            println!("Bucket {} deleted", bucket_id);
        },
        Err(e) => {
            panic!("Error deleting bucket. Code: {} Full response: {:?}", e.code(), e)
        }
    };
```

We can see that they are all very similar, the only things that change are the Request, Response and the method name.

## Working with objects

Listing objects in a bucket and deleting them, is straightforward:

```rust
let mut request = Request::new(ListObjectsRequest {
    parent: format!("projects/_/buckets/{}", bucket_id),
    ..Default::default()
});

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}&bucket=projects/_/buckets/{}", PROJECT_ID, bucket_id)).unwrap(),
);

let mut objects = vec![];
match gcs
    .get()
    .list_objects(request)
    .await {
        Ok(r) => {
            println!("Objects found in bucket {}:", bucket_id);
            for o in &r.get_ref().objects {
                println!("{}:", o.name);
            }
        },
        Err(e) => {
            panic!("Error listing objects in bucket. Code: {} Full response: {:?}", e.code(), e)
        }
    };


let mut request = Request::new(DeleteObjectRequest {
    bucket: format!("projects/_/buckets/{}", bucket_id),
    object: object_name.clone(),
    ..Default::default()
});

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}&bucket=projects/_/buckets/{}", PROJECT_ID, bucket_id)).unwrap(),
);

match gcs
    .get()
    .delete_object(request)
    .await {
        Ok(_) => {
            println!("Object {} deleted.", object_name);
        },
        Err(e) => {
            panic!("Error deleting object {}. Code: {} Full response: {:?}", object_name, e.code(), e)
        }
    };
```

The only things worth noting are that the bucket name needs to be specified using this format: `projects/_/buckets/{}` and the `x-goog-request-params` needs to also include the bucket name.

Uploading objects is a little trickier. There are basically 3 strategies:

- Upload the whole object at once - Easy to use, but might use too much memory if the object is large
- Stream upload - Can be used to upload larger objects without using too much memory
- Resumable upload - Can be used to upload very large objects

Let's start with the simplest scenario, uploading an object all at once:

```rust
let file_bytes: Vec<u8> = match fs::read(LOCAL_FILE_NAME) {
    Ok(b) => b,
    Err(e) => {
        panic!("Error reading file bytes: {:?}", e);
    }
};

let write_request = WriteObjectRequest {
    first_message: Some(FirstMessage::WriteObjectSpec(WriteObjectSpec {
        resource: Some(Object {
            name: file_name.to_string(),
            bucket: format!("projects/_/buckets/{}", bucket_id),
            ..Default::default()
        }),
        ..Default::default()
    })),
    data: Some(Data::ChecksummedData(ChecksummedData {
        content: file_bytes,
        ..Default::default()
    })),
    finish_write: true,
    ..Default::default()
};
let req_stream = stream::iter(vec![write_request]);
let mut request = Request::new(req_stream);

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}&bucket=projects/_/buckets/{}", PROJECT_ID, bucket_id)).unwrap(),
);

match gcs
    .get()
    .write_object(request)
    .await {
        Ok(r) => {
            println!("Object written: {:?}", r);
        },
        Err(e) => {
            panic!("Error writing object. Code: {} Full response: {:?}", e.code(), e)
        }

    };
```

We start by reading the whole file to memory:

```rust
let file_bytes: Vec<u8> = match fs::read(LOCAL_FILE_NAME) {
    Ok(b) => b,
    Err(e) => {
        panic!("Error reading file bytes: {:?}", e);
    }
};
```

For the `WriteObjectRequest` we specify the `name` and parent `bucket` in the `first_message` field. Since we are sending the whole file, we need to set `finish_write` to `true`.

```rust
let write_request = WriteObjectRequest {
    first_message: Some(FirstMessage::WriteObjectSpec(WriteObjectSpec {
        resource: Some(Object {
            name: file_name.to_string(),
            bucket: format!("projects/_/buckets/{}", bucket_id),
            ..Default::default()
        }),
        ..Default::default()
    })),
    data: Some(Data::ChecksummedData(ChecksummedData {
        content: file_bytes,
        ..Default::default()
    })),
    finish_write: true,
    ..Default::default()
};
```

The `write_object` API requires a stream, so we must convert this request to a stream even when it will be a single request:

```rust
let req_stream = stream::iter(vec![write_request]);
let mut request = Request::new(req_stream);
```

The rest is similar to other APIs.

For the streaming upload, we can use this code:

```rust
let bucket_id_for_stream = bucket_id.clone(); // clone for the stream
let req_stream = stream! {
    let mut offset = 0;
    let mut finish = false;
    let mut buffer = vec![0u8; CHUNK_SIZE];
    let mut file = match std::fs::File::open(LOCAL_FILE_NAME) {
        Ok(f) => f,
        Err(e) => {
            panic!("Error openning file: {:?}", e);
        }
    };

    while !finish {
        let n = match file.read(&mut buffer) {
            Ok(r) => r,
            Err(e) => {
                panic!("Error reading file: {:?}", e);
            }
        };

        if n == 0 || n < CHUNK_SIZE {
            finish = true;
        }

        let fm = if offset == 0 {
            Some(FirstMessage::WriteObjectSpec(WriteObjectSpec {
                resource: Some(Object {
                    name: file_name.to_string(),
                    bucket: format!("projects/_/buckets/{}", bucket_id_for_stream),
                    ..Default::default()
                }),
                ..Default::default()
            }))
        } else {
            None
        };

        let request = WriteObjectRequest {
            write_offset: offset,
            first_message: fm,
            data: Some(Data::ChecksummedData(ChecksummedData {
                content: buffer[..n].to_vec(),
                ..Default::default()
            })),
            finish_write: finish,
            ..Default::default()
        };

        offset += n as i64;
        yield request;
    }
};

let mut request = Request::new(req_stream);

request.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}&bucket=projects/_/buckets/{}", PROJECT_ID, bucket_id)).unwrap(),
);

match gcs
    .get()
    .write_object(request)
    .await {
        Ok(r) => {
            println!("Object written: {:?}", r);
        },
        Err(e) => {
            panic!("Error writing object. Code: {} Full response: {:?}", e.code(), e)
        }
    };
```

We use the [stream!](https://docs.rs/async-stream/latest/async_stream/) macro to create a stream that will yield a specific number of bytes from a file until it reaches the end. Every time the stream is called, we populate our buffer:

```rust
let n = match file.read(&mut buffer) {
    Ok(r) => r,
    Err(e) => {
        panic!("Error reading file: {:?}", e);
    }
};
```

On the first request, we set the `name` of the object on the `first_message` field. For all other requests, we set it to `None`. The `finish_write` field is only set to `true` for the last request.

We create the request based on this stream, and everything else is the same.

```rust
let mut request = Request::new(req_stream);
```

Using a resumable update is similar to using streams, but it can be used for larger files, since the upload of the chunks doesn't need to be done in the same process or machine:

```rust
let mut first_req = Request::new(StartResumableWriteRequest {
    write_object_spec: Some(WriteObjectSpec {
        resource: Some(Object {
            name: file_name.to_string(),
            bucket: format!("projects/_/buckets/{}", bucket_id),
            ..Default::default()
        }),
        ..Default::default()
    }),
    ..Default::default()
});

first_req.metadata_mut().insert(
    "x-goog-request-params",
    MetadataValue::try_from(format!("project=projects/{}&bucket=projects/_/buckets/{}", PROJECT_ID, bucket_id)).unwrap(),
);

let resumable_id = match gcs
    .get()
    .start_resumable_write(first_req)
    .await {
        Ok(r) => {
            println!("Started resumable write with id: {}", r.get_ref().upload_id);
            r.get_ref().upload_id.clone()
        },
        Err(e) => {
            panic!("Error starting resumable write. Code: {} Full response: {:?}", e.code(), e)
        }
    };

let mut finish = false;
let mut offset = 0;
let mut buffer = vec![0u8; RESUMABLE_CHUNK_SIZE];
let mut file = match std::fs::File::open(LOCAL_FILE_NAME) {
    Ok(f) => f,
    Err(e) => {
        panic!("Error openning file: {:?}", e);
    }
};

while !finish {
    let n = match file.read(&mut buffer) {
        Ok(r) => r,
        Err(e) => {
            panic!("Error reading file: {:?}", e);
        }
    };
    println!("Bytes read: {}, offset: {}", n, offset);

    if n == 0 || n < RESUMABLE_CHUNK_SIZE {
        finish = true;
    }

    let write_request = WriteObjectRequest {
        write_offset: offset,
        first_message: Some(FirstMessage::UploadId(resumable_id.clone())),
        data: Some(Data::ChecksummedData(ChecksummedData {
            content: buffer[..n].to_vec(),
            ..Default::default()
        })),
        finish_write: finish,
        ..Default::default()
    };

    let req_stream = stream::iter(vec![write_request]);
    let mut request = Request::new(req_stream);

    request.metadata_mut().insert(
        "x-goog-request-params",
        MetadataValue::try_from(format!("project=projects/{}&bucket=projects/_/buckets/{}", PROJECT_ID, bucket_id)).unwrap(),
    );

    match gcs
        .get()
        .write_object(request)
        .await {
            Ok(_) => {
                println!("Object chunk written. Finished: {}", finish);
            },
            Err(e) => {
                panic!("Error writing object chunk. Code: {} Full response: {:?}", e.code(), e)
            }
        };

    offset += n as i64;
}
```

We need to start by calling `start_resumable_write`. This will give us an ID that we can use to upload the chunks. When creating the `WriteObjectRequest` we set `first_message` to this ID.

This time, instead of creating a stream using the `stream!` macro, we just send a separate request for each chunk.

## Conclusion

I wasn't able to find any example online of how to use `gcloud-sdk` to manage buckets and objects, so I had to do a little trial and error. Luckily, after getting familiar with `tonic`, it's mostly a matter of finding the different gRPC methods and messages for the API.

Figuring out how to upload objects took some time, but these 3 options should be enough for most scenarios.

As usual, you can find a working version of the code in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/using-gcloud-sdk-to-work-with-storage-buckets-in-rust).
