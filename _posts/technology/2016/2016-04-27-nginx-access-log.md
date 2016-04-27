---
layout: post
category: technology
tag: nginx
title: nginx access log
---

早晨尝试给数据喂一些设备的请求信息。
虽然最后发现客户端没有带上这些信息从而作罢，但是还是学到了一点冷知识。

Nginx 的访问日志比我想象的厉害一点，`ngx_http_log_module` 模块可以自定义日志格式。
日志格式通过指令 `log_format` 来定义，日志输出通过指令 `access_log` 来定义。

## log_format

默认的输出格式的名字叫 combined。
我们可以自定义输出格式的名字，这个名字将可以用在 access_log 里面指定这种自定义格式输出到哪里。
输出格式的字符串中可以填入由 $ 开头的的变量。

有一些内建的变量，例如 `$bytes_sent`, `$request_time`, `$status`, `$time_iso8601` 等等。
可以通过 `$sent_http_` 前缀获取响应 header，例如 `$sent_http_content_length` 可以获取响应长度。
可以通过 `$http_` 前缀获取请求的 header，例如 `$http_user_agent`。
可以通过 `$cookie_` 前缀获取请求的 cookie，例如 `$cookie_session`。

缺失的内容会被使用 `-` 填充。

## access_log

使用 `access_log off` 关闭日志，但是不建议这么做。
使用 `access_log /var/log/nginx/app-event.log` 将 combined 日志输出到文件。
使用 `access_log /var/log/nginx/app-event.log my_log_format` 将自定义的输出格式输出到文件。

可以使用 gzip, 或者 compress 压缩内容。
可以使用 flush 设定刷到磁盘的间隔或 buffer 设定缓冲区的大小。
可以使用 if 来过滤请求。

## 总结

以上用法在 `ngx_http_log_module` 模块的文档中有更多介绍。

### 接口设计与实现

在指令的设计上，有 formatter 和 handler 的两层封装，与大多数日志库的使用是一样的。

Nginx 可能在解析日志后使用一张表存储了每个 server 的 log_format，而在输出时将请求的数据应用到多种格式输出到目的文件。

### 替代方案

估计没有很多人会喜欢解析 nginx access log，因为脏数据比较多。
如果不是非必需，应用自己收集日志可能可用性更高。

来源: [ngx_http_log_module](http://nginx.org/en/docs/http/ngx_http_log_module.html)
