---
title: Callgrind
---



使用 callgrind 报告输出函数指令的调用占比，可以快速定位和修复 C 程序性能瓶颈。以下是使用 callgrind 的一点不重要的小笔记。

我发现，使用 Peppa PEG 编写的 JSON 解析器运行非常的慢。构造的测试用例是深度嵌套的 JSON Array 数据结构：`[[[[[…]]]]]`, 左边一千个 `[`, 右边也一千个 `]`。写好一个程序后，使用 `valgrind —tool=callgrind` 生成一个注解文件 `callgrind.out.$PID`。再使用 `callgrind_annotate` 即可将注解文件合并生成最终报告。示例：

```
$ gcc -g  peppapeg.c examples/json.c && valgrind --tool=callgrind ./a.out
$ callgrind_annotate callgrind.out.63642
1,265,470,759 (100.0%)  PROGRAM TOTALS
--------------------------------------------------------------------------------
Ir                    file:function
--------------------------------------------------------------------------------
706,187,168 (55.80%)  peppapeg.c:P4_NeedLoosen [/app/a.out]
320,620,450 (25.34%)  peppapeg.c:P4_IsTight [/app/a.out]
170,320,160 (13.46%)  peppapeg.c:P4_IsScoped [/app/a.out]
 25,020,000 ( 1.98%)  peppapeg.c:P4_NeedSquash [/app/a.out]
 10,000,000 ( 0.79%)  peppapeg.c:P4_IsSquashed [/app/a.out]
  4,617,160 ( 0.36%)  ???:_int_free [/usr/lib64/libc-2.28.so]
  3,382,226 ( 0.27%)  ???:malloc [/usr/lib64/ld-2.28.so]
```

这个报告把问题报告的非常清楚，程序整整有 94% 时间浪费在这几个 P4_ 的调用上。如果可以优化掉它们，就能带来 10 倍的性能提升。

具体修复过程就不赘述，无外乎空间换时间和减少调用开销。下面的 Issue 关联了 三 个 PRs 用于改善性能。

<https://github.com/soasme/PeppaPEG/issues/15>

经过修复后，调用量直降了两个数量级。

```
33,294,688 (100.0%)  PROGRAM TOTALS
--------------------------------------------------------------------------------
Ir                  file:function
--------------------------------------------------------------------------------
5,259,163 (15.80%)  ???:_int_free [/usr/lib64/libc-2.28.so]
3,846,555 (11.55%)  ???:malloc [/usr/lib64/ld-2.28.so]
2,595,108 ( 7.79%)  peppapeg.c:P4_Match'2 [/app/a.out]
2,078,669 ( 6.24%)  ???:free [/usr/lib64/ld-2.28.so]
1,841,351 ( 5.53%)  peppapeg.c:P4_MatchLiteral [/app/a.out]
1,805,004 ( 5.42%)  ???:__strlen_avx2 [/usr/lib64/libc-2.28.so]
1,705,988 ( 5.12%)  peppapeg.c:P4_MatchChoice'2 [/app/a.out]
1,518,598 ( 4.56%)  peppapeg.c:P4_Expression_dispatch'2 [/app/a.out]
1,260,936 ( 3.79%)  ???:strdup [/usr/lib64/ld-2.28.so]
1,174,097 ( 3.53%)  peppapeg.c:P4_MatchRepeat [/app/a.out]
1,092,247 ( 3.28%)  peppapeg.c:P4_RaiseError [/app/a.out]
1,003,802 ( 3.01%)  ???:__memcpy_avx_unaligned_erms [/usr/lib64/libc-2.28.so]
```

在修复后重新输出的报告中，所有的耗时调用均被消除，程序最大头的消耗落在了 malloc/free，这完全符合身为解析器的最大要务：malloc/free 语法树 Token。事实上，这个千层饼 JSON 的运行时间也从 0.15 秒降到了 0.012 秒，我们也确实感知到了 10 倍的性能提升。

```
$ time ./a.out
real	0m0.012s
user	0m0.009s
sys	0m0.002s
```

看了下其他 JSON 解析器的使用，Python 的也不多说，没改限制的情况下，调用栈被打爆了。Nim 首次运行大概需要 0.9 秒，JIT 后一直稳定在 0.018 左右。

```
$ cat testjson.nim
import json, strutils
let s = "[".repeat(1000) & "]".repeat(1000)
discard parseJson(s)
```

当然啦，跟 cJSON，RapidJSON 等专为 JSON 优化的解析器相比，自然是比不过的（大概在 0.04s 左右）。我觉得性能调优到这里已经可以算有阶段性成果了。

下一篇，我打算看看 valgrind massif 的用法，它看起来可以报告程序对 Heap 的使用。

最后，欢迎关注 我的新项目 Peppa PEG，an untra lightweight PEG parser in ANSI C.

<https://github.com/soasme/PeppaPEG>
