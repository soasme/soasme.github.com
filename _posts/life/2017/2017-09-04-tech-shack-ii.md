---
layout: post
category: life
tag: techshack
title: Tech Shack II
---

这阵子可老实了，自从又开始看书看技术帖子以后，整个人像打了麻药一样，变得比较镇静。不太亢奋是件好事啊！

给 techshack.soasme.com 做了一些改进：优化了样式，添加了 https，总结部分添加了 markdown 渲染，做了网站数据定时备份。
其余维持不变：按天聚合当天看过的帖子；定时发布静态网站。

目前在做的事情是重构所有代码，毕竟是从一个 gist 转过来的项目，原来代码还比较脚本流，不太好维护。

内容方面尽力做到每天能看完五篇帖子，有时候一些文章看得很透的话，三四篇也成。

统计一下：

```
# 写了13天啦～
sqlite> select count(distinct substr(created, 0, 11)) from stanza;
13

# 写了61篇啦～
sqlite> select count(1) from stanza;
61

# 写了 15k 字啦～
sqlite> select sum(length(thoughts)) from stanza;
15744
```

总而言之呢，这套流程目前流转顺畅，看样子用上几个月以上概率还是蛮高的。

![](/images/2017/Rick-and-Morty-Pickle-Rick.jpg)
