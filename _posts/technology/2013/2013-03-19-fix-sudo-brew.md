---
layout: post
title: sudo brew是禁忌
category: technology
tag: brew
---


因为曾经用过 `sudo brew` 的样子，所以 `/usr/local/include` 等folder被改成了root权限，下场：

    ~ % brew link gdbm libyaml
    Linking /usr/local/Cellar/gdbm/1.10... Warning: Could not link gdbm. Unlinking...

    Error: Could not symlink file: /usr/local/Cellar/gdbm/1.10/include/gdbm.h
    /usr/local/include is not writable. You should change its permissions.

拯救办法：

    ~ % sudo chown -R $(whoami) /usr/local/include
    ~ % sudo chown -R $(whoami) /usr/local/lib
    ~ % brew link gdbm libyaml
    Linking /usr/local/Cellar/gdbm/1.10... 6 symlinks created
    Linking /usr/local/Cellar/libyaml/0.1.4... 5 symlinks created

总之：**You should never have to use `brew` with `sudo`.**
