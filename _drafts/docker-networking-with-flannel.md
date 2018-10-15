I've been lately looking at the <a href="https://coreos.com/">Coreos</a> ecosystem to try to understand better how to run containers at scale. This has turned out to be a lot more complex than I expected but very enlightening. There a lot of tools that have been created to help with this task, and I'm slowly getting familiar with them.

Today I'm looking at solving the problem of having containers on multiple hosts communicate with each other seamlessly. I have written a little about <a href="https://ncona.com/2016/11/docker-networking/">docker networking</a> in a previous post, but I only covered networking for a single host.

<strong>Networking without Flannel</strong>

Lets look at how troublesome a single host networking approach would look with an example. Lets say we have two hosts and three 5 services.

<ul>
  <li>A blog</li>
  <li>An API</li>
  <li>A catalog</li>
  <li>A MySQL database</li>
  <li>An user management service</li>
</ul>

This services will need to communicate with each other. Namely:

<ul>
 <li>The user management service needs access to the MySQL database</li>
 <li>The API service needs access to the user management service and also to the database</li>
 <li>The blog uses the user management service and the API</li>
 <li>The catalog uses the user management service and the API</li>
</ul>

Now lets look at a diagram of how we could accommodate them in our two hosts (For now we only need to focus on communication between our services, we don't care about our services being accessible from the outside):

<a href="https://storage.googleapis.com/ncona-media/2017/10/455bc3fe-two-hosts-networking.jpg"><img src="https://storage.googleapis.com/ncona-media/2017/10/455bc3fe-two-hosts-networking.jpg" alt="" width="2112" height="1034" class="alignnone size-full wp-image-4629" /></a>

The image shows a possible configuration for our containers. I included IP addresses on the hosts to illustrate that they are in the same subnet and that all the communication between the hosts would have to go through those interfaces.

I tried to split the services in a way to minimize calls between hosts (The database is in the same host as the services that need is), but the blog and catalog will still need access to the API and user management service on host 1.

How do we make accessible different services in the same IP address? The simplest answer would be to use different ports. In docker we can do this with parameters to the run command. We could do this on host 1:

[cc]
docker run -p 8081:80 api
docker run -p 8082:80 users
[/cc]

And we can configure the blog and catalog services to communicate with the API service at 192.168.10.23:8081 and with the users service at 192.168.10.23:8082. Since the API service also needs the users service, it can also be configured to find it at 192.168.10.23:8082.

API and user services also need to communicate with the database. The easiest way to do this is to also export the port on the host:

[cc]
docker run -p 3306:3306 mysql
[/cc]

This required some manual work, but wasn't really that hard. The problem is that as you add more containers doing this manually starts being very time consuming and slowing deploys and releases. It's also a problem if you need to move containers to a different host because all consumers would need to be updated manually to point to the new host.

Lets see how Flannel can help us.

<strong>Flannel</strong>

Flannel allows you to create an overlay virtual network on top of your physical network. That's a lot of fancy words in a single sentence, so let me try to explain what that means.

In the picture above I showed two hosts. We can imagine these are two machines that are connected via an Ethernet cable. These machines can communicate with each other using their IP address. This is our physical network (These could actually be virtual machines and virtual interfaces too, but the example is clearer with physical machines).

An overlay network is a virtual (implemented in software) network that sits on top of the physical network. Nodes connected to the overlay network can communicate with each other without having to worry about the structure of the physical network (e.g. The IP addresses on the physical network can change and this wouldn't affect it).

Why do we want an overlay network? What we can use this overlay network for is to model each of our containers as a node in this network. If we do this, communication between containers can be achieved easily without having to recourse to port mappings (because for all the network knows each node has it's own IP address).

Now that we know what and why, we can go ahead and design our network. We want all the nodes on our network to be able to communicate with each other, so we need to choose a subnet that gives us a large enough range of IP addresses. I will start with a subnet in the /16 range and give each of the physical hosts a a subnet in the range /24. Each container can then grab an IP address in that subnet. Lets see how this looks in paper:

<a href="https://storage.googleapis.com/ncona-media/2017/10/bc681f3f-overlay-network-structure.jpg"><img src="https://storage.googleapis.com/ncona-media/2017/10/bc681f3f-overlay-network-structure.jpg" alt="" width="2233" height="1502" class="alignnone size-full wp-image-4637" /></a>

In the image we can see that each container has it's own IP address. You can also see two new participants vs1 and vs2, these are virtual switches that will automatically be created by Flannel. These switches are in the same /16 subnet so they can communicate directly. Containers in different hosts belong to a different /24 network. Containers in host 1 start with 10.10.1 and containers in host 2 start with 10.10.2. If the Blog service tries to call 10.10.1.2 (API service), the call will arrive to the switch and this will send it to the correct host.

The question now is. How do I actually create and manage this network?

<strong>Running Flannel</strong>

Flannel reads it's configuration from Etcd. If you are not familiar with Etcd, you can read my <a href="http://ncona.com/2017/10/introduction-to-etcd/">Introduction to Etcd article</a>. From here on, I will assume you have access to an Etcd cluster.

By default Flannel reads the configuration from /coreos.com/network/config. This key will contain a JSON string with the flannel configuration. For my example, I will use most default values. The only value I will change is the default backend, which is not recommended for production:

[cc lang="js"]
{
  "Backend": {
    "Type": "vxlan",
    "Port": 7890
  }
}
[/cc]
