---
layout: post
category: technology
title: Relocatable virtualenv
---

### virtualenv uses absolute path

You might be familiar with these commands:

    $ virtualenv venv
    $ source venv/bin/activate

After activating, virtualenv will change your sys env: $PATH.
That’s what exactly executes in `venv/bin/activate`:

    VIRTUAL_ENV="/private/tmp/venv"
    export VIRTUAL_ENV

    _OLD_VIRTUAL_PATH="$PATH"
    PATH="$VIRTUAL_ENV/bin:$PATH"
    export PATH

You might have noticed that there is an absolute path `/private/tmp/venv` embed in the script.

Absolute path exists also in bin scripts.

    $ head -n1 venv/bin/pip
    #!/private/tmp/venv/bin/python2.7

In computing, a shebang is the character sequence consisting of the characters number sign and exclamation mark (#!) at the beginning of a script. That’s why there’s no need for activation when you directly run a `venv/bin/pip`.

You can find absolute path in each `pyc` file inside venv/lib dir.

    In [1]: import marshal

    In [2]: f = open('venv/lib/python2.7/site-packages/pip/__init__.pyc', 'rb')

    In [3]: f.read(8)
    Out[3]: '\x03\xf3\r\n\xc5\xd4\xf5V'

    In [4]: code = marshal.load(f)

    In [5]: print code.co_filename
    /private/var/folders/2g/xtwm8ql505v4cn4wtxlr2tch0000gn/T/pip-build-UR6agf/pip/pip/__init__.py

### relocatable problem

So here is the problem:

> Since absolute path is tightly tied to so many files, it is impossible to copy `venv` to another computer.

Here is an example:

    $ cp -r venv newenv
    $ rm -rf venv
    $ newenv/bin/pip --version
    zsh: newenv/bin/pip: bad interpreter: /private/tmp/venv/bin/python2.7: no such file or directory

`pip` in `newenv` cannot find program `/private/tmp/venv/bin/python2.7` to run itself due to missing `venv`.

### `virtualenv --relocatable ENV`

You can fix up an environment to make it relocatable with `--relocatable` option.

NOTICE: you have to activate first and then run `virtualenv --relocatable`:

    $ source venv/bin/activate
    (venv) /tmp % virtualenv --relocatable venv
    Making script /private/tmp/venv/bin/easy_install relative
    Making script /private/tmp/venv/bin/easy_install-2.7 relative
    Making script /private/tmp/venv/bin/pip relative
    Making script /private/tmp/venv/bin/pip2 relative
    Making script /private/tmp/venv/bin/pip2.7 relative
    Making script /private/tmp/venv/bin/python-config relative
    Making script /private/tmp/venv/bin/wheel relative

    $ head -n4 /private/tmp/venv/bin/pip
    #!/usr/bin/env python2.7

    import os; activate_this=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'activate_this.py'); exec(compile(open(activate_this).read(), activate_this, 'exec'), dict(__file__=activate_this)); del os, activate_this

We can see that `pip` is now using relative path by exec `activate_this.py`, instead of using shebang `#!/private/tmp/venv/bin/python2.7` as first line.  Shebang `#!/usr/bin/env python2.7` will find python2.7 program defined in sys env `$PATH`. Line `import os; ...` will find python libraries by executing `activate_this.py` first, which insert `venv/lib/python2.7/site-packages/` to `sys.path` if it is a *nix system.

You may happily copy venv to another place,

    $ cp -r venv newenv
    $ rm -rf venv
    $ source newenv/bin/activate
    (venv) $

