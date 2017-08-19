---
layout: post
tag: asyncio
category: technology
title: asyncio 的事件循环 
---


异步编程的核心是事件循环。如果说异步编程是一台机器，那么事件循环就是这台机器的引擎。一旦事件循环停止运行，那么异步编程就变成了"零步编程"了。事件循环，顾名思义，指的是一个处理事件的循环。循环，是每个程序员最开始就学习的知识。循环是一种控制流程，可以按照指定的次数重复运行一段程序。事件循环是一种专用于处理异步事件的循环，循环内的代码负责注册，执行，以及取消异步函数调用。



## 获取事件循环对象

为了获得一个事件循环，一个进程必须做的事情就是调用 `asyncio.get_event_loop` 函数。

```
函数 asyncio.get_event_loop()
等价于调用 get_event_loop_policy().get_event_loop()。
```

例如，在 Mac OSX 10.12 中运行如下 iPython 的代码片段，将获得一个事件循环对象。

```python
In [1]: import asyncio

In [2]: loop = asyncio.get_event_loop()

In [3]: loop
Out[3]: <_UnixSelectorEventLoop running=False closed=False debug=False>
```

这个函数不需要传入参数。首次调用这个函数，程序将初始化一个事件循环对象。连续调用这个函数，不会产生新的事件循环对象。这是因为初始化以后的事件循环对象作为当前线程的本地变量，被存储于 `threading.local` 对象的实例中。我们可以通过查看这个 loop 的内存地址验证这个结论（如下）。两次连续的调用获得的事件循环对象的内存地址是同一个，这说明 `asyncio.get_event_loop()` 函数调用返回了同一个事件循环对象。

```python
In [4]: id(asyncio.get_event_loop())
Out[4]: 4539261504

In [5]: id(asyncio.get_event_loop())
Out[5]: 4539261504
```

上面的结论也暗示我们，事件循环对象是线程不安全的。我们不能直接将事件循环对象应用于多线程的场景。在不扩展 `asyncio` 功能的前提下，即使用 `asyncio` 默认的事件循环实现，仅有主线程会存在一个事件循环，其它线程默认不存在事件循环。

## 事件循环的类型

目前在 Python 3.6 中，`asyncio` 支持两种类型的事件循环：`SelectorEventLoop` 与 `ProactorEventLoop`。这里做一下简单的介绍，我们还会在后面的篇幅中详细介绍它们。

`SelectorEventLoop` 这种事件循环基于模块 `selectors` 。这个模块会根据程序运行的操作系统对 I/O 多路复用 (I/O Multiplexing) 的支持，自动选择效率最高的实现。I/O 多路复用是一种 IO 操作的实现方法。通常，我们在同步模型中做 `read()` 和 `write()` ，我们只有在一个操作完成后才能继续另一个操作。而借助 I/O 多路复用技术，我们可以通过一个线程同时检查多个文件描述符的状态变化来实现异步 I/O 操作。上文出现的 `_UnixSelectorEventLoop` 就是 `SelectorEventLoop` 的子类。具体来说，在 `Linux` 2.5+ 中，它会选择 `epoll()` 作为实现；在 Solaris 中，他会选择 `devpool()`作为实现，在大多数 BSD 系统中，它会选择 `kqueue()` 作为实现。`ProactorEventLoop` 这种事件循环是专为 Windows 系统编写的，它基于一种叫做 I/O 完成端口 (I/O Completion Port) 的技术。



## 设置事件循环对象

在上面我们介绍了使用 `asyncio.get_event_loop`  获取事件循环，那么是否存在一个函数设置事件循环对象呢？答案是存在的。我们可以通过 `asyncio.set_event_loop` 函数设置想要的事件循环对象。这个函数接受一个事件循环对象作为参数。

```
函数 asyncio.set_event_loop(loop)
等价于调用 get_event_loop_policy().set_event_loop(loop)。
```

例如，我们可以通过如下代码可以针对 Windows 操作系统使用 `ProactorEventLoop` ：

```python
import asyncio, sys

if sys.platform == 'win32':
    loop = asyncio.ProactorEventLoop()
    asyncio.set_event_loop(loop)
```

执行过上述代码片段后，再次调用 `asyncio.get_event_loop()` 就将获得我们设置的事件循环对象。注意上述分支内的代码仅适用于 Windows 操作系统。
