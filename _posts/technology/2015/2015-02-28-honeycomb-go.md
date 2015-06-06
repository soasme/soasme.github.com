---
layout: post
category: technology
title: Honeycomb GO
tag: game
---



想到一个好玩的游戏, 是围棋的变种.

棋盘是蜂窝状的(六边形表格).


规律:

    4x, 4x+3 为 n + 1 个
    4x+1, 4x+2 为 n 个

表格矩阵生成算法:

    lock_line_number = 3

    def make_table():
        table = []
        for i in range(block_line_number):
            for ii in range(4):
                if ii in (0, 3):
                    table.append([0 for _ in range(block_line_number+1)])
                else:
                    table.append([0 for _ in range(block_line_number)])
        return table

    def format_table(table):
        for line in table:
            if len(line) % 2 != 0:
                print ' ',
            for item in line:
                print item, ' ',
            print ''

    format_table(make_table())

运行结果:

    0   0   0   0
      0   0   0
      0   0   0
    0   0   0   0
    0   0   0   0
      0   0   0
      0   0   0
    0   0   0   0
    0   0   0   0
      0   0   0
      0   0   0
    0   0   0   0

* 规则: 对于下面两种的case:

  * case 1:

      c   c
    0   b   0
    c   a   c
      b   b
      c   c

  * case 2:

      c   c
      b   b
    c   a   c
    0   b   0
      c   c


落子在 a 处时, 若 b 与 a 不是同一阵营, 且 b 后面的两个 c 与 a 是同一阵营时, 交换 a b 位置.
若存在多个 b 可以交换, 则随机选定一对 a b 交换.

算法上, 回溯是比较符合直觉的算法, 使用广度优先算法, 算两层就能知道结果.


* 规则: 当一个六边形被一方占据了超过4颗棋子, 则这块六边形算作被该方占据. 33对分, 该六边形各算0.5. 边角只有填满才能占据.

* 规则: 除非一方认输, 在所有六边形被占满时比赛结束, 占据六边形多的一方获胜.
