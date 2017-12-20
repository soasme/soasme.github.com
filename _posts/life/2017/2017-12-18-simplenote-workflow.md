---
layout: post
category: life
tag: diary
title: Simplenote 工作流
---

上一次阐述我的工作流已经是 4 年前了( 如何让Evernote摇身一变TO-DO APP)，在这里更新一下现在使用的方法。

## 使用场景

* 应用在工作，学习，生活，灵感，任务管理这五种场景。
* 会在公司电脑，私人电脑，云端服务器，智能手机上使用。
* 目标是：日志，进度管理，备忘，知识摄入，目标管理，习惯养成。

## 工具

由于使用场景的变更和希望更轻量对Markdown支持更好的需求，选择了 Simplenote + 一些运行在服务器上的 Python 小脚本 ＋ 一些 Alfred Workflow。

## 工作流简介

### 工作

每天开始工作前，新建一篇 Simplenote 的 Note，起名格式：`# WORK YYYY-MM-DD`，标签是公司名字。
内容格式大概长这个样子：

* 09 Check Emails: Portland Data Center had 2 alerts. Auto recovered after 10min.
* 09 #this-is-a-slack-channel
    * Problem: Current status of chef is: Failed to execute: xxx [link](url to slack)
    * Reason: pulled a bad chef-base repo.
    * Solution: repull and rebuild vdc.
    * Readmore: [confluence: this is a page](https://...) 
...
做一件事情前，在笔记中记录小时，然后事情，记录一些上下文和索引链接，代码片段，操作命令，对话摘要，会议议程大纲，会议纪要，搜索结果，问题记录，思考下一步怎么办的1234， 事故响应的时间线，等等等等不一而足。基本上什么都记，内容太多的就摘要一下。如果要分类，大约可以是：听到的信息，看到的信息，说过的话，做的所有事情，和想到的东西。

大约会在周一的时候，整理一下 Last week, 和 This week 两个小列表，整理下做过的事情和将要做的事情。

使用下来的体验：

* 找运行过的命令超级简单，因为标过标签在命令附近，例如 `* 09 #ldap #id #permission `id -nGn $USER`.
* 在记录的过程中，事情会越想越清楚。所谓的 Thinking by writing 不外如是乎。
* 回顾一天，一周做的事情很简单，扫一遍，即可。写各种 Report 的时候基本上 5 分钟就能成骨干（Copy & paste)，剩下的整理措辞。
* 缺点：在长跨度下（超过一周），基本就不看了，貌似工作日志，只在一两周范围内会非常有用。

### 生活

每天会有一篇格式大约是如下的文章出来：

# Life YYYY-MM-DD / 这是今天的主题
Blah, Blah, Blah
Blah, Blah, Blah
* 记事
    * 预定周二洗牙
* 饮食
    * Biriyani
    * CJK 拉面
* 娱乐
    * Amazing Race 14 季 07 集
每天可以通过饮食强制召唤起午餐和晚餐的时间节点，进而所有附近相关的记忆也会慢慢全都呈现出来。从脑袋一片空白到越来越多东西要记下来。

其实每天的 Blah, Blah, Blah 大约写的跟情书差不多 o(*////▽////*)q 会跟老婆协作，老婆偶尔打评论进去，我再跟帖。。。

### 学习

没什么好说的，是公开的 http://simp.ly/p/0zNbd2

下一步，会把语言学习和创造性的输出也纳入这套体系。

### 灵感和任务管理

它是一篇 Simplenote 的置顶的 `My Workstation` 的笔记。它的重要章节如下面所介绍的。

每日更新 `## Tasks`.

## Tasks
- [x] 恢复 soasme.com 在 admin.google.com 的活动，已经一年没登录啦
- [y] 买露营帐篷，防潮垫，灯，睡袋。全部调查完毕。
- [ ] 预订 camp ground
- [x] 购买 18 Dec - 24 Dec 食材和准备下周的食谱
- [ ] 完成 Tech Shack, Mon, 12 Dec, 2018 的阅读
...
不定期更新 `## 习惯目标`

* Tech Shack: Mon - Fri in 2018, 260 Posts
* Crab Shack: Mon - Fri in 2018, 260 Posts
* Life: Mon - Sun, 365 Posts
* Work: Mon - Fri in 2018, 260 Posts
这个章节会不断通过脚本创建出新任务来。

剩下的章节都是属于灵感记录，一些会移入更正式的笔记，一些直接删了没意思，一些转入 gist，一些转入博客。。。

## 自动化

* Alfred 输入 uuid, 新建出一个唯一 ID，插入 Tech Shack
* 自动根据习惯目标新建任务
* 备份快照
* 自动新建特定类型的日记
* ...

## 总结

依然还是比较简单的工具，但是引入了更多自动化，所以心智负担没有更重，可以比专注的学习，记录，思考，产出。通过坚持不懈的更新，给自己营造出了忙碌，坚实，不断前进的正向反馈。感觉养成了很好的习惯。

EOF
