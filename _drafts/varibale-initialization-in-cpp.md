An initialization is when you provide a value to a variable. There are a few ways to initialize a variable. Here are some examples:

[cc lang="c++"]
int main() {
  // Expression
  int a = 1;

  // Expression list
  int b(2);

  // Initializer list
  int c{3};
}
[/cc]

Each of the lines above initializes a variable (a to 1, b to 2 and c to 3).

<strong>Expression</strong>

The expression is the simplest way to initialize a variable. When this is done, the value on the right side of the equal sign is copied to the variable on the left side. If the compiler deems it possible, the initialization might be done at compile time.

<strong>Expression list</strong>

An expression list can be used to initialize objects using their constructor, for example:

[cc lang="c++"]
#include <vector>

int main() {
  std::vector<int> vec(10, 5);
}
[/cc]

In the example above we are initializing the vector <em>vec</em> with a size of 10, and all values set to 5.

<strong>Initializer list</strong>

Initializer lists are the newest way of initializing a variable. They were introduced in C++11. They look similar to expression lists:

[cc lang="c++"]
#include <vector>

int main() {
  std::vector<int> vec{10, 5};
}
[/cc]

But they work a little different. In the example above we are creating a vector with two items on it (10 and 5).

For non aggregates, it will call the constructor the same way as the expression list:

[cc lang=c++"]
#include <iostream>
#include <vector>

struct Hello {
  Hello(int v) : a(v) {}
  Hello(int v1, int v2) : a(1), b(v2) {}

  int a;
  int b;
};

int main() {
  Hello hello{1};
  Hello hello2{1, 2};

  std::cout << hello.a << "-" << hello.b << std::endl;
  std::cout << hello2.a << "-" << hello2.b << std::endl;
}
[/cc]

The output is:

[cc]
1-0
1-2
[/cc]

Narrowing conversions