But it comes to a totally mess:

 `source newenv/bin/activate` won’t work. you might noticed that after activating, you did not enter into `newenv`, but entered into `venv`. It’s because the activate scripts are not currently made relocatable by `virtualenv --relocatable`.

 Newly installed library won’t be relocatable if you don’t run `--relocatable` again. We can not easily run `--relocatable` in `newenv` environ, Since `activate` has broken I explained above. Let’s specify $PATH and $VIRTUAL_ENV to bypass it:


    $ newenv/bin/python newenv/bin/pip install pytest
    Collecting pytest
      Using cached pytest-2.9.1-py2.py3-none-any.whl
    Requirement already satisfied (use --upgrade to upgrade): py>=1.4.29 in ./newenv/lib/python2.7/site-packages (from pytest)
    Installing collected packages: pytest
    Successfully installed pytest-2.9.1

    $ head -n3 newenv/bin/py.test
    #!/private/tmp/newenv/bin/python

    # -*- coding: utf-8 -*-

    $ PATH=newenv/bin:$PATH VIRTUAL_ENV=newenv virtualenv --relocatable newenv
    Making script /private/tmp/newenv/bin/py.test relative
    Making script /private/tmp/newenv/bin/py.test-2.7 relative

    $ head -n3 newenv/bin/py.test
    #!/usr/bin/env python2.7

    import os; activate_this=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'activate_this.py'); exec(compile(open(activate_this).read(), activate_this, 'exec'), dict(__file__=activate_this)); del os, activate_this


You can move the directory around, but it can only be used on other similar computers.  Unicode representation in python is determined once compiled. Different platform may use different python versions.

C libraries may have different prefixes. different versions or different filesystem layout  between computers. That will also cause virtualenv unrelocatable.

## how to solve?

### virtualenv-tools

Thanks to armin. This is a useful tool to solve all the problems listed above.

Once copied venv on the target server, use the virtualenv-tools to update the paths and make the virtualenv magically work in the new location.

To also update the Python executable in the virtualenv to the system one you can reinitialize it:

    $ virtualenv-tools --reinitialize newenv
    Already using interpreter /Users/soasme/.pyenv/versions/2.7.11/bin/python2.7
    New python executable in /private/tmp/newenv/bin/python2.7
    Not overwriting existing python script /private/tmp/newenv/bin/python (you must use /private/tmp/newenv/bin/python2.7)
    Installing setuptools, pip, wheel...done.
    Overwriting /private/tmp/newenv/bin/activate with new content
    Overwriting /private/tmp/newenv/bin/activate.fish with new content
    Overwriting /private/tmp/newenv/bin/activate.csh with new content
    Overwriting /private/tmp/newenv/bin/python-config with new content

    $ virtualenv-tools --update-path /tmp/newenv newenv
    A newenv/bin/activate
    A newenv/bin/activate.csh
    A newenv/bin/activate.fish
    S newenv/bin/python-config
    B newenv/lib/python2.7/_abcoll.pyc
    B newenv/lib/python2.7/_weakrefset.pyc
    B newenv/lib/python2.7/abc.pyc

- run `virtualenv-tools --reinitialize` will copy python binary in target computer into `bin`, instead of a python bin copied from build computer. That solved python unicode presentation problem, c libraries problem.
- run `virtualenv-tools --update-path` solve activate problem, newly installed library problem by updating:
  - update shebang in the head of bin scripts
  - update PATH in activate scripts
  - update pyc in lib, since the are relative with Python unicode code
  - updat some symlinks

### pip && wheel

`pip` has envolved these years:

- `pip download` can download dependencies into a dir
- `pip wheel` can build dependencies as wheel package( which is actually a zip file) into a dir. Wheels are the new standard of python distribution and are intended to replace eggs. There are several advantages of wheel. Fast is the most attractive property among them.
- `pip install --no-index --find-links` can install libraries from a dir

These features make relocatable virtualenv not that much important.

We can totally create a new virtualenv environment at target computer, and install python from wheels.

since they are all created at target server,

- unicode representing problem and c libraries problem won’t be an issue;
- there is no need to update path.

I worked on implementing it these days and [beeper](https://github.com/soasme/beeper.py) is a library to build a tar that can deployed to anywhere.

### REF

* https://coderwall.com/p/engshq/how-to-create-your-custom-virtualenv-installation-that-include-the-packages-of-your-choice
* http://pythonwheels.com/
* https://wheel.readthedocs.org/
* https://virtualenv.pypa.io/en/latest/userguide.html
* https://coderwall.com/p/engshq/how-to-create-your-custom-virtualenv-installation-that-include-the-packages-of-your-choice
* https://pypi.python.org/pypi/virtualenv-tools
* https://en.wikipedia.org/wiki/Shebang_(Unix)
