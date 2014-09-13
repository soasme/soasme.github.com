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
You first write a `tutorial.md` file:


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


### See also:

* [doctest](https://docs.python.org/2/library/doctest.html)
* [Doctest wiki](http://en.wikipedia.org/wiki/Doctest)
* [Doctest-introduction](http://pythontesting.net/framework/doctest/doctest-introduction/)

(Write The Fuck Document, M2Crypto.)
