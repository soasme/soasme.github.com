---
layout: post
category: technology
tag: SICP
---

SICP 读前言
=============

人类的活动大抵是离不开规划(program)的.

这要求, 首先心中有数, 其次执行有力.

若将规划编为一组供由计算机执行的离散符号, 可谓编程(我的理解).

易得:

* => 程序设计是一种心智活动.

* => 程序是一种媒介

To take advantage of the unsurpassed flexibility of this medium requires tremendous skill‑technical, intellectual, and esthetic. 

- Marvin Minsky

程序设计中牵涉到的3类对象: 人脑/程序集合/计算机.

人脑抽象模型, 直到一个 metastable place, 
模型实现为程序, 
程序被计算机执行.

人脑对模型的认知会加深至下一个 metastable place,
程序集合更趋近于模型的本质, 
计算机也更接近问题的精确解.

在这个认知过程中, 程序集合的演变不比模型认知变更那般简单, 它被多次付诸编写, 定型.

这个过程Alan J.称之为: Invent and fit; have fits and reinvent!

我们希望程序正确.

这需要:

1. 人脑对模型的认知正确
2. 程序集合是模型的正确实现
3. 计算机可以正确执行程序.

以前两点最难得以保证.

我们根据数十年的经验, 总结出了使大程序中的一个小部分总是正确的 standard program structures, 谓之 idioms.

它们是被正确认知, 被正确实现, 被正确执行, 可以通过谓词演算, 通过逻辑方法, 做出形式化的, 可接受的, 正确性的论证.

idioms是抽象的, 普适的, 所以:

它适于参与未知程序的构造, 成为大型程序系统的一小部分.

程序员应该追求好的算法和惯用法, 对程序设计的审美观有很好的感觉, 有能力控制程序集合的正确性和复杂性.

程序员专注于真正的问题: 需要计算什么, 如何分解问题, 如何组合这些部分. (坊间流传c系关注机器, lisp系关注计算, 此话不假).

事实上, 这些技巧也是所有工程设计所通用的.

感谢先驱们(已经都在天国了):

* Lisp 祖师爷 John McCarthy

* Lambda 神算子师徒 Alanzo Church, J. Barkley Rosser

* 将λ演算引入程序设计江湖, 提出闭包, 语法糖, 越位语法(Python徒子徒孙们请叩首): Peter John Landin

* Recursion Prophet: Stephen Cole Kleene

* 组合子 Haskell Brooks Curry


衍生阅读:

[WHY PROGRAMMING IS A GOOD MEDIUM FOR EXPRESSING POORLY UNDERSTOOD AND SLOPPILYFORMULATED IDEAS](http://web.media.mit.edu/~minsky/papers/Why%20programming%20is--.html)
