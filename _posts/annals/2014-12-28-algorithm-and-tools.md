---
layout: post
category: annals
title: 2014, 算法和工具
tags: annals
---

# 2014, 算法和工具


2014流水账: 练习半年英语和算法, 玩了半年Clojure, 培养了一个前端.
咻的一声~ 一年过去了. 总的来说, 好玩, 但还不够尽兴!

### 勤修内功练心法

书有载算法精要, 解题还需常修炼.
虽非练法奇才, 意在此生受用.
潜心读写, 孜孜不倦:

* 算法导论
* 算法
* 算法和数据结构
* leetcode(说来有愧, 已解尚不足三分之二, 当继续发奋图强).

![Leetcode](/images/2014/leetcode.png)

### 吾家有女初学成

家鹅闭关久矣, 决心转行前端.
现俨然新手, 每每夜半, 秉烛共学.

### 姓名在火星之途

今年某日, 记有我与 @ainesmile 两人名字之纸片飞向火星.

### 欲寄彩笺兼尺素

IMO 已用多年. 某天醒来, 竟不再支持 Google Hangout.
环顾 App Store, 竟无顺手之器.
遂造之自用, 名唤鸡脱壳, 谐音GTalk.
恋爱至今, GTalk 伴我俩每日, 离开不能.
因一直处于未完成态, 臭虫少许, 故只自用, 绝不能谓之趁手.
梳妆未完懒画眉, 狗粮自当自己食.

![Jabby](/images/2014/JabbyMerge.jpg)


#### 似屏如障堪游玩

三月份, 难得又碰 Lua, 编写游戏程式以练手: Flappy Bird lua clone.
调参数供 @ainesmile 遣玩, 速度忽快忽慢, 管道或上或下, 东倒西歪, 避之不及.
是为一乐事.

<div id="flappy-bird"></div>
<img src="/images/2014/FlappyBirdPhysicsWorld.gif" style="height: 500px;"/>



#### 信手黄犬花芯睡

算法解题之余, 随手为 Python 写解析/序列化 DSON 数据结构.
温习开源项目细节种种: 文档写作, 测试覆盖, 打包发布.

![DSON](/images/2014/dogeon.png)


### 一切有为法, 万物皆函数, 如露亦如电, 应作如是观

趣学 Clojure, 于 Java/JS/Python 践行FP.
此大概为入行数年 学得最为开心之语言.

### spymemcat

Clojure memcache client.

{% highlight clojure %}
(with-client memcached-client
  (set "set-key1" "value" 3600)
  (add "add-key1" "value" 3600)
  (replace "replace-key" "value" 3600)
  (touch "touch-key" 3600))
{% endhighlight %}


### beanstalk-clj

Clojure beanstalkd client.

{% highlight clojure %}
=> (put client "body")
1N
=> (reserve client)
#<Job beanstalk_clj.core.Job@3695149e>
{% endhighlight %}

### and a practise

Using om, core.asyc.

![assoc](/images/2014/assoc.png)


### 工作

产出趋慢, 然复用性, 可测试性变高, 希望不是件坏事.
因同事交接, 得以处理些数据的, 算法的, 持续集成的任务种种, 多多益善尔.

### 其它

以及一些学了小有时日却又未有甚么产出:

* Axe(Library)
* BBC News(ESL)
* Crash Course(ESL)
* Jenkins Configuration(Tool)
* Neo4j(Database)
* OpenResty(Library)
* Padas(Library)
* RubyMotion(Library)
* Scientific American(ESL)
* Slack Integration(Tool)
* Storm(Library)
* Swift(Language)

### 爷爷, 再见

岁末, 爷爷去世, 心中伤痛, 难以抚平.
爷爷一生勤俭, 刚正不阿, 锤凿劈刨, 手艺精湛.
造桥, 围垦, 修铁路, 建水库, 关乎民生, 心系家国.
孙自视匠人, 当以爷爷为榜样, 学习今生不止, 手艺磨练不息.

### 总结

* 书不在多读, 在于读精, 是以今年读书少而细.
* 事不在多做, 在有所得, 是以工作平奇却得多.
* 器不在多造, 在琢在磨, 是以做慢工而出细活.

去年心愿回顾:

* √ Clojure 玩了小半年
* X 没能看完10+英文小说, 只看了浮士德, 呼啸山庄.
* √ 出现了第三座书山


### 2015

* 筹备人生大事
* 认知计算, 程序的构造与解释
* Language
  * Scheme
* 算法
  * 温习常见数据结构
  * POJ
* Blog
  * Most in English
  * Serial
