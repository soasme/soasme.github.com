---
layout: post
title: 在OpenShift上使用Jekyll
category: technology
tags: [openshift, jekyll]
---



ssh到openshift机器上后默认执行gem install jekyll是没有权限的.

    > gem install jekyll
    Fetching: liquid-2.4.1.gem (100%)
    Fetching: fast-stemmer-1.0.1.gem (100%)
    Building native extensions.  This could take a while...

    .......
    .
    Fetching: classifier-1.3.3.gem (100%)
    Fetching: directory_watcher-1.4.1.gem (100%)
    ERROR:  While executing gem ... (Errno::EACCES)
        Permission denied - /var/lib/openshift/blablablablablablabla/bin

sudo也不行

    sudo gem install jekyll
    bash: /usr/bin/sudo: 权限不够

我们可以通过自定义 Home 来达到安装jekyll的目的, 不介意的话写

    > export HOME=~/app-root/runtime
    > echo $HOME
    /var/lib/openshift/blablablablablablablabla/app-root/runtime
    > gem install jekyll

    gem install jekyll
    Fetching: liquid-2.4.1.gem (100%)
    Fetching: fast-stemmer-1.0.1.gem (100%)
    Building native extensions.  This could take a while...

    .......
    .
    Fetching: classifier-1.3.3.gem (100%)
    .
    bla bla bla.....

    > gem install rdiscount
    ..........
