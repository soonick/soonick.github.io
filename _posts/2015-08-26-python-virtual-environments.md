---
id: 3120
title: Python virtual environments
date: 2015-08-26T18:54:26+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3120
permalink: /2015/08/python-virtual-environments/
categories:
  - Python
tags:
  - programming
  - python
---
Python allows you to install packages using PIP. This works fine for small projects, but when you want to create a portable application you might run into problems if your application depends on a version of a package that is different to the version that another application depends on. Because by default PIP will install packages in a folder similar to:

```
/usr/lib/python2.7/site-packages/
```

<!--more-->

A folder will be created for the installed library. For example, when I installed flask, it was installed under:

```
/usr/lib/python2.7/site-packages/flask/
```

As you can see, the library folder is not versioned, so if you install a new version, the older will be overwritten.

Another problem with installing files in a location like **/usr/lib/python2.7/site-packages/** is that you need to use sudo to do it. If you don&#8217;t have sudo privileges in your current system, you wont be able to install packages (There are other ways around this, but virtual environments is the most elegant).

## Installation

```
sudo pip install virtualenv
```

## Usage

Create a folder where your project will live and create a virtual environment:

```
mkdir ~/python-project
cd ~/python-project
virtualenv env
```

This creates a copy of python in ~/python-project/env/ that will be used to run python-project. This effectively isolates the version of python(and all its dependencies) from the ones globally installed.

Now that the environment is installed, we need to activate it to start using it:

```
. env/bin/activate
```

This changes the prompt to something like this:

```
(env)[adrian@localhost python-project]$
```

Once in the virtual environment, installing packages using PIP will do it only for the current project, and sudo won&#8217;t be necessary:

```
pip install flask
```

To go out of the virtual environment you need to deactivate it:

```
deactivate
```

If you are curious, you can see that the package we installed is now here:

```
~/python-project/env/lib/python2.7/site-packages/flask/
```

## Develop using a virtual environment

Now that we have an environment with our dependencies, we need to use it. Since I&#8217;m using flask for my example I&#8217;m going to create a sample flask app in ~/python-project/app.py

```python
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run()
```

If you don&#8217;t have flask installed globally and you try to run the app you will get an error:

```
python app.py
Traceback (most recent call last):
  File "app.py", line 1, in <module>
    from flask import Flask
ImportError: No module named flask
```

If you activate your environment first you will be able to run your app without the need to install flask globally.

```
. env/bin/activate
python app.py
```

This time your app is executed using only the packages on your virtual environment.
