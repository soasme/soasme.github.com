---
layout: post
category: technology
title: Brew using proxy
tag: brew
---



When I want to download some package, it just do not work:

    ~ % brew install gnuplot
    ==> Installing dependencies for gnuplot: gd, lua
    ==> Installing gnuplot dependency: gd
    ==> Downloading https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.0.tar.g

    curl: (56) Recv failure: Operation timed out
    Error: Download failed: https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.0.tar.gz

F.

Anyway, VPN and proxy is easy to let it work.

```bash
    ~ % http_proxy=http://10.8.0.1:8118 brew install gnuplot
    ==> Installing dependencies for gnuplot: gd, lua
    ==> Installing gnuplot dependency: gd
    ==> Downloading https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.0.tar.g
    ######################################################################## 100.0%
    ==> ./configure --prefix=/usr/local/Cellar/gd/2.1.0 --with-png=/usr/local/opt/li
    ==> make install
    🍺  /usr/local/Cellar/gd/2.1.0: 32 files, 1.1M, built in 4.3 minutes
    ==> Installing gnuplot dependency: lua
    ==> Downloading http://www.lua.org/ftp/lua-5.1.5.tar.gz
    ######################################################################## 100.0%
    ==> Downloading patches
    ######################################################################## 100.0%
    ==> Patching
    ...
```
