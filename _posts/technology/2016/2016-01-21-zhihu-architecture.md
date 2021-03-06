---
layout: post
category: technology
title: 知乎架构变迁
---

这是今天做的笔记整理，关于知乎的架构变迁。

美国西海岸的单节点部署。 出现问题：网络延迟；解决方案：备案，在国内买机器。

中国机房单节点部署。 出现问题：内存泄漏，机器宕机；解决方案：高可用。

中国机房多节点部署。MySQL 一主多从，两个 LVS 示例，再加上 keepalived, 保证负载均衡的高可用。LVS 将请求转发到多个 Nginx 示例。Nginx 再转发到 Python 进程上。Redis 单实例。

出现问题：MySQL 主从有延迟；解决方案：读写分离。外加离线脚本同步数据。

出现问题：内网吞吐量很低；解决方案：换设备。

出现问题：Redis 单机瓶颈；解决方案：自撸 redis-cluster, 作 Sharding，保证一致性。

出现问题：没有日志系统；解决方案：自撸带订阅的类 Scribe 工具。

日志收集实例收集数据或被数据分析订阅（实时），或发送至中心节点，转储至硬盘，供数据分析（非实时）

出现问题：维护逻辑困难，解决方案：事件驱动。

出现问题：丢消息，解决方案：撸了一个中间件，先持久化，再发消息。

部署 beanstalkd，用做消息队列。

出现问题：页面性能不好。解决方案：重写页面渲染，组件化页面，少获取数据。

出现问题：系统难以维护。解决方案：RPC，服务化。在 WEB 与 数据存储层中间再加一层服务层。

出现问题：RPC 自动生成的代码太多，解决方案：撸了一套简单的 RPC 框架。

出现问题：RPC 框架搞不定服务版本升级的问题，解决方案：再加了一层版本定义。

出现问题：服务开始变多，管不过来，解决方案：基于 consul 做服务发现。

出现问题：服务化不好调优；解决方案：基于 zipkin 做 tracing system。

---

内容源是李申申的演讲。
从中我们可以窥探出的一些事情：

* 我们没有办法一开始就做好这些所有事情，只能做好一些事情，知道它的结局，然后等着预期问题来临的那一天。
* 问题驱动架构演化。
* 这里面有一些是跟 timeing 有关的决策。比如 redis-cluster，社区当时还没有足够成熟的方案。等不到那一天，就只能自撸快上。
* 然而，有一些事情是可以早期就能定下方案并去执行的，比如事件驱动。
* 使用社区提供的工具，能降低成本。

大概，以上。
