---
layout: post
category: technology
tag: python
title: PIP Install
---




服务器上的库想用`sudo pip install package`不太现实哎, 都被SA管着呢.
其实很想用virtualenv, 但是公司的库依赖管理对开发者不太透明, 库的依赖也懒得去自己整理.

稍微配置下其实可以绕开. 比如:

    export PATH=$PATH:$HOME/pip_packages/bin
    export PYTHONPATH=$PYTHONPATH:$HOME/pip_packages/lib64/python2.7/site-packages
    alias pip_install='pip install --install-option="--prefix=$HOME/pip_packages" '

如此一来, 想要安装包, 就可以使用 `pip_install package` 安装到本地了.
