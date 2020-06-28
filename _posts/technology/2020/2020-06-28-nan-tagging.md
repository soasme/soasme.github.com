---
title: NaN Tagging
category: technology
---

看到一个好玩的概念，叫做 [NaN Tagging](https://github.com/wren-lang/wren/blob/93dac9132773c5bc0bbe92df5ccbff14da9d25a6/src/vm/wren_value.h#L486-L541).
这个小技巧在 LuaJIT 中也被得到了应用, 见 [HN](https://news.ycombinator.com/item?id=11327166)。

[NaN](https://en.wikipedia.org/wiki/NaN) 在 [IEEE-754](https://en.wikipedia.org/wiki/IEEE_754) 中就是个特殊的浮点数。
在具体编码中，它被表示为 `s111 1111 1xxx xxxx xxxx xxxx xxxx xxxx`。s 是正负号，但一般没什么意义。后面接着 7 个 1， 然后就没有然后了，x 也没什么意义。

NaN Tagging 巧妙的利用了 `x 也没什么意义`, 将剩下的空间用于存储数据。
在编程语言的实现中，这剩下的 56 个 bits，可以被用于存储整形数，指针。
特别的，即便是 64 位系统，由于地址只需要 48 bits，因此空间还是够的。
这个设计直接导致了：在更高的抽象维度上的数据类型，包括整形，浮点，布尔值，指针，均可被塞入一个 64 bits 的内存中。
空间几乎全部利用了，不再需要额外定义 `struct Value { ... }`, 也不需要复杂的 box/unbox 即可做数字运算。
效率杠杠。

[这里]https://gist.github.com/apsun/46779ab1a8681822ccd4971f826272aa) 是一个 NaN Tagging 的小 demo，它的实现可以再完善一些，box_t 可以被定义为:

```c
typedef union {
  uint64_t b64;
  uint32_t b32[2];
  double   d64;
} box_t;
```
