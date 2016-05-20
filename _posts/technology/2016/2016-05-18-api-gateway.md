---
layout: post
category: technology
title: API 网关
---

## 简介

将单体应用服务化后，应用的逻辑委托给一至多个服务执行。
以知乎的架构为例， 用户请求通过负载均衡组件转发到一个 WebN 的实例。
Web01~WebN 在系统层次上可以认为是 API 网关层。
它通过内部服务的负载均衡调用各种内部微服务。

API 网关的出现使得这些服务被收敛到一个粗粒度的接口中。

业界对于 API 网关有着大量成熟的实现，其中以下几款产品为翘楚：

- Amazon AWS
- Netflix OSS
- Spring Cloud

这些系统成熟可靠。
如若一家公司的技术栈与上述产品相契合，我认为直接应用是个不错的选择。
而如果因诸如新的技术栈风险，运维人力资源不足等原因，无法直接应用，自行设计一套网关将会面临很多挑战。

以下提供了一套基于 Python + Tornado 的方案，希望可以得到大家的借鉴与指导。

## 方案

API 网关应用以 Tornado 的实例运行在一批服务器上组合为集群，放置在负载均衡层下层。

API 网关有一些模块组成

- 配置与路由模块
- 请求处理模块
- 请求中间件
- 服务调用模块

### 配置与路由模块

该模块用于配置 API 网关的系统设定，其中与网关领域相关的关键设定有：

- 路由配置: 决定资源对应的路由函数，提供三种选择
  - 配置路由至处理请求处理函数
  - 配置转发至后端服务
  - 配置提供 Mock 数据
- 服务节点配置: 决定调用的内部服务集合，可变更服务提供方（例如 dev cluster / stag cluster / prod cluster）
- 容错设定: 例如
  - 特定服务的超时与重试
  - 特定服务的特定接口容错方案，可选项包括（Circuit Beaker/Bulkhead Isolation/Load Shedder/Fallback）
- 统计配置: 统计服务配置。打点收集数据，用于网关的实时监控。可接入不同的 Transport，例如 Fluentd / Statsd 等
- 日志配置: 配置系统日志级别，格式化输出，以及日志处理器

API Gateway 传入路由与配置作为 tornado.web.Application 的参数。

### 请求处理模块

该模块由开发者自行实现。

网关应能提供：

- async yield 语法糖，使用同步的语法编写异步代码
- 提供请求至响应期间的上下文数据
- 错误处理的捕获
- 静态声明一个资源请求处理函数使用到的后端服务

应用开发者通过继承 tornado.web.RequestHandler 编写请求处理函数。

### 请求中间件

该模块用于增强网关特性，默认不启用，但作为可选项提供给开发者。其中包括：

- Document Autogeneration
- JWT
- CDN
- Metric
- Rate Limit
- Ban IP
- Tracing

### 服务调用模块

该模块用于调用内部微服务，其中包括三个子模块：

- 序列与反序列化模块
- 有能力支持多种服务调用协议, 例如 HTTP / Thrift / gRPC 等。
- 容错模块，提供 Fail Fast / Fail Silent / Fallback 三种容错实现。能对服务调用做熔断/半熔断/隔离等。

API Gateway 在框架级别提供了 make_request 的实现，封装以上子模块的细节。

### 其它

一些辅助的模块，例如

- Benchmark 模块，可以对系统做压力测试，给出测试报告，方便调整容错设定
- Test 模块，可以提供单元测试级别的服务调用抛错 Mock，方便测试。

API Gateway 的设计基于一些假定：

- 没有设计用户身份相关的模块，假设该部分逻辑由 Account Service 与 Session Service 提供。
- 没有 ACL 鉴权相关的模块，假设权限控制由一个单独的 ACL Service 提供。

## 特性

### Adaptor

API Gateway 通过路由模块为客户端与内部微服务做适配。
API Gateway 为平滑迁移降低了成本，我们可以就不合理的服务划分聚合或再拆分，而同时对外稳定的接口。

### Bridge

通过路由转发，API Gateway 可以将请求转为内部的 thrift / gPRC 等调用。
在某些场景中可以认为是 protocol proxy。

### Composer

API Gateway RequestHandler 是聚合内部微服务的数据与操作，大量的轻量业务逻辑在这里实现。
RequestHandler 应当是无状态的。这将保证 API Gateway 可以水平扩展。
RequestHandler 应当是事务性的。一个接口不应该调用两个微服务的事务，除非场景是事务不敏感的。
如果出现了大量此类调用，后端微服务应该考虑合并。
RequestHandler 应当考虑到服务调用总是可能是失败的，应当编写容错逻辑。

### Fault Tolerant

API Gateway 的服务调用模块是其最核心的模块，主要参考自 Netflix Hystrix 的设计。
这个模块的设计目标是：

- 为依赖的服务调用提供延迟与失败的保护。
- 防止雪崩。在依赖的后端服务崩溃时，可以熔断对整个系统做保护。
- 提供快速失败和快速恢复的弹性机制：熔断 - 半熔断 - 恢复。
- 尽可能回退，优雅降级
- 能实时监控报警

这个模块通过以下方法解决容错：

- 所有外部请求通过容错模块提供的请求函数执行
- 全局/单独设定超时时间与重试次数(推荐时间为使99.5%请求能成功的值)
- 为每个服务提供隔离的，有限个 ThreadPoolExecutor，防止一个服务吃光所有资源
- 测量成功/失败/超时等情况，用于熔断
- 服务的请求基于 circuit beaker 状态机，如果处于熔断则完全拒绝请求，处于半熔断则放行少量请求。
- 为失败/拒绝/超时/半熔断的请求配置回退的逻辑
- 实时监控

