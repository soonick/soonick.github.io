---
title: Dependency injection (Inversion of Control) in Spring framework
author: adrian.ancona
layout: post
date: 2022-04-20
permalink: /2022/04/dependency-injection-in-spring-framework
tags:
  - architecture
  - design_patterns
  - java
  - programming
---

In this article we are going to learn about one of the foundational pieces of the Spring Framework; its implementation of Dependency Injection (which they usually refer by the more confusing name: Inversion of Control or IoC).

If you don't know what Dependency Injection is, you can start by reading the first section of my [Dependency Injection with Dagger and Bazel](https://ncona.com/2021/09/dependency-injection-with-dagger-and-bazel) article. That section explains what is dependency injection and how it's typically used.

## Spring Beans

The term `bean` is used to refer to a few things in the Java world, so it's important to know what it means when used in the context of Spring.

A Spring `bean` refers to an object that is injected by Spring's depedency injection framework (Usually referred as IoC framework or IoC container).

## ApplicationContext

The `ApplicationContext` interface takes care of creation and injection of beans. There are different implementations of this interface that allow us to configure our beans using different methods. We'll start by looking at the traditional way: `ClassPathXmlApplicationContext`.

<!--more-->

We can instantiate an `ApplicationContext` that loads beans from the configuration file `beans.xml` with this code:

```java
ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
```

Once we have an instance of `ApplicationContext`, we can use it to get `beans`:

```java
Zoo zoo = context.getBean("zoo", Zoo.class);
```

## Configuring beans

In the previous section we load a configuration file named `beans.xml`. As the name of the application context suggests (`ClassPathXmlApplicationContext`), the specified file is going to be loaded from the `CLASSPATH`.

Let's now look at a valid `beans.xml` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean id="elephant" class="diexample.Elephant"></bean>

    <bean id="zoo" class="diexample.Zoo">
      <constructor-arg ref="elephant" />
    </bean>
</beans>
```

We can see that there is a top-level xml element called `beans` where we load the schema for the file. Inside, we use the `bean` tag to define our beans. Let's take a closer look at our beans:

```xml
<bean id="elephant" class="diexample.Elephant"></bean>
```

The `id` attribute is used to refer to this specific bean. In the previous section we used `getBeam` to retrieve the bean with the id `zoo`.

The `class` attribute specifies the class to be instantiated. For the `elephant` bean, that's all we need since it has a no-arguments constructor:

```java
package diexample;

class Elephant implements Animal {
  public void talk() {
    System.out.println("Hello, I'm an elephant");
  }
}
```

The `zoo` bean uses `constructor-arg` to define arguments to pass to the constructor when it's being created:

```xml
<bean id="zoo" class="diexample.Zoo">
  <constructor-arg ref="elephant" />
</bean>
```

It uses `ref="elephant"` to specify that the bean with `id` elephant is going to be used as first argument when constructing `zoo`.

```java
package diexample;

public class Zoo {
  private Animal animal;

  Zoo(Animal animal) {
    this.animal = animal;
  }

  public void talk() {
    animal.talk();
  }
}
```

This is just an example of how to create beans. Spring provides many other ways (factories, setters, etc...) that I don't cover in this article.

You can find a full example of using an xml file to configure bean at: [Github: Xml Configuration](https://github.com/soonick/ncona-code-samples/tree/master/spring-dependency-injection/xml-configuration)

## Configuring beans using code

In the previous section we used an xml file to configure our beans. This was the only option available in the early days of IoC in Spring, but we have other options now.

We can configure our application using code and annotations instead of XML files. The `beans.xml` file would be replaced with a file called `BeansConfiguration.java`:

```java
package diexample;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class BeansConfiguration {
  @Bean
  public Animal elephant() {
    return new Elephant();
  }

  @Bean
  public Zoo zoo() {
    return new Zoo(elephant());
  }
}
```

In order to use this new configuration we also need to change the `ApplicationContext` implementation:

```java
package diexample;

import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class DiExample {
  public static void main(String args[]) {
    ApplicationContext context = new AnnotationConfigApplicationContext(BeansConfiguration.class);
    Zoo zoo = context.getBean("zoo", Zoo.class);
    zoo.talk();
  }
}
```

You can find the full example at: [Github: Code Configuration](https://github.com/soonick/ncona-code-samples/tree/master/spring-dependency-injection/code-configuration)

## Configuring beans using annotations

In the previous sections we defined our beams in an XML file or in a configuration file written in Java. In this section we are going to tell Spring to scan our project for annotated classes and use those annotations to figure out how to construct beans.

Similar to what we did when we used XML for configuration, we are going to create an XML file. The difference is that this time we are only going to tell Spring to scan the project for beans. The XML file looks like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:context="http://www.springframework.org/schema/context"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context-3.0.xsd">
    <context:component-scan base-package="diexample" />
</beans>
```

Now we need to add the annotations to our classes.

`Elephant.java`:

```java
package diexample;

import org.springframework.stereotype.Service;

@Service
class Elephant implements Animal {
  public void talk() {
    System.out.println("Hello, I'm an elephant");
  }
}
```

`Zoo.java`:

```java
package diexample;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

@Service("zoo")
public class Zoo {
  private Animal animal;

  @Autowired
  Zoo(Animal animal) {
    this.animal = animal;
  }

  public void talk() {
    animal.talk();
  }
}
```

By annotating these classes, Spring will be able to figure out that it can instantiate an `Elephant` by using a default constructor and it can instantiate a `Zoo` by passing it an `Elephant`.

The main file stays the same:

```java
package diexample;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class DiExample {
  public static void main(String args[]) {
    ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
    Zoo zoo = context.getBean("zoo", Zoo.class);
    zoo.talk();
  }
}
```

You can find the full example at: [Github: Annotation Configuration](https://github.com/soonick/ncona-code-samples/tree/master/spring-dependency-injection/annotation-configuration)

It's also possible to combine the code configuration with annotations. We just need to change our `BeansConfiguration.java` file to look like this:

```java
package diexample;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ComponentScan;

@ComponentScan(basePackages = {"diexample"})
@Configuration
public class BeansConfiguration {}
```

You can find the full example at: [Github: Code and Annotation Configuration](https://github.com/soonick/ncona-code-samples/tree/master/spring-dependency-injection/code-and-annotation-configuration)

## Conclusion

After reading this article we should understand how Spring beans are created and injected.

There are many options that we didnt' cover, but they follow the same pattern of creating an application context where we specify how beans are created and injected.
