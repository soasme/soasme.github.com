---
layout: post
category: technology
tag: opensource
title: Simple Regex Language 
---

## 简介

SRL 是一个正则表达式的 DSL，其文档见 [Simple Regex]。[Simple Regex] 通过将正则表达式转化为自然语言来增加可读性。
正则表达式很强大，但新手入门门槛高。这个库加快了理解正则表达式的时间，非常适合新手学习。
其原始实现是 PHP, 这两天为语言编写了 Python 实现。仓库是 [SimpleRegex/SRL-Python]。

## 快速起步

- 大小写不敏感
- 逗号是可选的
- 子查询需要使用括号
- Characters 指的是可以匹配文字的部分：例如 `letter`, `digit`, `literally`等
- Quantifiers 用于指定出现次数
- Groups 用于分组 Characters 和 Quantifiers，可用于做子查询
- Lookarounds 用于做向前向后标记
- Flags 是正则的标记，比如贪心，大小写敏感等
- Anchors 用于指定起止

## 基本使用

```python
>>> from srl import SRL
>>> srl = SRL('digit exactly 3 times')
>>> bool(srl.match('123'))
True
>>> bool(srl.match('12'))
False
```

## 进度

基本流程：

- 使用 TDD 的方式，根据 PHP 项目的测试用例，快速构建起可用的 Builder
- 补齐 simple regex 文档页提供的测试用例
- 根据 Builder 写 Parser。
- 完成开源项目的标准配置：文档，证书，发版，注释等。

时间表：

- 1 Sep, 2016 编写了所有文档页提及的构建器方法，并通过了 srl 库对 builder 的所有单元测试用例
- 2 Sep, 2016 继续完善 builder，使其通过了 [Simple Regex] Documentation 描述的所有特性，使用与 beanstalkc 测试类似的技术结合了文档和测试
- 6 Sep, 2016 注意到上游原始PHP实现分化出了规范和各种语言的实现，均为占坑无实现状态。加入开发讨论组 simpleregex.slack.com。加入 SimpleRegex Github Developer Team。[soasme/SRL.py] 与作者讨论后做为 SRL-Python 的官方实现。注册了 Pypi SRL 包名。
- 7 Sep, 2016 使用 lex yacc 实现了一个 parser，并将 parser 应用于文档测试。
- 8 Sep, 2016 通过了所有的测试，针对命名，Builder的行为与开发组讨论，发出了第一个实现PR。编写了2/3兼容。重写了Documentation的文档测试。增加了新特性：打印SRL对象时显示正则表达式。实现合入主仓库。配置 Travis。发版 0.1.0。

## 学习

SRL-Python 的 Builder 实现与 SRL-PHP 是不谋而合的。
在单独实现的情况下，最后发现他们的实现几乎一样。

SRL-Python 的 Language Interpreter 实现与 SRL-PHP 完全不同。
作者对于 SRL-PHP 的 DSL 解析看起来还有缺陷。
这次在实现 SRL-Python 的过程中，第一次尝试使用了 lex + yacc 这套技术。
在已经有成文的规则后，使用 lex + yacc 实现一门 DSL 是相对简单的，
感觉上编码过程可以将注意力集中在规则的制定，而非解析组装这种细节。

SRL-Python 的单元测试在常规的测试用例之外还是用了文档测试。
第一次见到这种用法是在 [beanstalkc](https://github.com/earl/beanstalkc/)，在提供库的使用方法的同时，测试也同时写好了。
SRL-Python 的[说明书](https://github.com/SimpleRegex/SRL-Python/blob/master/specification.md) 本身也是很健全的测试。
Markdown 文档测试可以在 `.nose.cfg` 中指定。

EOF

[SRL]: https://github.com/SimpleRegex/SRL-PHP
[Simple Regex]: https://simple-regex.org
[soasme/SRL.py]: https://github.com/soasme/SRL.py
[SimpleRegex/SRL-Python]: https://github.com/SimpleRegex/SRL-Python)
