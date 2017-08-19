---
layout: post
tag: asyncio
category: technology
title: 休息一下
---



长期在电脑前边工作，对视力的影响很大。我们需要一些手段提醒自己在工作一段时间后要注意休息。市面上当然有很多相关的定时休息软件，我也推荐使用它们。事实上，如果只是需要一个倒计时的小工具，我们完全可以自己简单写一个。`asyncio` 官方文档的 [18.5.1.18.2](https://docs.python.org/3/library/asyncio-eventloop.html#display-the-current-date-with-call-later) 中就提供了一个很简单的倒计时的实例代码，我们在这里稍加改编来完成我们的需求。

我们的需求如下：

* 输入命令 `take-a-rest` ，进入倒计时模式
* 每秒钟界面上会刷新还剩多少秒
* 可以通过环境变量配置一次休息多少秒

实现它的代码很简单，如下所示，将这段代码存为 `take-a-rest` 。

```python
#!/usr/bin/env python3

import os
import sys
import asyncio

REST_SECONDS = int(os.environ.get('REST_SECONDS') or 60)

def report(left_time):
    sys.stdout.write("Resume working after %d seconds. \r" % (left_time))
    sys.stdout.flush()

def rest(end_time, loop):
    current_time = loop.time()
    report(end_time - current_time)
    if (current_time + 1.0) < end_time:
        loop.call_later(1.0, rest, end_time, loop)
    else:
        loop.stop()

loop = asyncio.get_event_loop()
loop.call_soon(rest, loop.time() + REST_SECONDS, loop)
loop.run_forever()
loop.close()
```

为了使用方便，我们通过执行命令 `chmod +x take-a-rest` 为这个脚本赋予可执行的属性，并将这个文件移动到 `$PATH` 所在的目录中。现在，我们可以直接在命令行中输入命令，就能进入倒计时模式：

```bash
$ take-a-rest
Resume working after 60 seconds.
```

我们通过 `int(os.environ.get('REST_SECONDS') or 60)` 获得环境变量中的配置，并设置默认值为 60.

函数 `report(left_time)` 的功能是在命令行中显示目前还剩多少秒可以回到工作。特别地，字符 `\r` 可以让输出结束后的光标回到行首。通过这种方法，我们可以在新的一次调用中将上一次的输出替换掉。

函数 `rest(end_time, loop)` 的功能是决定是否还继续倒数。当尚未到达倒数时间点，我们继续触发一次 `rest(end_time, loop)`；当到达倒数时间点，我们停止运行事件循环。换句话说，当 `loop.stop()` 调用后，`loop.run_forever()` 也将停止。最后我们关闭事件循环，程序结束。

函数调用`loop.time()`的返回值是类型为浮点数字的当前时间，它取决于事件循环的内部时钟。

上述的代码其实隐含地包括了一段逻辑：执行一个函数，当调用结束时，停止事件循环。我们可以使用 `loop.run_until_complete` 函数简化它：

```python
#!/usr/bin/env python3

import os
import sys
import asyncio

REST_SECONDS = int(os.environ.get('REST_SECONDS') or 60)

def report(left_time):
    sys.stdout.write("Resume working after %d seconds. \r" % (left_time))
    sys.stdout.flush()

async def rest():
    for left_time in range(REST_SECONDS, 0, -1):
        report(left_time)
        await asyncio.sleep(1)

loop = asyncio.get_event_loop()
loop.run_until_complete(rest())
loop.close()
```

函数调用 `loop.run_until_complete(future)`  不像上面使用的 `loop.run_forever()` 一直执行下去，而是一直执行直到传入的 `future` 对象执行完毕。如果传入的是个协程对象，`asyncio` 会使用 `ensure_future()` 将这个协程对象转为 `future` 对象。

我很喜欢这个小工具。为了更好地提示自己该休息了，我使用了一段 `bash` 主题的配置，它会按照我的休息时间提示我是否该休息了。有关这段主题配置的代码我放在了 gist 上，[前往阅读](https://gist.github.com/soasme/78e1d5e9854a8e66e69984a2692a72a0)。