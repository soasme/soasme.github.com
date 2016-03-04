---
layout: post
category: technology
title: Python Packaging
---

Python 打包是一件日常的工作。稍微整理了一下最近觉得打包需要关心的事情。

### 初始项目

- 使用 [cookiecutter] 新建项目，基于 [cookiecutter-pypackage] 开始一个新项目。
- 将获得一些枯燥的文件目录组织和配置工作。

### Python Packaging

- Python 打包的若干细节, 写 setup.py, setup.cfg, MANIFEST.in, requirements.txt, 配置若干。
- 我选择一款叫 cookiecutter 的工具，每次使用 cookiecutter-pypackage 作为项目的模板。
- 用 `bdist_wheel` 打包，用 twine 上传发行版：不要用 `python setup.py sdist bdist_wheel upload` 。因为不安全。要用 `python setup.py sdist bdist_wheel && twine upload dist/*$VERSION*`。使用了 HTTPS 上传包，避免被劫持。
- MANIFEST.in 定义打包的目录，因为默认只有 py,c,test,scripts,readme,setup.cfg, 还有 package_data,data_files 列出的会包含。但是写在 MANIFEST.in 里会更好，规则有 include, recursive-include, prune
- `install_requires`: 定义项目抽象依赖，不建议钉死版本，应该写适用的版本区间。 
- 没有写过需要编译为二进制包的插件，所以没有经验。一般可以使用 cffi。这样可以把二进制的东东挪走，在 Python 这一层就只有接口封装。
- requirements.txt 与 install_requires: install_requires 是项目依赖，txt 是整个 python 的环境依赖，install_requires 是最小版本的依赖，requirements.txt 要列出并钉死所有版本。install_requires 是抽象的不设定外部源，requirements.txt 则需要指定具体的源。install_requires 会动态分析，txt 则不需要，按顺序执行下来即可。
- wheel vs egg: wheel 有 pep, egg 没有，wheel 是发布格式打包格式，egg 还是个运行时安装格式，可移植。但是似乎最近没有 wheel 流行了，特别是 pip 加入了 wheel 支持以后。
- 有一个很好地系列对打包的各种细节做了深入探讨， [Python Packaging]，WIP.

### Bumpversion

- 版本定义可能会出现在很多地方：项目定义，文档，`__version__`。按照 DRY 的原则，同时修改这些版本定义，可以用自动生成代码的方式来搞定。选用的工具可以是 [bumpversion]
- 添加配置到 setup.cfg 或 bumpversion.cfg，然后运行 bumpversion --version --dry-run patch 可以升级补丁，minor 升级小版本，major 升级大版本。去掉 --dry-run 可以生效。

配置：

    [bumpversion]
    current_version = 0.2.9
    commit = True
    tag = True

    [bumpversion:file:setup.py]
    [bumpversion:file:docs/conf.py]
    [bumpversion:file:package/__init__.py]

### 锁定依赖版本

- NPM 有 shrinkwrap, GEM 有 Gemfile.lock, PIP 也有对应的 requirements.in 与 requirements.txt. 它们的目的是构建是 predictable and deterministic 的。所以需要锁定依赖版本，并让锁接受版本控制。使用工具：pip-tools。
- 某次和 @tonyseek, @fleurer 的讨论内容如下：
    - pip freeze 的一个问题是弄脏 venv 之后 dump 出来的依赖就不干净了，pip-tools 没有这个问题，还支持 .pipignore 什么的
    - setup.py 声明依赖
    - requirements.in 声明从哪获取并钉死版本
    - requirements.txt 钉死依赖的依赖的版本

### devpi: PyPI server and packaging/testing/release tool

- 写完包，开源的就发到 pypi, 企业私有的可以搭个 devpi 的服务。 这是一个兼容 PyPI 服务的工具。
- devpi 能镜像 PyPI, 能上传/测试/预部署私有包。 索引有继承关系能逐级查找，例如 corp/pypi -> root/pypi, 企业内部的源可以继承 pypi 的源。
- 打包的人在 `.pypirc` 中配置 `[distutils]index-servers`, `[corp]username`, `[corp]password`, `[corp]repository`, 后，可以使用以下命令将包打到 corp/pypi 去。

    $ python setup.py register  -r corp
    $ python setup.py sdist bdist_wheel -r corp
    $ twine upload dist/*$VERSION* -r corp

- 普通项目使用时可以在 requirements.txt 中指定 `--index-url` 为企业私有的源。
- 对了，由于目前 pip-tools 还不支持 trusted-host 加到编译的 txt 中，目前最好的版本仍然是为企业私有的源也加上 https 支持

### 项目打包

- 与 库 打包不同的是，项目打包通常会有很多 build 流程，armin 出品的 [Platter] 工具可能足够使用。
- patter 使用上 先 build 项目为 tar, 再解压执行 ./install.sh && ln。tar 包含有项目 wheel 和项目依赖bundle wheel, install.sh 会新建venv环境并安装这些 wheel. 构建前后有钩子可以执行脚本。

### Reference

* http://nvie.com/posts/pin-your-packages/
* https://packaging.python.org/en/latest/current/

[cookiecutter]: https://github.com/audreyr/cookiecutter
[cookiecutter-pypackage]: https://github.com/audreyr/cookiecutter-pypackage
[bumpversion]: https://pypi.python.org/pypi/bumpversion
[pin]: http://nvie.com/posts/pin-your-packages/
[Python Packaging]: https://packaging.python.org/en/latest/current/
[devpi]: http://doc.devpi.net/latest/index.html
[Platter]: http://platter.pocoo.org/dev/
