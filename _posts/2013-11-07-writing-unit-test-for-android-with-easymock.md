---
id: 1799
title: Writing unit test for Android with Easymock
date: 2013-11-07T00:44:53+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1799
permalink: /2013/11/writing-unit-test-for-android-with-easymock/
tags:
  - android
  - java
  - mobile
  - programming
  - testing
---
I already wrote a post about [how to create a test suite for Android](http://ncona.com/2013/09/unit-testing-android-apps/ "Unit testing Android Apps"), but while trying more complex tests I noticed that a lot of things are not as easy as I would have expected. Unit testing Java is different that unit testing JavaScript, but unit testing Android is even a little harder. The problem with Android is that a lot of things depend on the Activity life cycle and most of the methods have been made final so they are impossible to mock.

## Alternatives

Easymock wasn&#8217;t my first alternative. My first choice was Robolectric because I heard a lot of people say good things about it, the problem is that it has very little documentation and most of it is specific for eclipse. They also have a sample project but I wasn&#8217;t able to make it work. I also tried Mockito but I wasn&#8217;t able to make it work with my project. The reason I chose Easymock is because it was really easy to make it work and it seems to have a lot of support and documentation.

<!--more-->

## Installing Easymock

From now on I&#8217;m going to assume that you have a project set up as I explain on [unit testing Android apps](http://ncona.com/2013/09/unit-testing-android-apps/ "Unit testing Android Apps").

The first step is to get EasyMock. You can get the latest version from [Easymock&#8217;s download page](http://easymock.org/Downloads.html "Easymock downloads"). Choose the latest version and you will get a zip file. You only need easymock-3.2.jar (3.2 will change depending on the version you choose). You will also need dexmaker for Easymock to work on Android. You can get the jar from [Dexmaker&#8217;s website](http://code.google.com/p/dexmaker/downloads/list "Dexmaker homepage"). Once you have both jar files put them in <project_path>/tests/libs. Now you have EasyMock available in your tests.

## Mocking stuff

It is time to use this new library that we just installed. One thing to have in mind when using EasyMock is that it is not possible to mock private or final methods so you might want to change your methods to protected if possible. Lets look at an example of a test for a custom view:

```java
// Some other imports go in here

import static org.easymock.EasyMock.*;

public class SomeViewTest extends AndroidTestCase {
    public void testSomeFunction() {
        // Create a mock of SomeView class
        // Since this is a custom view the constructor needs the
        // context as an argument. Since this is an AndroidTestCase
        // we can use getContext() to get a mock context and pass
        // it to the constructor
        // When using createMockBuilder all methods for the class
        // you are mocking will remain with the same functionality
        // except for the ones you specify with addMockedMethod.
        // Finally we need to call createMock() to get the mock.
        SomeView sv = createMockBuilder(SomeView.class)
            .withConstructor(getContext())
            .addMockedMethod("someOtherFunction")
            .createMock();

        // By default when using createMock() your test will
        // fail if a mocked method is called unless you set
        // expectations for the call. If you want a different
        // behavior you can use createNiceMock().
        // This expects someOtherFunction to be called once
        // with 3 as an argument and it will return 300
        expect(sv.someOtherFunction(3)).andReturn(300);

        // This tells EasyMock that you are done setting
        // expectations and that it is ready to replay it
        replay(sv);

        // Call the function to test
        sv.someFunction();

        // Verify the expectations
        verify(sv);
    }
}
```

## Easymock matchers

The previous example shows how to create a mock and set some expectations but there are many times when you want to verify that you are calling a specific functions with some specific arguments. To do this kind of verifications you can use EasyMock matchers. They allow you to expect a function call that with arguments that match different criteria. Here are some examples:

```java
// Matches a call with the only argument being the int 3
mock.mockedFunction(3);

// Matches any int
mock.mockedFunction(anyInt());

// Matches null
mock.mockedFunction(isNull());

// Matches an array with the same values as the given array
mock.mockedFunction(aryEq(someArray));
```

One thing to keep in mind is that you can&#8217;t mix matchers and specific values, so this will fail:

```java
mock.mockedFunction(3, anyObject());
```

Instead you can use eq() to convert an specific value to a matcher:

```java
mock.mockedFunction(eq(3), anyObject());
```

Another gotcha is there aren&#8217;t matchers for all possible scenarios that you could imagine. One functionality that I needed was to expect a function to be called with a bi-dimensional array as an argument. None of these work for bi-dimensional arrays:

```java
mock.mockedFunction(someBiDimensionalArray);
mock.mockedFunction(eq(someBiDimensionalArray));
mock.mockedFunction(aryEq(someBiDimensionalArray));
```

So I had to create a custom matcher.

## EasyMock custom matchers

Creating a custom matcher is not complicated but the documentation wasn&#8217;t completely clear about it. What I did is create a new class for my custom matcher and put it in <project_path>/tests/src/com/domain/project/lib and called it twoDimensionalArrayMatcher.java:

```java
import org.easymock.IArgumentMatcher;
import java.util.Arrays;
import static org.easymock.EasyMock.*;

// All custom matchers must implement IArgumentMatcher
public class twoDimensionalArrayMatcher implements IArgumentMatcher {
    private int[][] expected;

    public twoDimensionalArrayMatcher(int[][] expected) {
        this.expected = expected;
    }

    // This is the actual code that defines if the argument is
    // a match. If this function returns true it is considered
    // a match, otherwise it is not a match.
    public boolean matches(Object actual) {
        return Arrays.deepEquals(expected, (int[][])actual);
    }

    public void appendTo(StringBuffer buffer) {
        buffer.append("towAryEq failed");
    }

    // This is how you will access this matcher from outside
    public static int[][] twoAryEq(int[][] in) {
        reportMatcher(new twoDimensionalArrayMatcher(in));
        return null;
    }
}
```

Once you have your custom matcher you can use it as any other matcher:

```java
// Some other imports go in here

import static org.easymock.EasyMock.*;
// Our custom matcher
import static com.domain.project.lib.twoDimensionalArrayMatcher.*;

public class SomeViewTest extends AndroidTestCase {
    public void testSomeFunction() {
        // Some hidden code where we create the mock

        expect(sv.someOtherFunction(twoAryEq(someBidimensionalArray)));

        // More hidden code
    }
}
```

## The ugly part

Android has defined a lot of it&#8217;s native functionality as final which makes it impossible to mock. This was a big problem for my view test because I wanted to mock calls to functions like getHeight() so I could specify a mocked screen size. What I ended up doing was creating proxy methods for those functions in my view:

```java
protected int getViewWidth() {
    return getWidth();
}
```

This is not an elegant solution but it was the easiest way I found to mock those calls. In the future I&#8217;ll probably create a TestableView class that extends view so my custom views get those proxy methods automatically.

With all this I think I will be able to correctly unit test most of my Android code.
