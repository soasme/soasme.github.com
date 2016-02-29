---
layout: post
title: Wheel Guide
---

Wheel 是一种格式。Wheel 文件是一个 Zip 包，后缀是 `.whl`。Wheel 文件包含了Python 源代码，而非 Python 编译后的中间字节文件。Wheel 文件还包含了编译后的二进制代码，如果有的话。安装 Wheel 通常是非常快的，因为不用构建。

tl; dr

### What is Wheel

Wheel 源自   PEP 426 (Metadata for Python Software Packages 2.0, use .dist-info instead .egg-info) 和 PEP 376 (Database of Installed Python Distributions, express dependencies), 遵循这些在 Egg 后才出现的标准。

Wheel 的设计宗旨是安装一个包可以通过 unzip 和 cp 完成：编译构建，是由包发行者来完成，且只需完成一次。
Wheel 是安装流程得到简化：用户安装 Python 包，只需要下载 Wheel 文件，解压到特定目录即可。
这个流程会导致以下一些后果：

- 因为打出来的包 unzip + cp 就能完成安装，所以 setup.py 不那么重要了。反而在 Wheel 里一些 METADATA 会比较重要，它指定了包适用的环境与平台。
- Wheel 只包含 Python 源代码，不包含 `.pyc` 文件，`.pyc` 文件是运行时生成的。
 
### The Format of Wheel Package

Wheel 的文件遵循标准 PEP 0427 - The Wheel Binary Package Format 1.0。
它希望在构建和安装中间提供一个简单的接口，使安装不再需要知道构建系统的细节。
Wheel 文件 中的 `.dist-info/WHEEL` 声明了包的版本，是否是纯 Python 包等重要信息。
Wheel 文件的文件名包含了诸多重要信息，注入包名，版本，适用Python版本，适用平台，适用的ABI类型。

### Wheel vs. Egg

- wheel 是一个安装包，内含构建的产物，而 egg 则是可移植的包，需要目标机器上构建产物；
- wheel 的内容放在 zip 包的 .dist-info 目录里; 而 egg 放在 .egg-info；
- wheel 的文件命名含义更丰富；
- wheel 包里有 wheel 的版本信息，egg 则没有
- wheel 有 pep 标准，egg 没有
- wheel 包 import 前需解压，egg 则不需要（对纯 Python 包而言）
- wheel 包包含 python 源代码，egg 包含 python 字节码。
- wheel 需要对不同的 Linux 平台发行不同的包，egg 则不需要（对非纯 Python 包而言）

### Usage

构建 Wheel 包：

    python setup.py bdist_wheel

安装时使用 Wheel 缓存：

- `pip install --use-wheel --no-index --find-links=http://wheelhouse.company.com` 
- `pip install --use-wheel --no-index --find-links=/path/to/wheelhouse`

可以使用一款叫做 devpi 的软件镜像和缓存 PyPI 包，上传和下载私有 wheel 包。

### References

- [Wheel 与 Egg 的比较](http://lucumr.pocoo.org/2014/1/27/python-on-wheels/)
- [Wheel History](http://wheel.readthedocs.org/en/latest/)
- [PEP 0427 - The Wheel Binary Package Format 1.0](https://www.python.org/dev/peps/pep-0427/)
- [DevPI](http://doc.devpi.net/latest/)
