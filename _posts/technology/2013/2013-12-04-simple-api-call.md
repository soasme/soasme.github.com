---
layout: post
category: technology
tag: api
---

一个简单的API调用
===

按照设想中的调用:

    client = Client('https://api.github.com')
    for obj in client.repos('soasme', 'retries').branches.GET():
            print obj.name, obj.commit.sha, obj.commit.url

这样等价于调用 `https://api.github.com/api/v3/repos/soasme/retries/branches`.
于是练了一下手, 写了下面的实现:

<script src="https://gist.github.com/soasme/7798580.js"></script>

不过, 突然想起来, 有个叫[kadirpekel/hammock](https://github.com/kadirpekel/hammock)的库, 其实是一样的. 看它的实现, ╮(╯_╰)╭ 
