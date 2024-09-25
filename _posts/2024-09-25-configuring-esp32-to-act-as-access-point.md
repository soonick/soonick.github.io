---
title: Configuring ESP32 to act as Access Point
author: adrian.ancona
layout: post
date: 2024-09-25
permalink: /2024/09/configuring-esp32-to-act-as-access-point/
tags:
  - c++
  - esp32
  - programming
---

In a previous article we learned how to [use ESP32 as a WiFi client](/2024/09/making-http-https-requests-with-esp32/). If you haven't I recommend you take a look at that article, since there are some steps in common that I'm not going to cover in much depth here.

## Initialize WiFi

When we are creating a client or and Access Point, we need to initialize NETIF and create the default event loop:

```cpp
ESP_ERROR_CHECK(esp_netif_init());
ESP_ERROR_CHECK(esp_event_loop_create_default());
```

To initialize our WiFi interface as an Access Point, we need to call:

```cpp
esp_netif_create_default_wifi_ap();
```

<!--more-->

We initialize the WiFi driver by calling `esp_wifi_init`:

```cpp
wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
cfg.nvs_enable = 0;
esp_wifi_init(&cfg);
```

We set `cfg.nvs_enable` to `0`, so the access point doesn't depend on NVS.

The next step is to set the operating mode of the WiFi driver:

```cpp
ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_AP));
```

We are now ready to set the SSID and password, and start the Access Point:

```cpp
wifi_config_t wifi_config = {
    .ap = {.ssid = EXAMPLE_ESP_WIFI_SSID,
           .ssid_len = strlen(EXAMPLE_ESP_WIFI_SSID),
           .password = EXAMPLE_ESP_WIFI_PASS,
           .max_connection = EXAMPLE_MAX_STA_CONN,
           .authmode = WIFI_AUTH_WPA_WPA2_PSK},
};
ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_AP, &wifi_config));
ESP_ERROR_CHECK(esp_wifi_start());
```

## Web server

Often, we start an Access Point, so users can connect to a configuration portal. To serve this portal we need a web server.

We can start a web server with `httpd_start`:

```cpp
httpd_handle_t server = NULL;
httpd_config_t config = HTTPD_DEFAULT_CONFIG();
ESP_ERROR_CHECK(httpd_start(&server, &config));
```

If the server is successfully started, the `server` variable will be set to it.

Let's create a simple HTML file that our server will show:

```cpp
<!DOCTYPE html>
<html>
  <head>
    <title>Hello world</title>
  </head>
  <body>
    <h1>Hello World!</h1>
  </body>
</html>
```

We'll call this file `hello.html`.

We can then use the `EMBED_FILES` CMake macro to add this file to our firmware:

```cmake
idf_component_register(SRCS "main.c"
                       INCLUDE_DIRS "."
                       EMBED_FILES hello.html)
```

The macro saves the file in the firmware and makes it possible to get a pointer to the start of the file and a pointer to the end:

```cpp
extern const char hello_start[] asm("_binary_hello_html_start");
extern const char hello_end[] asm("_binary_hello_html_end");
```

We can use these pointers to build a handler function:

```cpp
static esp_err_t hello_handler(httpd_req_t *req) {
  const uint32_t hello_len = hello_end - hello_start;

  httpd_resp_set_type(req, "text/html");
  httpd_resp_send(req, hello_start, hello_len);

  return ESP_OK;
}
```

Once we have the handler function we can build a `httpd_uri_t`, where we can define the path and HTTP method:

```cpp
static const httpd_uri_t hello = {
    .uri = "/", .method = HTTP_GET, .handler = hello_handler};
```

Finally, we need to register the handler in our server:

```cpp
httpd_register_uri_handler(server, &hello);
```

## Getting the Access Point's IP address

For now, we're going to use our Access Point's IP to connect to it. To get the IP address and print it to the serial monitor, we can use this code:

