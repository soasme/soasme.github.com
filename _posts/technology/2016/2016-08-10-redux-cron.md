---
layout: post
category: technology
tag: cron
title: redux cron
---

昨天写了个蛮有意思的脚本。

需求是这样子的：

- 这是一个耗时任务，但随时可以被中断
- 脚本可以从断点继续恢复执行

我们可以简单推断： 脚本需要持久化数据，以便重入时切回上下文。

解法有很多，但我说说我昨天是怎么解的。

0. 脚本会将所有操作序列线性地追加到一个文件，并根据执行该序列维护运行状态
1. 脚本每分钟触发一次运行，运行前需要先尝试读取该文件构建运行状态
2. 脚本的业务逻辑部分会根据运行状态生成下一个操作序列，直到完成所有操作序列。

示例：

{% highlight python %}
def add_event(stream, action, **payload):
    stream.write('%s\n' % json.dumps({
        'action': action,
        'payload': payload,
        'created_at': int(time.time()),
    }))

def load_events(stream):
    states = {} # default states
    for line in stream.readlines():
        data = json.loads(line.strip())
        if data['action'] == ACTION_1:
            # manipulate states by ACTION_1 payload
        elif data['action'] == ACTION_2:
            ...
    return states

def main():
    try:
        with open('stream.dat', 'r') as f:
            states = load_events(f)
    except IOError:
        print 'ioerror'
        return

    with open('stream.dat', 'a+') as f:
        next_action = get_init_action(states)
        while True:
            action, payload, states = yield_action(next_action, states)
            if action == DONE:
                break
            add_event(f, action, payload)
            next_action = action
{% endhighlight %}

它带来的好处：

- 不可变: 所有的运行状态都存储在 states 中，业务逻辑只要编写如何根据action构建状态，以及根据状态生成下一个action。
- 纯函数：没有副作用，函数的输出是可预知的。

写到这里突然发现，这货不就是 redux 么 - -

#智石更
