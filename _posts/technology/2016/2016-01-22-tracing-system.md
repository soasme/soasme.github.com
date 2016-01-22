---
layout: post
category: technology
title: 礼物说追踪系统
---

## 要做的原因

- 微服务架构容易出现一致性问题。必须通过事后回溯，恢复数据。
    - 场景举例
        - 用户下单商家收到推送通知去发货。
            - 在这个过程中，系统要把下单记录下来，要把消息队列中的推送提醒记录下来。有一天发现老是收不到提醒，开发者需要根据订单号搜索该订单的整个声明周期，然后发现只有消息入队，没有出队，意识到消费者挂了。重启消费者继续消费。
        - 领取优惠券：已登录用户直接领取；未登录用户登记手机号，注册后再领取。
            - 在这个过程中，系统要把用户信息获取，发优惠券或登记手机号记录下来。一旦有报告没有拿到，根据手机号查询领取历史，选择其中一次服务，发现发优惠券500了，重新执行一遍发优惠券。
- 微服务架构容易出现性能问题。必须
    - 1) 提前：规划服务的拓扑图。
    - 2) 事后：追溯系统运行性能。

## 需要达到的目标

- 前置条件
    - 可以很容易地收集服务日志。
        - 低负载
        - 应用层透明
        - 可扩展
- 后置条件
    - 根据条件筛选出想要的内容。
    - 可以很容易地核查某次服务调用的所有环节
        - 查出坏事务中丢失执行的服务，进而
            - 恢复未执行的子事务。
            - 撤销执行重试的子事务。
        - 查出服务调用链的瓶颈，进而
            - 改善系统性能。
            - 优化服务拓扑图

## 策略

- 黑盒：服务请求本身不需要添加任何信息。基于统计回归关联这些请求。将时间相关性更高的一批请求线性回归到一起。
- 标注：使用全局唯一的ID标记由用户请求，以及衍生出来的服务请求。
- 对比
    - 黑盒方案没有移植问题，有日志就能分析
    - 黑盒方案有准确率问题，要求建模足够好，也需要更多数据。
    - 标注方案有侵入性，需要所有服务公用一些日志的基础设置。

## 我早期设想的方案

- 所有内部服务提供的是 HTTP 接口，走反向代理。
- 基于标注。用户请求生成 X-Service-Transaction-ID, 并串联接下来的服务请求的耗时，来源，时间戳。
- 使用土脚本或流式数据处理监控：缺失执行或执行太久的事务抛出异常至 Sentry。

## 社区解决方案
- Dapper
    - Google 家的基础服务，dapper的维护团队说几乎所有的google的生产进程可能都植入了dapper。
    - 使用树形ID标记，每个服务调用记录根节点ID，父节点ID，自身ID，主机，时间戳。用户请求是根节点。
    - 一次服务调用会有至少两次日志记录，开始+结束。允许服务添加业务数据（注解）到日志（有个数限制）。记开头的原因与服务器时间不同步有关。
    - 追踪触发点：进程内的上下文有追踪容器，异步调用和同步调用使用两个公共的库，该两个库都保证异步调用上会带上追踪信息。
    - 性能损耗：可以选择性地关停，或做采样。损耗非常低，不纳入采样 9 ns, 否则 40ns 左右。（因为写数据基本都是异步的）。尽管如此，某些场景还是有可能有影响。google 的访问量大到采样率设为 1/1024 都足够。还能根据流量大小自动浮动。
    - 数据流：存储到本地，收集组件拉到Bigtable。数据到中央仓库会有2min到数小时时延不等。
    - 数据量：还行，目测大概0.1k吧。每天记大约 1TB 数据。
    - 数据安全：只记方法名，不记载荷数据；注解的内容会审核。
    - 代码：2k lines，主要包括节点创建，采样，写日志。
    - 访问方式：查特定的ID；MapReduce批量查时间窗口内ID的调用链；给节点建索引（主机，服务）地查。有很多内部 WebUI 工具。
