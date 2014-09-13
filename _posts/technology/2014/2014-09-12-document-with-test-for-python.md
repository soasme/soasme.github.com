---
layout: post
category: technology
tag: python
---

# Python doctest

Doctest is a module included in the Python programming language's standard library that allows the easy generation of tests based on output from the standard Python interpreter shell, cut and pasted into docstrings.


### Doctest in docstring example

{% highlight python %}

# file: code.py

def add(a, b):
    """Example:

    >>> add(1, 2)
    4
    """
    return a + b

if __name__ == '__main__':
    import doctest
    doctest.testmod()
{% endhighlight %}

Execute `$ python code.py`:

{% highlight bash %}
(venv)t % python t.py
**********************************************************************
File "t.py", line 4, in __main__.add
Failed example:
    add(1, 2)
Expected:
    4
Got:
    3
**********************************************************************
1 items had failures:
   1 of   1 in __main__.add
***Test Failed*** 1 failures.
{% endhighlight %}


Doctest makes innovative use of the following Python capabilities:

* docstrings
* The Python interactive shell, (both command line and the included idle application).
* Python introspection

### Doctest in a separate file from code

I think it is the ability to put your doctests in a text file one of the most cool features of doctest (in .md, .rst, .whatever format you want).This is especially useful for functional testing, since that allows you to write developer-friendly test-driven
documents.

Assume that we are now trying to introduce a module named `idiot`.

{% highlight python %}
# idiot/__init__.py
# -*- coding: utf-8 -*-

class Idiot(object):

    def __init__(self, iq=30):
    self.iq = iq

def add(a, b):
    return a + b + 1
{% endhighlight %}

First write a `tutorial.md` file:


    # Basic tutorial

    Welcome, developers, to a tour de force through `idiot` library.
    You will get to know it well in this trip, so be better start off
    on a friendly note. And now, let's go!

    ## Getting Started

    To use `idiot` library we have to import the library

        >>> import idiot
        >>> dull = idiot.Idiot(iq=30)

    If you leave out `iq` parameter as None, `10` would be used as defaults.

    ## Basic Operation

    Now that we have an instance of `idiot`, we can have `dull` do some add:

        >>> idiot.add(1, 2)
        4

    See? He will never return a right answer to you.

    ## More?

    I think it is all of this library.
    Hope you using it in your production repo. Good luck!


### Running doctest in seperate file

Run:

    $ python -m doctest tutorial.md

Let's see verbose output (run with `-v`):

    (venv)t % python -m doctest tutorial.md -v
    Trying:
        import idiot
    Expecting nothing
    ok
    Trying:
        dull = idiot.Idiot(iq=30)
    Expecting nothing
    ok
    Trying:
        idiot.add(1, 2)
    Expecting:
        4
    ok
    1 items passed all tests:
       3 tests in tutorial.md
    3 tests in 1 items.
    3 passed and 0 failed.
    Test passed.


### Running doctest with nose

Write`.nose.cfg`:

{% highlight ini %}
[nosetests]
verbosity=3

with-doctest=1
doctest-extension=mkd
{% endhighlight %}

Run:

    $ nosetests -c .nose.cfg


### Running doctest with py.test

Run:

    py.test --doctest-glob='*.rst'

Also, using fixtures from classes, modules or projects and autouse fixtures (xUnit setup on steroids) fixtures are supported when executing text doctest files.

### Real World Example

[earl/beanstalkc](https://github.com/earl/beanstalkc)

There is no unittest or interation test in repo, doctest only.

    beanstalkc
    ├── LICENSE
    ├── README.mkd
    ├── README_fixtures.py
    ├── TUTORIAL.mkd
    ├── TUTORIAL_fixtures.py
    ├── beanstalkc.py
    ├── setup.py
    └── test
        ├── __init__.py
        ├── fixtures.py
        ├── no-yaml.mkd
        └── no-yaml_fixtures.py

    1 directory, 11 files

All test written in 3 markdown documents: `README.mkd`,`TUTORIAL.mkd`, `no-yaml.mkd`.

Furthermore, the author wrote `setup` and `teardown` as fixtures.

File `README.mkd`

    beanstalkc
    ==========

    beanstalkc is a simple beanstalkd client library for Python. [beanstalkd][] is
    a fast, distributed, in-memory workqueue service.

    beanstalkc depends on [PyYAML][], but there are ways to avoid this dependency.
    See Appendix A of the tutorial for details.

    beanstalkc is pure Python, and is compatible with [eventlet][] and [gevent][].

    beanstalkc is currently only supported on Python 2 and automatically tested
    against Python 2.6 and 2.7. Python 3 is not (yet) supported.

    [beanstalkd]: http://kr.github.com/beanstalkd/
    [eventlet]: http://eventlet.net/
    [gevent]: http://www.gevent.org/
    [PyYAML]: http://pyyaml.org/


    Usage
    -----

    Here is a short example, to illustrate the flavor of beanstalkc:

        >>> import beanstalkc
        >>> beanstalk = beanstalkc.Connection(host='localhost', port=14711)
        >>> beanstalk.put('hey!')
        1
        >>> job = beanstalk.reserve()
        >>> job.body
        'hey!'
        >>> job.delete()

    For more information, see [the tutorial](TUTORIAL.mkd), which will explain most
    everything.


    License
    -------

    Copyright (C) 2008-2014 Andreas Bolka, Licensed under the [Apache License,
    Version 2.0][license].

    [license]: http://www.apache.org/licenses/LICENSE-2.0

File `test/fixtures.py`:

{% highlight python %}
import os, signal, time

_BEANSTALKD_PID = None

def setup(module):
    beanstalkd = os.getenv('BEANSTALKD', 'beanstalkd')
    module._BEANSTALKD_PID = os.spawnlp(
            os.P_NOWAIT,
            beanstalkd,
            beanstalkd, '-l', '127.0.0.1', '-p', '14711')
    time.sleep(0.5) # Give beanstalkd some time to ready.

def teardown(module):
    os.kill(module._BEANSTALKD_PID, signal.SIGTERM)
{% endhighlight %}

File `.nose.cfg`:

{% highlight ini %}
[nosetests]
verbosity=3

with-doctest=1
doctest-extension=mkd
doctest-fixtures=_fixtures
{% endhighlight %}

Let's find the magic `_fixtures` here!

> Use the Doctest plugin with --with-doctest or the NOSE_WITH_DOCTEST environment variable to enable collection and execution of doctests. Because doctests are usually included in the tested package (instead of being grouped into packages or modules of their own), nose only looks for them in the non-test packages it discovers in the working directory.
>
> Doctests may also be placed into files other than python modules, in which case they can be collected and executed by using the --doctest-extension switch or NOSE_DOCTEST_EXTENSION environment variable to indicate which file extension(s) to load.
>
> When loading doctests from non-module files, use the --doctest-fixtures switch to specify how to find modules containing fixtures for the tests. A module name will be produced by appending the value of that switch to the base name of each doctest file loaded. For example, a doctest file “widgets.rst” with the switch --doctest_fixtures=_fixt will load fixtures from the module widgets_fixt.py.



### See also:

* [doctest](https://docs.python.org/2/library/doctest.html)
* [Doctest wiki](http://en.wikipedia.org/wiki/Doctest)
* [Doctest-introduction](http://pythontesting.net/framework/doctest/doctest-introduction/)
* [Nose doctest plugin](http://nose.readthedocs.org/en/latest/plugins/doctests.html)

(Write The Fuck Document, M2Crypto.)
