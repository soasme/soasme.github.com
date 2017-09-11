---
layout: post
category: technology
tag: python
title: You don't need IPython
---

# You don't need IPython

For years, I kept listing IPython in `requirements.txt` for all my
projects. I admitted that IPython is a great tool and encouraged people
to use it. One annoy thing is that IPython has some dependencies,
which just makes my projects less tidy. So I'm finding a way to simplify
my working environment. My thought is to consider what exactly things
I need from IPython, and then see if I could find a replacement.

## Start a shell

Basically, simply typing `python` could lead us into Python Interactive
Mode.

Another way to kick off a shell progress is by embed this line of code
into my project's command line entry code:

```
@click.command('shell') 
def shell():
    # do some project setup.
    import code
    code.interact(local=locals())
```

Then by simply typing `my-cli shell`, it will launch a playground for
my project, with some variables pre-loaded.

## Auto complete

Auto-complete is a must-have feature.

Copy and paste below code to `# do some project setup` part above:

   try:
       import readline
   except ImportError:
       print("Module readline not available.")
   else:
       import rlcompleter
       readline.parse_and_bind("tab: complete")

We could start a Python shell with auto-complete now. Yay:

    >>> i<TAB HERE>
    id(          import       input(       intern(      isinstance(  iter(
    if           in           int(         is           issubclass(

## Edit tmpfile

A useful feature I like is typing `%ed` to edit code. It basically
launches Vim and executes saved code after quitting Vim.

My workaround is quit simple. Split terminal into two panels, left
for Python shell, and right for Vim editing. The workflow might be
something like this:

* Edit file in right panel (Vim editing).
* `:w` Save source code.
* `cmd+ctrl+h` Jump to left panel. This requires iTerm2 profile setting.
* `>>> execfile('/tmp/path/to/file.py')` Run saved file.
* `cmd+ctrl+l` Jump to right panel if any further code changing needed.
* back to step 0.

## View history

Something like `%hist`, showing shell running history.

Copy and paste below code to `# do some project setup` part above:

    def hist():
        for i in range(readline.get_current_history_length()):
            print(readline.get_history_item(i + 1))

All you need to do is typing `hist()` function. It will list
all commands you ran in this Shell session.

## Summary

Just a few lines of code provide me a good-enough Python shell
using experience. ☺️
