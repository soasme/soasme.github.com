---
layout: post
category: technology
title: Pip & Git
---

As people commonly do, we claim requirements in `requirements.txt` file.
When we need a library, just add a line such as `library==0.1.0`.

If we need to install library from Git, pip enable us to do that.
pip currently supports cloning over `git`, `git+https` and `git+ssh`:

```
git+ssh://git@ghe.domain.com/org/repo.git#egg=repo
git+https://ghe.domain.com/org/repo.git#egg=repo
git+git@ghe.domain.com:org/repo.git#egg=repo
```

We can also passing branch names, a commit hash or a tag name as an url anchor:

```
git+ssh://git@ghe.domain.com/org/repo.git@0.1.0#egg=repo
```

We must know there are 2 types of installing mode:

* for editable mode, by adding `-e` option, pip will install library by cloning project into a `src` directory, which means source code included.
* for non-editable mode, the project is built locally in a temp dir and then installed normally.

```
-e git+ssh://git@ghe.domain.com/org/repo.git#egg=repo
```

Q: How to choose these modes?

A: If you have tagged git commit to a specified version, just use non-editable mode.

Normally, we will append version to egg is used by pip in its dependency logic to identify the project prior to pip downloading and analyzing the metadata. The optional "version" component of the egg name is extremely important if you want to upgrade library in non-editable mode. The format of egg is like `#egg=library-0.1.0`:

```
git+ssh://git@ghe.liwushuo.com/lws/flask-ldap.git@v0.5.0#egg=flask_ldap-0.5.0
```

<script src="https://gist.github.com/soasme/984675c55f3e97d7cd48.js"></script>
