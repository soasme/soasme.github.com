---
layout: post
category: technology
tag: [twisted, asynchronous]
title: 在 Twisted Web 中调用同步方法
---

发现一个隐藏了很久的BUG，记一笔。

我原来给 Scrapyd 写过一个[小插件](https://github.com/soasme/scrapyd_kit)，希望可以同步等待爬虫的结果，并在接口中返回。

原来的实现是:

{% highlight python %}
class CrawlService(scrapyd.resources.JsonResource):

    def render_POST(self, request):
        resp = self.DO_SOME_SYNC_OPERATION(request)
        return resp
{% endhighlight %}

在日志中，发现有大量连续的超时响应，遂发现这个问题。

由于 Twisted 是单线程/事件驱动的，同步调用造成了调度线程被完全堵塞，进而完全无法对外服务。

修复依赖 Twisted 的异步 Response 特性，见[Twisted Developer Guide: Asynchronous Response](http://twistedmatrix.com/documents/current/web/howto/web-in-60/asynchronous.html): 我们需要将实现替换为返回 `NOT_DONE_YET`, 并在返回前触发一个异步操作，在异步操作中调用 request.write, request.finish。
另外，同步调用应当在额外的线程中执行，见[Twisted Developer Guide: Using Threads in Twisted](http://twistedmatrix.com/documents/current/core/howto/threading.html): 我们需要将同步操作塞到 callInThread 中执行。

修复如下：

{% highlight python %}
class CrawlService(scrapyd.resources.JsonResource):

    def render_POST(self, request):
        reactor.callInThread(self.DO_SOME_SYNC_OPERATION, request)
        return server.NOT_DONE_YET
{% endhighlight %}

上段时间写 Tornado 程序，被异步调用蹂躏了一番，这次很容易看出了问题。
修复已经发版到了 pypi 上，最新版本: 0.1.6 。
应该不会再出现同步堵塞Event Loop的问题了.
