---
title: Nim-markdown 性能优化
---

2020 年的最后一天，发现来的不是 2021 年，而是一个 GitHub Issue <https://github.com/soasme/nim-markdown/issues/48>
一个 Nim-Markdown 的用户报告性能问题，100kb 的文档，库解析要 4 秒。

在此之前，我从来没有考虑过性能优化，能把 markdown 几百个 spec 跑通已经是件很恶心的事情了。
但作为维护者，我还是承诺在 2021 年会给出一个修复。
此后两月，每每想要解决，总是改一行挂几十个 case，真的是怕了怕了！
我都撸完 Peppa PEG 一整个项目了，这个 Issue 就一直挂在那里。

眼看三月就要入秋了，一个小伙子发来了一个 PR <https://github.com/soasme/nim-markdown/pull/50> 带来了 25% 的性能提升。
哎，心想，该来的还是要来。
所以，最近别的项目都停更了，死磕这个性能问题。

这里稍微聊 Nimlang 里面做性能优化一定要用的标准库 nimprof，如下

    import nimprof
    enableProfiling()
    discard markdown(stdin.readAll)

编译时，带上 `--profiler:on` 选项即可。运行时，程序会产生一个 profile_results.txt 文件，里面的内容会从高到低排出最多被运行的指令或函数调用。

再稍微聊聊为什么会有性能问题。排查下来，最大的问题是字符串的 GC 开销：

    let a = "long long long string …."

做一次 slice: a[i .. j] 其实底下 malloc/free 都很吃时间的。Nim 中字符串 slicing 可能还涉及一些别的操作，如果仅仅使用 substr(a, i, j) 都会比 a[i, j] 快。事实上，如果你去看 nim 标准库的源码，strutils, parseutils 这些实现也都偏向使用 substr(a, i, j) 来做 slicing。

另外 a[i, j].matchLen(pattern) 替换成 a.matchLen(pattern, i, j) 也有立竿见影的效果 - 不需要额外的 malloc/free 开销。

同理，a.splitLines 在大文档的场景下也非常吃亏，不如去拿到行首和行尾的 index，有需要再去做 substr。

就这么花了半个月，每晚就这么 0.1s 0.1s 的优化，终于从 4秒优化到大约 100+ms 了。有点体会到钓鱼的人的乐趣。。。

哎，就是也没人给我 bounty，<https://nee.lv/2021/02/28/How-I-cut-GTA-Online-loading-times-by-70/>
