---
id: 2287
title: Publishing an Android library to Sonatype central repository
date: 2014-09-04T02:15:49+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2287
permalink: /2014/09/publishing-an-android-library-to-sonatype-central-repository/
categories:
  - Mobile development
tags:
  - android
  - automation
  - gradle
  - mobile
---
I made this little open source library for Android that I want to consume from an app I&#8217;m building. I have the easy option of [checking in the .aar file into my repository as explained in my article](http://ncona.com/2014/08/consuming-android-library-with-gradle/ "Consuming Android library with gradle") but I want to do things right so I&#8217;m going to try to publish my app to central repository.

To get started you have to [create a jira account](https://issues.sonatype.org/secure/Signup!default.jspa "Create a Jira account") and then [create a ticket](https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134 "Create a ticket") so they can create a project for you. There are a few mandatory fields:

&#8211; Summary: I am not sure what I was supposed to enter here so I just entered the name of my project. (conversion-graph)
  
&#8211; Group Id: The top level group you are going to use. (com.ncona)
  
&#8211; Project URL: I entered URL to the project on github. (https://github.com/soonick/conversion-graph)
  
&#8211; SCM URL: The same URL but with a .git extension (https://github.com/soonick/conversion-graph.git)

<!--more-->

The next day I got an e-mail telling me that I could now make deploys. (It is important to wait for this e-mail before you proceed, otherwise the world ends).

It is part of Sonatype requirements that you supply a package for javadoc and a package for sources. You can generate a sources jar by adding these lines to build.gradle:

```groovy
task sourcesJar(type: Jar) {
  classifier = 'sources'
  from android.sourceSets.main.allSource
}
```

To generate your javadoc jar you will need something like this:

```groovy
task androidJavadocs(type: Javadoc) {
  source = android.sourceSets.main.allSource
  classpath += project.files(android.getBootClasspath().join(File.pathSeparator))
}

task androidJavadocsJar(type: Jar) {
  classifier = 'javadoc'
  from androidJavadocs.destinationDir
}
```

Then you need to add them to the artifacts collection:

```groovy
artifacts {
  archives androidJavadocsJar, sourcesJar
}
```

Before we can continue with the publishing part we need to create GPG keys so we can sign our artifacts:

```
gpg --gen-key
```

You can use the defaults for most of the values. Fill your data for the other fields and make sure to use a good password that you wont forget. After creating your keys, you will want to make your public key available to the public so they can use it to verify that your artifacts were actually signed by your private key. You can publish your key with this command:

```
gpg2 --keyserver hkp://pool.sks-keyservers.net --send-keys 2CCE6FB4
```

The number at the end of that command is the id of my public key, which you can get with this command:

```
gpg --list-keys
/home/ncona/.gnupg/pubring.gpg
--------------------------------
pub   2048R/2CCE6FB4 2014-09-03
uid                  Some Name <somemail@yahoo.com.mx>
sub   2048R/6F248598 2014-09-03
```

The next step is to modify your build.gradle so it knows how to sign and publish your artifacts to a maven repository. There are two gradle plugins that help us with this:

```
apply plugin: 'maven'
apply plugin: 'signing'
```

To take care of the signing add this to build.gradle:

```groovy
signing {
  sign configurations.archives
}
```

And this to gradle.properties:

```
signing.keyId=2CCE6FB4
signing.password=YourKeyP455WORD!
signing.secretKeyRingFile=/home/ncona/.gnupg/secring.gpg
```

For the publishing part you can paste this into build.gradle (Make sure to modify my project information with that of your project):

```groovy
group = "com.ncona"
archivesBaseName = "conversion-graph"
version = "1.0.0"

uploadArchives {
  repositories {
    mavenDeployer {
      beforeDeployment { MavenDeployment deployment -> signing.signPom(deployment) }

      repository(url: "https://oss.sonatype.org/service/local/staging/deploy/maven2/") {
        authentication(userName: ossrhUsername, password: ossrhPassword)
      }

      snapshotRepository(url: "https://oss.sonatype.org/content/repositories/snapshots/") {
        authentication(userName: ossrhUsername, password: ossrhPassword)
      }

      pom.project {
        name 'Conversion graph'
        packaging 'aar'
        description 'Graphs a conversion path'
        url 'https://github.com/soonick/conversion-graph'

        scm {
          url 'https://github.com/soonick/conversion-graph'
          connection 'scm:git:https://github.com/soonick/conversion-graph.git'
        }

        licenses {
          license {
            name 'The Apache License, Version 2.0'
            url 'http://www.apache.org/licenses/LICENSE-2.0.txt'
          }
        }

        developers {
          developer {
            id 'soonick'
            name 'Adrian Ancona Novelo'
            email 'soonick5@yahoo.com.mx'
          }
        }
      }
    }
  }
}
```

And add this to gradle.properties:

```
ossrhUsername=YourSonatypeUsername
ossrhPassword=YourSonatypePassword
```

To verify that everything worked fine run a build:

```
gradle build
```

And try to publish:

```
gradle uploadArchives
```

Once the upload finishes successfully you should be able to log in to [Sonatype](https://oss.sonatype.org/ "Sonatype") and see your artifacts in the **Staging Repositories** list.

[<img src="/images/posts/Sonatype.png" alt="Sonatype" />](/images/posts/Sonatype.png)

From here you will be able to examine the artifacts you uploaded. If you see anything wrong you can drop the repository and try again. If everything looks good you will want to close it and then release it.

If this is the first time you are releasing your package you will need to go back to the Jira ticket you opened in the beginning and let them know that you have done a release. This will let them know that they can start the sync process.

Finally, you will be able to find your artifacts published in Sonatype: https://oss.sonatype.org/content/groups/public