- X-Trace
- Zipkin
    - Twitter 家的基础服务，所有 Twitter 的独立服务都用 Zipkin 收集时间数据。
    - 模型基本按照 Dapper 的来。树形标记，两次记录，附加注解，异步采样，...etc.
    - Fiangle: RPC 基础库，内建 thrift call 的 zipkin tracer 支持；也能支持 Tracer 直接发注解数据。
    - Transport: 使用了 Scribe，把数据发送到 Zipkin 和 Hadoop。
    - Zipkin Collector: 数据校验，存储，索引。
    - Storage：默认支持 Cassadra，其它对 Redis/MySQL/HBase 这三种的支持完整度待调研。
    - Zipkin Query Service: 查找 trace 数据。
    - Web UI
    - Span Receiver: 目前支持 Scribe 和 Kafka.
    - 组件 Instrumented Library，用于 Twitter 所有基于 Finangle 开发的 RPC 服务里。
    - 组件：Collector(pull from scribe/kafka), Cassandra, Query, Web。

## 结论

以上信息不太适合完全照搬，在得出如何搭建系统的结论前应该适用于一家公司特定的架构。
在自己撸实现方案和使用社区现有工具之间权衡 pros and cons，才能得到一个合适的结论。

- 黑盒方案：用作辅助方案。由于无法精确定位问题，仅保存数据，用于检测系统长期的性能情况。
    - 需要我们有个所有内部服务的负载均衡，并把日志集中收集
    - 需要研发一个统计模型，定时生成结果。
- 标注方案：主方案，
    - 整个收集系统选用 Zipkin。
    - 收集器使用fluentd, 并使用插件 fluent-plugin-scribe 将 fluentd 的数据以 scribe 的格式输出给 Zipkin, 有现成插件 fluent-plugin-scribe。
    - 基于 Flask/requests/combu 写一套 zipkin 支持的数据结构发送到 fluentd。
        - 基于 Flask 提供一个库，实现 Dapper 论文的模型，扒一下 finagle-zipkin， 支持
            - 树形标记，两次记录，附加注解，异步采样。
            - 能装饰请求路由，发送追踪信息到 fluentd。
            - 能装饰蓝图，将蓝图下的所有路由发送追踪信息到 fluentd。
            - 能单独发送额外的追踪信息到 fluentd。
            - 能生成带追踪参数的适用于 requests 的参数。
            - 能生成带追踪参数的适用于 combu Message 的参数。
        - 使用：
            - 以如下使用方式启动 Flask 应用时，需要将嵌套的 Microservice Call 纳入追踪：
                - python manage.py shell
                - python scripts/somescript.py
                - python manage.py runserver
        - 调用时机
            - http request: 由于目前基于 RESTful 的 microservice 方案性能还不确定是否足够好，span 的数据会在传输层前后记录两笔注解：数据序列化/反序列化的开销。
                - before request
                - after response
            - message queue
                - enqueue
                - dequeue
                - consumed

## 一些值得学习的策略

- Blackbox 是个很有意思的模型，以后在考虑零侵入式，又对准确性要求不高的场景，这是一个很适合的模型。
- 跨系统的信息传导，通过追踪参数来做到。这是一个很常见的做法，例如 [Google Analytics URL Builder](https://support.google.com/analytics/answer/1033867?hl=en)

## 资料

- [distributed tracing in 5 minutes](http://www.slideshare.net/dkuebrich/distributed-tracing-in-5-minutes)
- [Dapper, a Large-Scale Distributed Systems Tracing Infrastructure](http://research.google.com/pubs/pub36356.html)
- [Zipkin - Strangeloop](http://www.slideshare.net/johanoskarsson/zipkin-strangeloop)
- [X-Trace](http://x-trace.net/pubs/xtr-nsdi07.pdf)
- [Zipkin](https://twitter.github.io/zipkin/index.html)
- [Fluentd can connect to Zipkin Collector using fluent-plugin-scribe. You can trace timing data with Fluentd and Zipkin :)](https://twitter.com/fluentd/status/474255256197804032)
