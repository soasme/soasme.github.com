---
layout: post
category: technology
tag: api
---

同步方案
=======

API的某个Endpoint十分卡, 在每天两百万次调用中, 大约有5%的调用耗时超过1s.
在Profile后, 发现有不少调用缓存并没有命中, 而且存在mc的get过多的情况. 遂做了初步优化, batch获取数据(使用mc.get_multi)
调用的耗时初步减少.

由于此部分后端代码存在架构上的问题, 函数调用十分混乱, 于是第二版重写, 基本上数据调用能减少到一次.

在讨论第二版的设计时, 有过一些不切实际的想法, 这里列一下.


+ 分页 - 优点: 数据量可控, 对现有api架构改动最小. 缺点: 客户端连接数变多, 需要维护分页逻辑, 耗电量增加.
+ 流式 - 优点: 数据逐个得到响应.除非遇到异常/服务器升级/ 缺点: 需要客户端有流式响应的支持. 
    + 方案一 尽量复用现在的sync逻辑, 只是响应时使用flask的流式响应[flask-streaming], 对现在的架构来说只能复用请求解析和格式检查这两块, 缺点: 流程就不太能复用, sync写操作的耗时依然存在. 随着数据量增加依然会逐渐变慢. 服务器端同时能支持的流式请求数有限. 
    + 方案二 迅速得到列表, 然后分发任务到mq, view的逻辑就是不断接受队列里处理好的数据. 流式响应数据. 即使失去连接,重连也能继续接受任务. 扩展性好, 请求数变多增加后端机器即可. [example: twitter-streaming-api] 缺点: 架构开始变得复杂, 数据延迟性会变高, 返回数据会是乱序 调试会困难起来. 
+ socket - 优点: 连接开销比较小; 缺点: 另外还需要设计rpc的调用规约.
    + 单开接口 - 优点: . 缺点: 服务器端除了逻辑大为不同, 部署方式都需要变化
    + websocket - 优点: client比较多. 缺点: 据app开发反馈, 比较蛋疼. 求深入解释.

当然, 最后这些都没有采用. 事实上, 最后采用的方案是: 改为增量更新, 就是这么简单.

大家讨论结果有点忘了. 分页其实也是个可行的不错的方案. 流式事实上并没有改变进程堵塞的实际情况. socket算是一个有风险的选择吧, 一来公司没怎么有过socket的实践, 对于项目来说有未知的风险; 二来双工的调用会使服务端和客户端耦合, 架构变得脆弱. 连接开销小这个其实也是给我们的错觉, 带来的复杂度实际上抵消了这个优势.


### 分页逻辑的实现 
[example: github-pagination]

返回的参数可能包括: next, last, first, prev 
如果有next, 则可以继续请求next的请求.
如果next=last, 则所有数据获取完毕.


### 流式的实现:

每行一个JSON, 结尾是 `\r\n` (in hex, 0x0D 0x0A). 一行就是一条数据.

#### 方案一.

改动很小.

### 方案二.

Server:

```python

    from flask import Response, stream

    @app.route('/sync')
    def sync():
        asyc_start_getting_data(g)
        mq.watch('user-sync-{user_id}')
        def gen():
            while True:
                job = mq.reserve()
                yield job.message
        return Response(stream(gen()))
```

    

### Socket

可以实时交互执行命令.

#### 方案一 socket

O_O

#### 方案二 Web Socket

只要把received_message, open, close几个事件对应的代码写好就可以了.

[flask-streaming]: http://flask.pocoo.org/docs/patterns/streaming/#streaming-with-context
[example: twitter-streaming-api]: https://dev.twitter.com/docs/streaming-apis 
[example: github-pagination]: http://developer.github.com/v3/#pagination