```cpp
esp_netif_ip_info_t ip_info;
esp_netif_get_ip_info(esp_netif_get_handle_from_ifkey("WIFI_AP_DEF"),
                      &ip_info);
char ip_addr[16];
inet_ntoa_r(ip_info.ip.addr, ip_addr, 16);
ESP_LOGI(TAG, "Set up softAP with IP: %s", ip_addr);
```

If we flash this code to an ESP32 and start the serial monitor. We can use a client (computer or phone) to connect to our Access Point and visit its IP address to see our page.

## DNS server

Most users are not familiar with IP addresses, so having our users type an IP address to access our configuration server is not a good experience. A better alternative is to start a DNS server that will act as a captive portal, so all URL requests are directed to the Access Point.

In order to do this part, we will need to understand a little of how the DNS protocol works.

When a user types a domain name in the browser (e.g. ncona.com), the browser sends a DNS request to port `53` of the access point it's using to connect to the internet. The AP might be configured to forward the request to a specific DNS server or to forward the request to the Internet Service Provider (ISP).

DNS uses UDP, so let's first look at how a UDP package looks:

[<img src="/images/posts/udp-package.png" alt="UPD package" />](/images/posts/udp-package.png)

- **Source port** - The port the request comes from. For requests from client to server, this port will be random. For requests from the server this port will be 53
- **Destination port** - Same as `source port` but reversed
- **Length** - The number of bytes of the UDP header plus the UDP data section. This must be at least `8`, since that's the number of required bytes for a valid header
- **Checksum** - Checksum of the header and data. [RFC 768](https://datatracker.ietf.org/doc/html/rfc768) defines how it should be computed. For IPv4 the checksum is optional (all zeros)
- **Data** - This will contain the DNS request or response

The DNS request looks like this:

[<img src="/images/posts/dns-request.png" alt="DNS request" />](/images/posts/dns-request.png)

- **Transaction ID** - An ID created by the client. It's used to match requests with responses provided by the server
- **QR** - Set to 0 if the message is a query. Set to 1 if the message is a reply
- **Opcode** - Set to 0 for a standard query. Set to 1 for an inverse query. Set to 2 for a status request
- **AA** - Set to 1 if the response comes from an authoritative server (The original DNS server for the domain)
- **TC** - Set to 1 if this message was truncated because it was too long for UDP. When this happens, the client needs to switch to TCP to get the full response
- **RD** - If the client sets it to 0, the DNS server will only provide a response if it's authoritative, or it has a cached response
- **RA** - If the server sets this to 0, it means it supports recursive resolution (Fetching DNS records from other DNS servers if they are not available locally)
- **Z** - Currently, always set to 0. Reserved for future use
- **Rcode** - Set to 0 for successful responses. Set to 1 when the server detects a format error in the request. Set to 2 when there is a server error. Set to 3 if the domain doesn't exist
- **Number of questions** - A DNS query can contain multiple domain questions in a single request. This number specifies the number contained in this request. This is typically only 1
- **Number of answers** - If this is a response. This indicates the number of answers provided in the answers section
- **Number of authority RRs** - Included only in responses. Contains information about the authoritative servers for the requested domains
- **Number of additional RRs** - Contains additional information about the servers mentioned in the `authority RRs` section. Typically IP addresses of those servers

Immediately after the DNS header, we find the questions section. Here, we expect:

- **Name** - The domain name being requested (e.g. ncona.com), followed by a null character (`00`)
- **Type** - Type of record (e.g. A). [Here is the list with all the available types](https://en.wikipedia.org/wiki/List_of_DNS_record_types)
- **Class** - Typically set to `1` for internet records

If the packet is a response, it will include an answers section. It looks like this:

- **Name** - The domain name to which the resource record applies. Followed by a null character (`00`)
- **Type** - Type of record (e.g. A). [Here is the list with all the available types](https://en.wikipedia.org/wiki/List_of_DNS_record_types)
- **Class** - Typically set to `1` for internet records
- **ttl** - The number of seconds that the record can be cached by a DNS resolver
- **Rdlength** - The length of the `Rdata` field (in bytes)
- **Rdata** - The actual data for the record (e.g. An IP address for an A record)

In both the question and answer, domain names are encoded as labels prefixed by the length of the label. i.e. the domain `ncona.com`, would start with a `05`, followed by the bytes for `ncona` (6E 63 6F 6E 61), followed by `03`, followed by the bytes for `com` (63 6F 6D). The whole domain would be encoded as: `05 6E 63 6F 6E 61 03 63 6F 6D`.

## Sockets

Now that we know the theory, let's see what we need to do to implement our own DNS server.

It all starts with [socket](https://man7.org/linux/man-pages/man2/socket.2.html), which can be created with the `socket` syscall:

```cpp
int socket(int domain, int type, int protocol);
```

For our case, we'll use the following call: 

```cpp
int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
```

- `AF_INET` - IPv4 will be used
- `SOCK_DGRAM` - UDP will be used
- `IPPROTO_IP` - In this case, it does nothing, since there is only one protocol available for IPv4 + UDP

After creating the socket, we need to bind it to an address. We do this with [bind](https://man7.org/linux/man-pages/man2/bind.2.html):

```cpp
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

The first argument is the socket we just created. For the second argument, we need to pass a `sockaddr` struct, but the actual implementation varies depending on the address family. Our socket uses `AF_INET`, so we'll be using [sockaddr_in](https://man7.org/linux/man-pages/man7/ip.7.html):

```cpp
struct sockaddr_in {
    sa_family_t    sin_family; /* address family: AF_INET */
    in_port_t      sin_port;   /* port in network byte order */
    struct in_addr sin_addr;   /* internet address */
};

/* Internet address */
struct in_addr {
    uint32_t       s_addr;     /* address in network byte order */
};
```

Let's create ours:

```cpp
struct sockaddr_in dest_addr;
dest_addr.sin_family = AF_INET;
dest_addr.sin_port = htons(53);
dest_addr.sin_addr.s_addr = htonl(INADDR_ANY);
```

Since we are using `AF_INET` in the socket, we need to also use it for `sin_family`. Our DNS server will listen on port `53`, but we need to use `htons` to convert the number from memory byte order to network byte order. For `sin_addr`, we use `htonl` to convert `INADDR_ANY` to network byte order.

We are ready to bind our socket:

```cpp
bind(sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
```

To read from our socket we use [recvfrom](https://linux.die.net/man/2/recvfrom):

```cpp
size_t recvfrom(int sockfd, void *buf, size_t len, int flags, struct sockaddr *src_addr, socklen_t *addrlen);
```

This system call is a little more complicated than the previous ones. As the first argument (`sockfd`), we just need to pass our previously created socket. For the second argument (`buf`) we need to pass a previously created buffer that will hold the bytes received. The `len` argument should be set to the size of the buffer. We are not going to be using the `flags` argument, so we'll just set it to 0 for now.

The `src_addr` argument will be set to the caller's address, as provided by the underlying protocol. The last argument (`addrlen`) should be the size of `src_addr`, but since it's a value-result argument, we need to create a variable first and pass it as a reference.

Let's look at the type of `src_addr`:

```cpp
struct sockaddr {
   sa_family_t     sa_family;      /* Address family */
   char            sa_data[];      /* Socket address */
};
```

We can see that it has an already familiar `sa_family_t` field (`AF_INET`) as well as a char array which holds the data about the source address. Since our socket uses IPv4, we will actually be using `sockaddr_in`:

```cpp
struct sockaddr_in {
   sa_family_t     sin_family;     /* AF_INET */
   in_port_t       sin_port;       /* Port number */
   struct in_addr  sin_addr;       /* IPv4 address */
};
```

With this information we can now call `recvfrom`:

```cpp
char rx_buffer[128];
struct sockaddr_in source_addr;
socklen_t addrlen = sizeof(source_addr);
int len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr *)&source_addr, &addrlen);
```

The `len` variable will be set to the number of bytes received.

Now comes the point to use our DNS knowledge to interpret the data received in our socket.

Since the purpose of this DNS server is to act as a captive portal, we're going to cut a lot of corners and just return the IP address of our web server in all cases.

The first thing we are going to do is create a variable to hold our response and copy the request content to this variable. We do this because a response is very similar to the corresponding DNS request.

```cpp
char dns_response[256] = {};
memcpy(dns_response, rx_buffer, len);
```

One of the differences between the request and the response is that the `QR` flag must be set to `1` for the response. Since the `QR` flag is the first bit in the third octet, we can set it to `1` in our response, like this:

```cpp
dns_response[2] |= (1 << 7);
```

For the response we also need to set the number of answers to the same as the number of questions:

```cpp
dns_response[6] = dns_response[4];
dns_response[7] = dns_response[5];
```

Now it's time to build our answer. For that, we'll create the following struct:

```cpp
struct dns_answer {
  uint16_t ptr_offset;
  uint16_t type;
  uint16_t class;
  uint32_t ttl;
  uint16_t addr_len;
  uint32_t ip_addr;
} __attribute__((__packed__));
```

If the `__attribute__((__packed__))` part confuses you, take a look at [my article about packed data](/2024/09/aligned-and-packed-data-in-c-and-cpp/).

Notice how it resembles the DNS answer we learned about earlier. You will notice that instead of `name` we have a `ptr_offset` field. The reason for this is that we are going to use [domain name compression](https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.4), which allows us to point to a previously defined domain name. In our case, we'll point to the domain name defined in the question section. The RFC specifies that the most significant bits of the pointer need to be `11`, so we need to keep that in mind.


```cpp
// Move to the start of the questions section. Since the DNS header is 12 bytes,
// we just need to move 12 bytes from the start of the response
char *qn_ptr = dns_response + 12;

// Move to the end of the request. The answer goes right after the question,
// so we can start writing at the end of the request
char *ans_ptr = dns_response + len;

// Cast the pointer to our dns_aswer type
struct dns_answer *answer = (struct dns_answer *)ans_ptr;

// 0x0c is the same as 1100_0000. We use | to make sure set those bits on the
// pointer. To convert to network order, call htons
answer->ptr_offset = htons(0xc000 | (qn_ptr - dns_response));
```

For `type` and `class`, we'll use the same values as those in the question:

```cpp
char *qn_type_ptr = qn_ptr;
while (qn_type_ptr[0] != 0x0) {
  qn_type_ptr++;
}
qn_type_ptr++;
answer->type = *(uint16_t *)qn_type_ptr;
qn_type_ptr += 2;
answer->class = *(uint16_t *)qn_type_ptr;
```

We'll hard code the TTL to 300 seconds (5 minutes):

```cpp
answer->ttl = htonl(300);
```

Lastly, we need to set the IP address information:

```cpp
// We are using IPv4 so we know it'll always be 4 bytes
answer->addr_len = htons(4);

// Get the IP information from default AP device
esp_netif_ip_info_t ip_info;
esp_netif_get_ip_info(esp_netif_get_handle_from_ifkey("WIFI_AP_DEF"), &ip_info);
answer->ip_addr = ip_info.ip.addr;
```

Since we want all DNS requests to respond with the Access Point's IP address, we use `esp_netif_get_ip_info` to get its address.

Now, we just need to send the response back to the client:

```cpp
int dns_response_len = sizeof(struct dns_answer) + len;
sendto(sock, dns_response, dns_response_len, 0, (struct sockaddr *)&source_addr,
       sizeof(source_addr));
```

When a client connects to our Access Point, and they try to visit any website, they will be directed to our web server.

## Conclusion

The most complicated part of making our AP work correctly was setting up the captive portal by spinning our own DNS server. We cut a lot of corners in order to keep the code simple, but it will work correctly in most scenarios.

As usual, you can find a working version of the code above [in my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/configuring-esp32-to-act-as-access-point).
