---
id: 507
title: 'Python lesson: Getting user input through the console. Bonus: handling an exception.'
date: 2012-02-01T01:32:07+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=507
permalink: /2012/02/python-lesson-getting-user-input-through-the-console-bonus-handling-an-exception/
tags:
  - programming
  - python
---
This is my second article about the Python programming language. And what we are going to learn today is handling user input from the console.

Python makes getting user input from the console very easy. For this purpose we can use the input function, which has this structure:

```
input([prompt])
```

This function only takes the prompt as an argument, which would be the text that the user would see before the console goes into input mode.

To store input from a user into a variable you can simply assign the return value of the function to a variable like this:

```
userInput = input('Give me a value');
```

With that little information we can make a little program that will get a number from the user and print it&#8217;s square.

<!--more-->

```python
# Ask for the number and store it in userNumber
userNumber = input('Give me an integer number: ')

# Make sure the input is an integer number
userNumber = int(userNumber)

# Get the square of the number
# userNumber**2 is the same as saying pow(userNumber, 2)
userNumber = userNumber**2

# Print square of given number
print 'The square of your number is: ' + str(userNumber)
```

I saved this example with the name square.py and ran it with this command:

```
python square.py
```

There is an important thing to mention about this piece of code. If you run this code and you give a string as input the script will break.

There is an even more important thing to mention about the **input** function itself. This function is not expecting a string as input, what it actually expects is a python expression. That means that if you input executable code, it will be executed.

So if the user entered something like this: **myinput** as input to that function she would get a syntax error because python would be looking for an identifier called **myinput**. If the user wanted to enter it as a string she would have to manually wrap it between quotes like this: **&#8216;myinput&#8217;**.

That wouldn&#8217;t be very intuitive for the user so we would probably want to use a different function that treads any input as a string: **raw_input()**. It&#8217;s definition is pretty similar, it just takes the prompt as an argument, but it&#8217;s behaviour is different. It will parse any input as string, as the user would expect.

So let&#8217;s rewrite our little script to something a little more robust:

```python
# Ask for the number and store it in userNumber
userNumber = raw_input('Give me an integer number: ')

# Make sure the input is an integer number
userNumber = int(userNumber)

# Get the square of the number
# userNumber**2 is the same as saying pow(userNumber, 2)
userNumber = userNumber**2

# Print square of given number
print 'The square of your number is: ' + str(userNumber)
```

This is a little better, but it still gives an error if the input is not a number.

Coming from PHP I would have expected the int() function to give me an intelligent answer when trying to use it against a non-numeric string, but it doesn&#8217;t, so we will have to walk around this.

To solve the problem of the user entering a non-numeric value we will have to add a little exception handling to our script:

```python
# Ask for the number and store it in userNumber
userNumber = raw_input('Give me an integer number: ')

try:
    # Try to convert the user input to an integer
    userNumber = int(userNumber)
# Catch the exception if the input was not a number
except ValueError:
    userNumber = 0
else:
    # Get the square of the number
    # userNumber**2 is the same as saying pow(userNumber, 2)
    userNumber = userNumber**2

# Print square of given number
print 'The square of your number is: ' + str(userNumber)
```

Well, this concludes my second experience with python, and it wasn&#8217;t that bad.
