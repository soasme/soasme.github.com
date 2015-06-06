---
layout: post
category: technology
title: Fix zsh tput unknown terminal and fish Could not set up terminal
tag: system
---


When I tried to login my shell, iTerm2 will output these messages:

```
Last login: Wed May 27 08:29:16 on tty??
tput: unknown terminal "xterm-color"
tput: unknown terminal "xterm-color"
tput: unknown terminal "xterm-color"
tput: unknown terminal "xterm-color"
tput: unknown terminal "xterm-color"
~ %
```

Even though I have set ENV in ~/.zshrc:

```
export TERMINFO=/usr/share/terminfo
export TERM=xterm-256color
```

It seems that my setting is not working.

Same case happens as using fish-shell:

```
fish: Could not set up terminal
```

The hacking solution is to change iTerm2’s preference:

Inside `Profiles`, set every profile’s `General` -> `Command` to a
customized Command:

```
env TERM="xterm-256color" TERMINFO="/usr/share/terminfo" /usr/local/bin/zsh
```

If you like using fish, you can fix that command to

```
env TERM="xterm-256color" TERMINFO="/usr/share/terminfo" /usr/local/bin/fish
```

Note: Keep in mind that $TERM does exist in $TERMINFO !
