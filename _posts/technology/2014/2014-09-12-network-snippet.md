---
layout: post
category: technology
tag: clojure
---

# Network snippet

在写 [beanstalk-clj] 的时候, 没有打算依赖更多的库, 于是裸写了 Socket 的交互:

<script src="https://gist.github.com/soasme/be04387e1c92dd21a9e5.js"></script>

Beanstalk 的协议还是比较简单, 一来一回, 格式都在文档里写的很清楚.
这个库直接使用 java.net.socket 进行网络交互.
网络调用读需要一点一点存下来, 拼在 StringBuilder 中. 写则简单了, 直接使用 socket.write.
