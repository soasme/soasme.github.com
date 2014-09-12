---
layout: post
category: technology
tag: python
---

# Document with test for Python

介绍一种与常规 && 常见的 unittest, integrate test, doctest 风格完全迥异的测试: doc-with-test.

unittest, integrate test 大家写的比较多.
unittest 一般做模块的细粒度测试.
integrate test 一般做功能特性级别的粗粒度测试.

这里想就 doctest 与 doc-with-test 的区别简单介绍下.

###### Python doctest example:

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

执行 `$ python code.py`, 会输出

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


doctest 将测试和文档写在代码里.


###### doc-with-test example

doc-with-test 是将测试写在文档里.

听上去有点难以理解, 我也来做个简单的示例.

假设我们要给开发者写一份文档, 介绍 `idiot` 库怎么使用, 我们要写一个简单的教程,
就保存为 `tutorial.md`:

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

        >>> dull.add(1, 2)
        4

    See? He will never return a right answer to you.

    ## More?

    I think it is all of this library.
    Hope you using it in your production repo. Good luck!


然后我们写一份 nose 的配置文件 `.nose.cfg`

{% highlight ini %}
[nosetests]
verbosity=3

with-doctest=1
doctest-extension=mkd
{% endhighlight %}

然后运行之:

    $ nosetests -c .nose.cfg

就像你写了单元测试一样, 文档中的代码部分会全部被 nosetests 执行一遍.

## 说明

说穿了, 这就是 nose 的特性, 解析 markdown 文件, 去做 doctest.

## More?

doc-with-test 从粒度上来说算是一种集成测试, 它不适合用作单元测试.
如果你的库有大量的API需要说明, 不妨尝试下这种做法.

好处嘛, 我就不说了咯.

(去死吧, M2Crypto.)
