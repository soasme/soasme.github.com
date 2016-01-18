---
layout: post
title: Idea - Flask Profiler
category: technology
---

在豆瓣工作的时候，每个豆瓣开发者都能在 web 界面上看到 profile log。
这对于查找瓶颈，分析性能很有帮助。

跳出豆瓣的技术栈后，一直并没有找到符合心目中理想的 Profiler，特别是对 Flask。

Werkzeug 提供了一个 WSGI Middleware，可以把报告按照请求输出到日志或目录。

我希望的性能报告可以比这个工具更灵活，它可以分析任何可以分析的东西（例如数据库记录，缓存读取等等）， 又可以有各种输出方式。

考虑了下实现，我觉得以日志作为中间存储是个不错的选择： 在想要做性能分析的模块中打印一些日志，在请求响应时执行日志输出的逻辑。

它的实现见 [github](https://github.com/soasme/flask-profiler/blob/master/flask_profiler.py).

预设的功能有：

* 输出一次请求的所有函数调用(cProfile)
* 输出一次请求的所有数据库调用(SQLAlchemy)
* 可以选择输出到 HTML 的底部
* 可以选择作为 JSON 响应对象的一个字段 输出

当然，这个 Profiler 的写法是很容易扩展的(至少我是这么认为的)。

然而，我还不确定这个库的功能是否强壮，也还确实一份文档。
在足够稳定后，我会将它发布到 PYPI.

感谢一下库提供了实现思路：

* [fengsp/flask-profile](https://github.com/fengsp/flask-profile)
* [werkzeug](https://github.com/mitsuhiko/werkzeug/)
* [sqlalchemy](http://docs.sqlalchemy.org/en/latest/c)
