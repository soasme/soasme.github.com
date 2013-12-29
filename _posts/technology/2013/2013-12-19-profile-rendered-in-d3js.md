---
layout: post
category: technology
tag: d3.js
---

d3.js练手
=======

前几天有个需求要可视化一组数据, 特点: 按时间排序, 希望监控一些重点关照的Log的耗时. 一天大概会有200-500条这样的log.
组里之前用的cubism比较适合可视化连续波动类型的数据, 对这种单点的数据有点不太适用.
去[d3.js examples](https://github.com/mbostock/d3/wiki/Gallery) 里面翻了一圈, 竟然也没有找到合适的, 所以自己写了一个.
虽说自己写的, 也还是借鉴了里面的一个例子[The New York Times visualizations](http://www.nytimes.com/interactive/2012/05/17/business/dealbook/how-the-facebook-offering-compares.html?_r=0)的一组, 但是人家写的太多了, 组件各种复杂 - - 前端小白想抄无门...

所以自己按照心里想的画出了这样的统计图:

![image](/images/2013/p10569223.jpg)


耗时多的就直径就大只, 耗时小的直径就小只. 横轴是时间, 纵轴图简单就随机了, 因为直径大起来y轴的上下已经没啥意义了.


Useage:

[Gist](https://gist.github.com/soasme/8034417)

Profiling graph for events using d3
======

* `git clone https://gist.github.com/8034417.git`
* `cd 8034417`
* `python -m SimpleHTTPServer 8889`
*  visit `http://localhost:8889/dot_event.html`
