---
layout: post
category: technology
tag: TAOCP
title: MIX 之殇
---

信手翻开了 TAOCP 一书， 心里有一点疑问。

到底将算法表达到高阶语言级别还是机器指令级别更好呢？

回想起前几天睡前为家鹅解释软件到底如何在硬件上运行。
我觉得使用机器指令作为表达的载体能让人更容易理解算法的流程。

但采取这种方法的弊端是显而易见的：
硬件模型变更后，指令集从 MIX 升级到到 MMIX ，令所有的算法都需要重写。
尽管高德纳不愿意承认，并觉得使用硬件代码不需要经常重写，但事实上他正在征集志愿者重写 TAOCP Vol 1~3 的代码。

以下是他认为使用机器指令写代码在今天仍有意义的原因：

* One of the principal goals of my books is to show how high-level constructions are actually implemented in machines, not simply to show how they are applied. I explain coroutine linkage, tree structures, random number generation, high-precision arithmetic, radix conversion, packing of data, combinatorial searching, recursion, etc., from the ground up.
* The programs needed in my books are generally so short that their main points can be grasped easily.
* People who are more than casually interested in computers should have at least some idea of what the underlying hardware is like. Otherwise the programs they write will be pretty weird.
* Machine language is necessary in any case, as output of many of the software programs I describe.
* Expressing basic methods like algorithms for sorting and searching in machine language makes it possible to carry out meaningful studies of the effects of cache and RAM size and other hardware characteristics (memory speed, pipelining, multiple issue, lookaside buffers, the size of cache blocks, etc.) when comparing different schemes.
* Moreover, if I did use a high-level language, what language should it be? 

我认为，代码长短是相对的。如果能用 3 行代码就能描述GCD，那么，30行的汇编代码就不能说很短。

全书使用汇编写是有问题的。我们可以介绍高阶语言如何转化为低阶语言，再使用高阶语言描述算法(这是SICP的做法)。
虽然对于机器真实运行的指令不是一眼就明的，但通过适当的推理绝对可以达到 `at least some idea of what the underlying hardware is like`。

我觉得 Dijkstra 也做的很恰当，他在编程的修炼一书中设计了能表达他想法的最小化语言实现：选择结构和卫结构。它稍微脱离了机器指令，但离任何一种流行的高阶编程语言都还尚远，即便如此，翻译为任何一种高阶编程语言都可以做到基本等价。Dijkstra 的设计在数学殇也是易于分析与证明的。

基于以上原因，我决定看完 MIX，MIXAL 后尽量以 Dijkstra 设计的小语言来解题目。
