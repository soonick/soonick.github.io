---
id: 4846
title: Writing tests for C++ code
date: 2018-02-22T09:19:06+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4846
permalink: /2018/02/writing-tests-for-c-code/
categories:
  - C/C++
tags:
  - programming
  - testing
---
The time has come for me to start writing some tests for my C++ code, and I have to admit I&#8217;m a little nervous. The company I&#8217;m working for uses [Google Test](https://github.com/google/googletest) as their test framework, so I will trust their expertise and use it too.

## Set up

Lets start by creating a folder for our project:

```
mkdir ~/project
cd ~/project/
```

The next step is to download and unzip google test:

```
wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz
tar -zxf release-1.8.0.tar.gz
rm release-1.8.0.tar.gz
```

<!--more-->

Now it&#8217;s time to compile the library. The documentation mentions this: 

> &#8230;you want to compile src/gtest-all.cc with GTEST\_ROOT and GTEST\_ROOT/include in the header search path, where GTEST_ROOT is the Google Test root directory&#8230;

What this means is to move to the folder where Google Test was downloaded and compile the library:

```
cd googletest-release-1.8.0/
g++ -Igoogletest -Igoogletest/include -c googletest/src/gtest-all.cc
ar -rv libgtest.a gtest-all.o
```

We are now ready to create a test file:

```
mkdir ~/project/tests
touch ~/project/tests/test.cpp
```

We can add this to our file for now:

```cpp
#include "gtest/gtest.h"

int main (int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);

    EXPECT_EQ(1, 2);
}
```

We can now compile and run our test:

```
g++ -Igoogletest-release-1.8.0/googletest/include -pthread tests/test.cpp googletest-release-1.8.0/libgtest.a -o tests/tests
./tests/tests
```

The output will looks something like this:

```
tests/test.cpp:6: Failure
      Expected: 1
To be equal to: 2
```

We are now more or less ready to write tests.

## Creating a test suite

A simple Google Test file looks something like this:

```cpp
#include "gtest/gtest.h"

namespace {

TEST(TestingAddition, PositiveNumbersAddedCorrectly) {
  ASSERT_EQ(3, 1 + 1);
}

}  // namespace

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

The TEST function receives two arguments. The first argument is used to group tests together (Maybe the name of the function being tested). The second argument is an identifier for this specific test (the functionality being tested). The call to RUN\_ALL\_TESTS() will run all tests defined in the test binary and return 1 if there is any failure. We can compile and run this file the same as before:

```
g++ -Igoogletest-release-1.8.0/googletest/include -pthread tests/test.cpp googletest-release-1.8.0/libgtest.a -o tests/tests
./tests/tests
```

And the output will look like this:

```
[==========] Running 1 test from 1 test case.
[----------] Global test environment set-up.
[----------] 1 test from TestingAddition
[ RUN      ] TestingAddition.PositiveNumbersAddedCorrectly
tests/test.cpp:6: Failure
      Expected: 3
To be equal to: 1 + 1
      Which is: 2
[  FAILED  ] TestingAddition.PositiveNumbersAddedCorrectly (0 ms)
[----------] 1 test from TestingAddition (0 ms total)

[----------] Global test environment tear-down
[==========] 1 test from 1 test case ran. (0 ms total)
[  PASSED  ] 0 tests.
[  FAILED  ] 1 test, listed below:
[  FAILED  ] TestingAddition.PositiveNumbersAddedCorrectly

 1 FAILED TEST
```

For testing functionality in other files, you just need the include the code you want to test as you would include any other code. To see this in action, lets add a class to our project:

```
mkdir ~/project/src
touch ~/project/src/Adder.h
touch ~/project/src/Adder.cpp
```

Adder.h

```cpp
#ifndef ADDER_H
#define ADDER_H

class Adder {
public:
  int add(int l, int r);
};

#endif
```

Adder.cpp

```cpp
#include "Adder.h"

int Adder::add(int l, int r) {
  return l + r;
}
```

And write a test for it:

```
touch ~/project/tests/AdderTest.cpp
```

AdderTest.cpp:

```cpp
#include "gtest/gtest.h"
#include "Adder.h"

namespace {

TEST(Adder, AddsNumbers) {
  Adder *a = new Adder;
  ASSERT_EQ(3, a->add(1, 2));
}

}  // namespace

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

To compile this test we need to add the class under test to the compile command:

```
g++ -Igoogletest-release-1.8.0/googletest/include -Isrc -pthread tests/AdderTest.cpp src/Adder.cpp &nbsp;googletest-release-1.8.0/libgtest.a -o tests/AdderTest
```

## Fixtures

Fixtures are useful when you need to write a few tests that share some initialization code. A fixture can be used for initializing an object and cleaning up after it if multiple tests need the same code.

When we want to use fixtures we use TEST\_F instead of TEST. The first argument passed to TEST\_F as with TEST, is used to group tests together. For TEST_F, the first argument should also match the name of the fixture class being used. Lets look at how to create this fixture class:

```cpp
#include "gtest/gtest.h"

namespace {

class VectorTest : public ::testing::Test {
 protected:
  virtual void SetUp() {
    vec.push_back(1);
    vec.push_back(2);
    vec.push_back(3);
  }

  virtual void TearDown() {
    // This could be used to clean up dynamically allocated resources
  }

  std::vector<int> vec;
};

TEST_F(VectorTest, BeginGivesIteratorToFirstElement) {
  ASSERT_EQ(1, *vec.begin());
}

TEST_F(VectorTest, CrbeginGivesIteratorToLastElement) {
  ASSERT_EQ(3, *vec.rbegin());
}

}  // namespace

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

Because the name of our fixture class is _VectorTest_ and our tests use _TEST_F_ and their first argument is _VectorTest_ too, the tests can use the member _vec_. An important thing to mention is that a new object is instantiated for each test. This means that if you modify vec in one of your tests, it will not affect other tests.

Although there are a lot of things I&#8217;m not covering in this article, this has helped me write my first tests. As I get to use more advanced features I might write another article.
