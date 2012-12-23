---
layout: post
category: technology
tag: vim
---

tmux下vim的配色
===

发生一件怪事，进入tmux后，用vim打开文件，以前的各种配色都不见了，甚为诡异。应该是进入tmux后terminal的配色方案出现了变化。

解决方案：

1. 在 `~/.tmux.conf` 中加一行

    set -g default-terminal "screen-256color"

2. 在` ~/.bash_alias` 中加一行

    alias tmux="tmux -2"

3. 执行 `$ source .bash_alias`

接下来进入tmux就可以使用漂亮的配色了。
