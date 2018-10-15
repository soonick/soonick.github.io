RAII is a pattern used in object oriented programming languages to manage resources. The pattern is only appropriate for programs that use deterministic cleanup (vs programs that use indeterministic garbage collection). The name (RAII) is not very descriptive of the pattern and other names have been proposed (Constructor Acquires, Destructor Releases. Scope-based Resource Management ), but it basically means that resources acquired during initialization (constructor), should be released in the destructor.

This technique is very important for languages like C++ because it helps avoid memory leaks on complex programs. Lets look at an example program that doesn't use RAII:

[cc lang="c++"]
#include <iostream>

int main() {
  for (;;) {
    std::string *input = new std::string();

    std::cout << "Give me a string: ";
    std::cin >> *input;

    std::cout << "You gave me: " << *input << "\n\n";
  }
}
[/cc]

This program has a memory leak because it creates a string in the heap inside the for loop, but it never deletes it. If the loop executes enough times, it will starve the memory in the system and eventually crash it. This is a very naive example, but it will serve as an example for now.

std::string doesn't

[cc lang="c++"]
#include <iostream>

int main() {
  for (;;) {
    std::string input;

    std::cout << "Give me a string: ";
    std::cin >> input;

    std::cout << "You gave me: " << input << "\n\n";
  }
}
[/cc]

Let's use 
