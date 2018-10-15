---
id: 3352
title: Using Gerrit with MySQL
date: 2015-12-18T19:14:41+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3352
permalink: /2015/12/using-gerrit-with-mysql/
categories:
  - Linux
tags:
  - Git
  - linux
  - open source
  - productivity
---
A few weeks ago I published a post with an [introduction to Gerrit](http://ncona.com/2015/11/using-gerrit-for-better-collaboration-on-git-projects/). The configuration I explain there is not very scalable, so now I want to explain how to connect it to an external MySQL database so the data is more secure. As in my previous post, I&#8217;m going to do everything inside a docker image so it is easy to reuse and share.

Lets start with the Dockerfile from my previous post:

```docker
FROM gerritforge/gerrit-centos7:2.11.4

# Expose gerrit ports
EXPOSE 29418 8080

# Start Gerrit
CMD /var/gerrit/bin/gerrit.sh start && tail -f /var/gerrit/logs/error_log
```

<!--more-->

If we want to connect to an external database, first we need to create a database that is accessible from within the container. You can set that up however you want, but at the end you will need a host name, port, database name, user name and password for that user. The database should be empty at this moment. Our docker image will create the schema for us.

Extending the Dockerfile to use a MySQL database is not that hard. Lets add a few lines to make this happen:

```docker
FROM gerritforge/gerrit-centos7:2.11.4

# Configure gerrit to use our MySQL database
USER gerrit
RUN git config -f /var/gerrit/etc/gerrit.config database.type "mysql"
RUN git config -f /var/gerrit/etc/gerrit.config database.hostname "172.17.42.1"
RUN git config -f /var/gerrit/etc/gerrit.config database.port "3306"
RUN git config -f /var/gerrit/etc/gerrit.config database.database "reviewdb"
RUN git config -f /var/gerrit/etc/gerrit.config database.username "root"
RUN git config -f /var/gerrit/etc/gerrit.config database.password ""

# Expose gerrit ports
EXPOSE 29418 8080

# Create gerrit DB schema
USER gerrit
RUN java -jar /var/gerrit/bin/gerrit.war init --batch -d /var/gerrit

# Start Gerrit
USER gerrit
CMD /var/gerrit/bin/gerrit.sh start && tail -f /var/gerrit/logs/error_log
```

Now, this is where problems start. Once we have the Dockerfile, the next step is to build the image:

```
docker build .
```

For some reason, the first time I run this command I get an error similar to this one:

```
Downloading http://repo2.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar ... OK
Checksum mysql-connector-java-5.1.21.jar OK
Exception in thread "main" com.google.gwtorm.server.OrmException: Cannot initialize schema
    at com.google.gerrit.server.schema.SchemaUpdater.update(SchemaUpdater.java:101)
    at com.google.gerrit.pgm.init.BaseInit$SiteRun.upgradeSchema(BaseInit.java:339)
    at com.google.gerrit.pgm.init.BaseInit.run(BaseInit.java:120)
    at com.google.gerrit.pgm.util.AbstractProgram.main(AbstractProgram.java:64)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at java.lang.reflect.Method.invoke(Method.java:606)
    at com.google.gerrit.launcher.GerritLauncher.invokeProgram(GerritLauncher.java:166)
    at com.google.gerrit.launcher.GerritLauncher.mainImpl(GerritLauncher.java:93)
    at com.google.gerrit.launcher.GerritLauncher.main(GerritLauncher.java:50)
    at Main.main(Main.java:25)
Caused by: java.io.IOException: Cannot update refs/meta/config in /var/gerrit/git/All-Projects.git: LOCK_FAILURE
    at com.google.gerrit.server.git.VersionedMetaData$1.updateRef(VersionedMetaData.java:376)
    at com.google.gerrit.server.git.VersionedMetaData$1.createRef(VersionedMetaData.java:292)
    at com.google.gerrit.server.git.VersionedMetaData.commitToNewRef(VersionedMetaData.java:174)
    at com.google.gerrit.server.schema.AllProjectsCreator.initAllProjects(AllProjectsCreator.java:183)
    at com.google.gerrit.server.schema.AllProjectsCreator.create(AllProjectsCreator.java:100)
    at com.google.gerrit.server.schema.SchemaCreator.create(SchemaCreator.java:85)
    at com.google.gerrit.server.schema.SchemaUpdater.update(SchemaUpdater.java:99)
    ... 11 more
```

It complains about not being able to initialize the schema, even though the schema was apparently created correctly. If I run the same command again the image is created successfully. This makes me a little nervous, because I Imagine the second time I run it, since it sees that the DB is there, it won&#8217;t try to create it again. The problem is that if there was a problem creating the DB then the problem will remain there. I&#8217;m going to assume there were no problems and continue.

We can now start the container:

```
docker run -p 8080:8080 -p 29418:29418 <image_id>
```

If the world was perfect this would be the end of the post. But it isn&#8217;t. There is a bug in the setup process that causes the Administrator to not be able to create new projects:

[<img src="/images/posts/new-project.png" alt="new-project" />](/images/posts/new-project.png)

I found a bug report related to this issue that explained a workaround: <https://code.google.com/p/gerrit/issues/detail?id=3698>. Hopefully this issue will be soon fixed and the workaround will not be necessary anymore.

Here are the steps I followed to fix the issue:

Open a terminal into the running container:

```
docker exec -i -t <container-id> bash
```

Clone the All-project.git into a location in the same container:

```
cd /tmp
git clone /var/gerrit/git/All-Projects.git
```

Retrieve the Admnistrators UUID from the project:

```
cat All-Projects/groups
```

You will get something similar to this:

```
# UUID                                      Group Name
#
b68e6759990854d3b29c815c3fc47d49127d6b77    Administrators
d9aa50be912f4e0c9b58e7da542e310c308e3e75    Non-Interactive Users
global:Anonymous-Users                      Anonymous Users
global:Project-Owners                       Project Owners
global:Registered-Users                     Registered Users
```

Select all the items of the account_groups table in the database. You will get something like this:

```
+-----------------------+------------------------------------------+------------------------------------------+
| name                  | group_uuid                               | owner_group_uuid                         |
+-----------------------+------------------------------------------+------------------------------------------+
| Administrators        | cd96de441c87d6e88b8f0967398e7c9e219d7a8f | cd96de441c87d6e88b8f0967398e7c9e219d7a8f |
| Non-Interactive Users | a59ec27be1b9a02fcfc978290d328fbb78834902 | cd96de441c87d6e88b8f0967398e7c9e219d7a8f |
+-----------------------+------------------------------------------+------------------------------------------+
```

We can see here that the Administrators group_uuid in the DB is cd96de441c87d6e88b8f0967398e7c9e219d7a8f. What we need to do is replace this with the one in the groups file (cd96de441c87d6e88b8f0967398e7c9e219d7a8f):

```
update account_groups set group_uuid = 'b68e6759990854d3b29c815c3fc47d49127d6b77' where name = 'Administrators';
update account_groups set owner_group_uuid = 'b68e6759990854d3b29c815c3fc47d49127d6b77';
```

At the end it will look something like this:

```
+-----------------------+------------------------------------------+------------------------------------------+
| name                  | group_uuid                               | owner_group_uuid                         |
+-----------------------+------------------------------------------+------------------------------------------+
| Administrators        | b68e6759990854d3b29c815c3fc47d49127d6b77 | b68e6759990854d3b29c815c3fc47d49127d6b77 |
| Non-Interactive Users | a59ec27be1b9a02fcfc978290d328fbb78834902 | b68e6759990854d3b29c815c3fc47d49127d6b77 |
+-----------------------+------------------------------------------+------------------------------------------+
```

We just need to restart the container and we will get our desired button:

[<img src="/images/posts/new-project-button.png" alt="new-project-button" />](/images/posts/new-project-button.png)

Now we have gerrit working with MySQL.
