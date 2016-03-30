---
layout: post
category: technology
title: 几个必设的 Nginx 参数
---

在使用 Nginx 作内网应用负载均衡与反向代理的时候, 一般需要下文提到的几项参数。

## upstream

设定 upstream server 列表:

    upstream app_servers {
        server    10.0.0.1:8888;
    }

## server_name

用于分派路由。

例如：

    server_name  openid.intra.example.org;

## listen

如果有提供用户界面，最好监听 443.
如果是完全的 SOA 的服务，可以只监听 80.

## ssl

将 SSL 证书放好，指定 ssh_certificate, ssh_certificat_key.
指定协议，千万不要把 SSLv3 之类的货色丢进去。

    ssl_certificate /etc/nginx/ssl/bundle.crt;
    ssl_certificate_key /etc/nginx/ssl/perm.key;
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 5m;
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

## location

### client_max_body_size

没有特殊的要求，使用默认配置即可。
涉及上传文件或者有批量处理的接口，最好计算一下上限，然后配置这个值，否则会有 413 报错。

    client_max_body_size 10m;

### proxy

配置反向代理的参数，proxy_pass 指到先前设定过的 upstream server.

    proxy_redirect     off;
    proxy_set_header   Host             $host;
    proxy_set_header   X-Real-IP        $remote_addr;
    proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;
    proxy_pass         http://app_servers;


### access_log, error_log

应用日志混杂在 Nginx 默认的日志文件里面非常不方便查找问题。
记得配上这两个参数。


