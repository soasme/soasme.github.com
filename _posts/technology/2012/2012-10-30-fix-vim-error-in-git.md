---
layout: post
title: 修复vim在git提交时的报错
category: technology
tags: [vim, git]
---


这个报错很诡异，已经很多天了。想来想去，觉得是vim退出时可能返回了错误的状态码。

解决办法: [stackoverflow](http://stackoverflow.com/questions/1799891/why-do-i-get-a-warning-after-i-say-git-commit)

    ➜  vagrant git:(master) ✗ git commit
    error: There was a problem with the editor 'vi'.
    Please supply the message using either -m or -F option.
    ➜  vagrant git:(master) ✗ vim
    ➜  vagrant git:(master) ✗ echo $?
    0
    ➜  vagrant git:(master) ✗ git commit
    error: There was a problem with the editor 'vi'.
    Please supply the message using either -m or -F option.
    ➜  vagrant git:(master) ✗ echo $?   
    1
    ➜  vagrant git:(master) ✗ git config --global core.editor /usr/bin/vim
    ➜  vagrant git:(master) ✗ git commit
    [master 8760dd7] my customize
     2 files changed, 5 insertions(+), 2 deletions(-)

错误原因: 应该是因为 `os x` 不像 `linux` 一样把vi自动替换为vim, 所以才会导致的报错:

    ➜  ~  whereis vi
    vi: /usr/bin/vi /usr/bin/X11/vi /usr/share/man/man1/vi.1.gz
    ➜  ~  whereis vim
    zsh: correct 'vim' to '.vim' [nyae]? n
    vim: /usr/bin/vim /usr/bin/vim.tiny /usr/bin/vim.nox /etc/vim /usr/bin/X11/vim /usr/bin/X11/vim.tiny /usr/bin/X11/vim.nox /usr/share/vim /usr/share/man/man1/vim.1.gz

所以才需要解决方案中重新设定 `core.editor` 为 `/usr/bin/vim`。

EOF
