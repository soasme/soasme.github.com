---
layout: post
category: technology
tag: vim
---

在安装我的[`soasvim`](https://github.com/soasme/soasvim)到 `OS X 10.8.2` 后报错打开python会报错:

    "a.py" [New File]Traceback (most recent call last):
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site.py", line 565, in <module>
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site.py", line 547, in main
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site.py", line 278, in addusersitepackages
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site.py", line 253, in getusersitepackages
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site.py", line 243, in getuserbase
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/sysconfig.py", line 523, in get_config_var
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/sysconfig.py", line 419, in get_config_vars
    File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/sysconfig.py", line 298, in _init_posix
    IOError: invalid Python installation: unable to open /usr/include/python2.7/pyconfig.h (No such file or directory)

解决方案:

<script src="https://gist.github.com/hasanozgan/3186381.js"></script>