通过以上方法，即使单个服务失败，接口对外表现仅为降级，而非失败。

### Graph

API Gateway 对大量的服务进行调用，这对服务的全局依赖关系提出了很高要求。

上述设计中，静态声明后端服务 这个设定可能不太好理解。
理论上可以通过静态分析来获得后端调用的全局图谱，但是 Python 是动态语言，静态分析不太方便。
所以，我想通过静态注解的方式描述服务的依赖关系。

另外一种获取服务依赖关系的方法是通过中间件 Tracing 模块，将数据收集至类似 Zipkin 这样的系统中用于分析。
这种方法可以实时勘测系统的运行时调用图谱，但是增加了系统维护的成本。
在有足够资源的情况下，开启这一选项是推荐的。

## 小结

近两年内，出现了大量以 API Management 为主营业务的创业公司。
此类系统的设计应该会雨后春笋一样不断冒出来。

一个良好的 API Gateway 应该做到

- 开发迅速
- 方便扩展
- 容错

上面的设计借鉴了业界很多成熟的实现。
这次设计得到了老婆的大力帮助，收获良多。
另外，哲叔和其它同事也给了不少意见。

## 资料

- 1. 知名公司的内部解决方案
    - a) (知乎](~/space/mine/github/pages/_posts/technology/2016/2016-05-18-api-gateway.md)
    - b) Netflix
        - (1) [Netflix API Redesign(http://techblog.netflix.com/2012/07/embracing-differences-inside-netflix.html)
        - (2) [Netflix RxJava](http://techblog.netflix.com/2013/02/rxjava-netflix-api.html)
        - (3) [Netflix 的 Api Gateway](http://www.chanpin100.com/archives/50391)
        - (4) [柠檬叔的日记](https://www.douban.com/note/507823285/)
        - (5) [构建微服务的基础框架](http://www.infoq.com/cn/articles/basis-frameworkto-implement-micro-service)
    - c) [Uber building tincup](https://eng.uber.com/building-tincup/)
    - d) [Evernote and thrift](https://blog.evernote.com/tech/2011/05/26/evernote-and-thrift/)
    - e) 阿里
        - (1) [阿里云 API Gateway](https://www.aliyun.com/product/apigateway)
        - (2) [手淘后端架构 两层网关](http://www.infoq.com/cn/articles/taobao-mobile-terminal-access-gateway-infrastructure)
- 2. 企业级解决方案
    - a) [Amazon AWS Lambda](http://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html)
        - (1) [Amazon AWS Lambda tutorial(auth0)](https://auth0.com/docs/integrations/aws-api-gateway/part-1)
        - (2) [Amazon API Gateway](https://aws.amazon.com/cn/api-gateway/?nc1=h_ls)
        - (3) [Amazon api gateway build and run scalable application backends](https://aws.amazon.com/cn/blogs/aws/amazon-api-gateway-build-and-run-scalable-application-backends/)
        - (4) [Amazon API Gateway -  Build and Run Scalable Application Backends](https://aws.amazon.com/cn/blogs/aws/amazon-api-gateway-build-and-run-scalable-application-backends/)
    - b) Sprint Cloud
        - (1) [使用Spring Cloud和Docker构建微服务](http://dockone.io/article/510)
        - (2) [Building REST APIs with Spring Boot and Spring Cloud](http://www.slideshare.net/KennyBastani/building-rest-apis-with-spring-boot-and-spring-cloud)
        - (3) [Sprint Cloud API Gateway Suite](https://github.com/rohitghatol/spring-boot-microservices/tree/master/api-gateway)
        - (4) Example: Spring Boot Template for Micro services Architecture - Show cases how to use Zuul for API Gateway, Spring OAuth 2.0 as Auth Server, Multiple Resource (Web Services) Servers, Angular Web App, Eureka dor registration and Discover and Hystrix for circuit breaker [Read more](https://github.com/rohitghatol/spring-boot-microservices/tree/master/api-gateway)
    - c) [IBM bluemix](https://console.ng.bluemix.net/docs/services/APIManagement/index.html)
    - d) [another IBM bluemix example](http://www.ibm.com/developerworks/library/se-publish-restapis-bluemix-trs/index.html )
- 3. 以 API Management 为主营业务的 Startup 解决方案
    - a) [akana](https://www.akana.com/solutions/api-gateway)
    - b) [JustAPIs](http://devhub.justapis.com/docs/terminology)
    - c) [Netscaler](https://www.citrix.com/content/dam/citrix/en_us/documents/products-solutions/netscaler-with-unified-gateway.pdf)
    - d) [apigee](http://apigee.com/about/products/api-management)
- 4. 其它解决方案
    - a) [Awesome API gateways](https://github.com/mfornos/awesome-microservices#api-gateways--edge-services)
- 5. 简介
    - a) [Pattern: API Gateway Introduction](http://microservices.io/patterns/apigateway.html)
    - b) [Nginx Building Microservices: Using an API Gateway](https://www.nginx.com/blog/building-microservices-using-an-api-gateway/)
- 6. 实现
    - a) [tortic](https://github.com/glibin/tortik)
    - b) [tornado proxy api-gateway](https://github.com/restran/api-gateway)
    - c) [Kong](https://getkong.org/)
    - d) [StrongGateway](https://github.com/strongloop/strong-gateway)
    - e) [如何容错](https://github.com/Netflix/Hystrix/wiki)
    - f) [Tracing Tornado HTTP](https://github.com/bdarnell/tornado_tracing)
    - g) [自带debug页查看所有请求的耗时](http://glibin.github.io/tortik/)
