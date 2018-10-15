When you get familiar with Docker and start thinking about using it in production you eventually end up realizing that you need a way to orchestrate all your containers. What I mean by orchestration could be something as simple as, having an application that runs in a container and wanting to have a load balancer in front. If the traffic increases you might want to add another instance of the same application. The orchestrator is responsible of starting the other instance and telling the load balancer to use it.

In the past I have used Amazon's ECS (EC2 Container Service) to orchestrate my containers. You can give ECS access to some EC2 servers and you can tell it to start X number of instances of Y service for you. One thing that was a little complicated with ECS was the service discovery. It was necessary to add load balancer for each type of service and each load balancer had a cost. This ended adding up to a lot of money and a little inconvenience. For that reason and because some day I might decide to not use Amazon anymore, I decided to take a look at Kubernetes.

<strong>What is Kubernetes</strong>

From Kubernetes' documentation

<em>Kubernetes is an open-source platform for automating deployment, scaling, and operations of application containers across clusters of hosts, providing container-centric infrastructure.
With Kubernetes, you are able to quickly and efficiently respond to customer demand:
Deploy your applications quickly and predictably.
Scale your applications on the fly.
Seamlessly roll out new features.
Optimize use of your hardware by using only the resources you need.
Our goal is to foster an ecosystem of components and tools that relieve the burden of running applications in public and private clouds.</em>

This is a lot of words, and in reality Kubernetes does more than I know how to use. What Kubernetes really means for me is that I can tell Kubernetes: Here are some machines(physical or virtual), I want to run these applications on them, I want communication between these applications to be easy.

<strong>Creating a cluster</strong>

There are many ways to run Kubernetes. Probaby the easiest way is to use a hosted solution like Google Cloud, that already has Kubernetes running and you just need to use it. There are other tools that create a Kubernetes cluster for specific cloud providers (AWS, Google, etc). You should use these tools if they fit your needs.

In this post I'm going to cover a more manual approach that doesn't depend on any specific hosting provider. As long as you have some machines (physical or virtual), you will be able to create a cluster. I will assume you already have some machines running and you want to create a Kubernetes cluster with them. These machines should be able to communicate through the network and ideally have at least 1GB of RAM.

For my example I will assume we have three machines available. Two of them will be nodes and one will be the master. 

All machines in the cluster will need Docker, so I'll assume it is already installed.














<strong>An example</strong>

Reading my explanation above I actually find it a little confusing, so I think an example would be better. I want to build a system that consists of a few services:

- A public facing service that will give you an HTML document
- An internal service that gives you the time
- An internal service that gives you a random image

All these services will be replicated (there will be two instances of each service) and since the public facing service depends on the internal services, it will need a way to communicate with them. To make this infrastructure easy to expand and modify, we don't want to use the specific IP addresses or ports the containers are using, because they might change in the future or more containers might be added. Kubernetes will take care of this for us.

For Kubernetes to be able to create and orchestrate containers we will need some machines where it can put the containers. These machines can be anything you want, virtual machines, machines in the cloud, etc. I'm going to use virtual machines for my example, but it really makes no difference. If you want, you can follow <a href="http://ncona.com/2015/02/virtualization/">my virtualization article</a> and create some machines for yourself.

I will be working with four fedora machines, one that will be the master and three that will be used to run our cluster(fedora-kubernetes-master, fedora-kubernetes-1, fedora-kubernetes-2, fedora-kubernetes-3), each of them with a 8GB hard drive and 1024 MB of RAM.



