---
layout: post
category: technology
title: 在 Python 中往日志混入数据
---

今天遇到一个奇怪的问题：最新打出的日志记录，其时间都是两天以前的，并且很多记录的时间戳是完全一样的。经过排查，可以断定，我们的实现有问题，导致打出的日志时间是进程启动后第一次打印日志记录的时间，而非日志记录的生成时间。

由此引出我刚才想解决的问题：该如何在日志中混入数据。

## 错误的做法

{% highlight python %}
fluent_handler.setFormatter(
    fluent.handler.FluentRecordFormatter({
        'hostname': '%(hostname)s',
        '_tag': tag,
        '_time': datetime.now(tzlocal()).isoformat(),
    })
)
{% endhighlight %}

在早先实现的版本里面，我们将 `_time` 作为格式器的配置项传入。这也是我们导致这个问题的根源。`datetime.now(tzlocal()).isoformat()` 生成的时间作为 `Formatter` 的实例变量，在这行代码执行完后就固定了。

## 可行的做法：

* 覆写 [fluent-logger-python/fluent/handler.py FluentRecordFormatter](https://github.com/fluent/fluent-logger-python/blob/master/fluent/handler.py#L20)
的 `format` 方法，在覆写后的方法中混入 tag 及 time 数据。

> format(record)
>
>     The record’s attribute dictionary is used as the operand to a string formatting operation. Returns the resulting string. Before formatting the dictionary, a couple of preparatory steps are carried out. The message attribute of the record is computed using msg % args. If the formatting string contains '(asctime)', formatTime() is called to format the event time. If there is exception information, it is formatted using formatException() and appended to the message. Note that the formatted exception information is cached in attribute exc_text. This is useful because the exception information can be pickled and sent across the wire, but you should be careful if you have more than one Formatter subclass which customizes the formatting of exception information. In this case, you will have to clear the cached value after a formatter has done its formatting, so that the next formatter to handle the event doesn’t use the cached value but recalculates it afresh.

{% highlight python %}
class Formatter(FluentRecordFormatter):

    def format(self, record):
        data = super(Formatter, self).format(record)
        if isinstance(data, dict):
            data['_time'] = datetime.now(tzlocal()).isoformat()
            data['_tag'] = record.name
        return data

...
fluent.handler.FluentRecordFormatter(Formatter({
    'hostname': '%(hostname)s',
}))
{% endhighlight %}
* 编写 Filter 类，Filter 类的设计意图除了允许过滤日志记录，还有一个便是原地修改日
志的内容。

> filter(record)
>
>     Is the specified record to be logged? Returns zero for no, nonzero for yes. If deemed appropriate, the record may be modified in-place by this method.

{% highlight python %}
class TimeFilter(logging.Filter):

    def filter(self, record):
        if isinstance(record.msg, dict) and '_time' not in record.msg:
            record.msg['_time'] = datetime.now(tzlocal()).isoformat()
        return True

class TagFilter(logging.Filter):

    def filter(self, record):
        if isinstance(record.msg, dict) and '_tag' not in record.msg:
            record.msg['_tag'] = record.name
        return True

...
fluent_handler.addFilter(TimeFilter())
fluent_handler.addFilter(TagFilter())
{% endhighlight %}

## 结论

考虑到混入内容实质上是在改写日志记录的内容，我更倾向于使用第二种方法(Filter)。

以上。
