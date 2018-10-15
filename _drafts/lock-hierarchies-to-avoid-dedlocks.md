In a previous post I explained <a href="https://ncona.com/2018/08/mutexes-in-c/">how mutexes work</a> and the problem of race conditions.

In this post I introduce another common problem with mutexes, which is deadlocks. Deadlocks are situations when a program can't make any progress because it is waiting for a mutex that will never be available. This might sound stupid, but is something that actually happens very often.

A naive example could be this:

[cc lang="c++"]
#include <thread>
#include <mutex>

std::mutex mutexA;
std::mutex mutexB;

void doSomething() {
  std::lock_guard<std::mutex> gA(mutexA);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  std::lock_guard<std::mutex> gB(mutexB);
}

void doSomethingElse() {
  std::lock_guard<std::mutex> gB(mutexB);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  std::lock_guard<std::mutex> gA(mutexA);
}

int main()
{
  std::thread t1(doSomething);
  std::thread t2(doSomethingElse);

  t1.join();
  t2.join();
}
[/cc]

The example above will cause a deadlock. If you take a close look, you will find that two threads are being started:

<strong>t1</strong>

<ul>
  <li>Locks mutexA</li>
  <li>Waits for 1 second</li>
  <li>Locks mutexB</li>
  <li>Exits</li>
</ul>

<strong>t2</strong>

<ul>
  <li>Locks mutexB</li>
  <li>Waits for 1 second</li>
  <li>Locks mutexA</li>
  <li>Exits</li>
</ul>

The reason the program deadlocks is because after 1 second has passed, <em>t1</em> will try to grab <em>mutexB</em>, but won't be able to do it, because it is being locked by <em>t2</em>. At the same time <em>t2</em> will try to grab <em>mutexA</em>, but will fail, because <em>t1</em> is holding that mutex. Both threads will wait forever for each other, so the program will never exit.

Although in this example, the problem is very obvious, when working on larger applications, it is not that easy to spot problems like this. One way to fix this problem is using std::lock:

[cc lang="c++"]
#include <thread>
#include <mutex>

std::mutex mutexA;
std::mutex mutexB;

void doSomething() {
  std::lock(mutexA, mutexB);
  std::lock_guard<std::mutex> gA(mutexA, std::adopt_lock);
  std::lock_guard<std::mutex> gB(mutexB, std::adopt_lock);
}

void doSomethingElse() {
  std::lock(mutexB, mutexA);
  std::lock_guard<std::mutex> gA(mutexA, std::adopt_lock);
  std::lock_guard<std::mutex> gB(mutexB, std::adopt_lock);
}

int main()
{
  std::thread t1(doSomething);
  std::thread t2(doSomethingElse);

  t1.join();
  t2.join();
}
[/cc]

<em>std::lock</em> makes sure the mutexes are always locked in the same order (regardless of the order of the arguments), avoiding deadlocks this way. Even though we are using <em>std::lock</em> we still want to use <em>std::lock_guard</em> to make sure the mutexes are released at the end of the scope. The <em>std::adopt_lock</em> option allows us to use lock_guard on an already locked mutex.

This approach is very easy to implement when we are locking the mutexes in the same function, but there are scenarios where this can't be done. For example:

[cc lang="c++"]
#include <thread>
#include <mutex>

std::mutex mutexA;
std::mutex mutexB;

void doSomethingWithMutexA() {
  std::lock_guard<std::mutex> gA(mutexA);
}

void doSomethingWithMutexB() {
  std::lock_guard<std::mutex> gB(mutexB);
}

void doSomething() {
  std::lock_guard<std::mutex> gA(mutexA);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  doSomethingWithMutexB();
}

void doSomethingElse() {
  std::lock_guard<std::mutex> gB(mutexB);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  doSomethingWithMutexA();
}

int main()
{
  std::thread t1(doSomething);
  std::thread t2(doSomethingElse);

  t1.join();
  t2.join();
}
[/cc]

In this case doSomething locks <em>mutexA</em> and then calls a function that needs to lock <em>mutexB</em>. Since the locking happens in two different functions, we can't use <em>std::lock</em> in this scenario. Because there is another thread locking <em>mutexB</em> and then waiting for <em>mutexA</em>, the two threads block each other forever.

To make make this scenario we can create lock hierarchies that disallow conditions that can cause deadlocks. We could say that for the example above, mutexB should never be locked before mutexA in the same thread. Because on complex applications it is possible that this won't be caught by programmer, we can have the program tell us if it detects this happening at run time. 


