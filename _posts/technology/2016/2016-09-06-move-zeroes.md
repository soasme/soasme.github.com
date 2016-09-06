---
layout: post
category: technology
tag: algorithm
title: Move Zeroes
---

早晨在地铁上试着求解和证明 [Move Zeroes](https://leetcode.com/problems/move-zeroes/) 的算法。

> Given an array nums, write a function to move all 0's to the end of it while maintaining the relative order of the non-zero elements.
> 
> For example, given nums = [0, 1, 0, 3, 12], after calling your function, nums should be [1, 3, 12, 0, 0].
> 
> Note:
> You must do this in-place without making a copy of the array.
> Minimize the total number of operations.

解：

令 A: 移动前的数组；
A': 移动后的数组（加'表示原地替换）；
k 表示 0 的个数，
i 表示 A 中的元素索引，
j 表示 A' 中的非0元素索引。
n 表示 A 的元素个数

根据题目要求，我们易得，k = i - j，即 A的第i个元素，它必然等于A'的第j个元素，i - j 的差值就是出现 0 的个数:

    P0: k = i - j

我们还有以下两个约束条件：

    P1: 任意 0 < k,  A'(n - k) = 0
    P2: 对于任意的 0 <= j <= i < n,  A'(j) = A(i) != 0

特别地，初始时，即 i = j = k = 0 时，A'(j) 必然要么满足 P0，要么满足 P2，也是满足约束条件的。

我们使用 0<=i < n 作为循环，P0, P2 应满足的条件作为两个分支应满足的条件，写出算法的骨架：

    int i, j, k
    i := j := k := 0

    do i < n ->
        if A(i) = 0 -> // x1: 这里应满足 P0
        | A(i) != 0 -> // x2: 这里应满足 P2
        fi
        i := i + 1; //x3: 使循环往终止方向推进
    od

我们来推导一下 x1, x2.

由于 x3 的存在，如果什么都不做，会使 x1, x2 不满足 P0, P2。
相应的，我们需要使 x1, x2 重新满足 P0, P2。

x1: 只需要加一句 k := k+1 ，就能得到 (k + 1) = (i + 1) - j ，重新满足 P0
x2: 我们必须让 A(j + 1) := A(i + 1) 才能使 P2 重新得到满足，另外，还需要加一句 j := j + 1, 才能得到 k := (i + 1) - (j + 1), 重新满足 P0

当程序运行到这里的时候, P1 全部值域仍然尚未未能得到满足，因此有必要再来一个循环不变式，遍历一次 P1 的值域。

    do k > 0 ->  
        // x4: 满足 P1
        k := k - 1;
    od

易得，x4 是 A(n - k) := 0;

综上，整个算法为

    int i, j, k
    i := j := k := 0

    do i < n ->
        if A(i) = 0 ->
            k := k+1;
        | A(i) != 0 ->
            A(j + 1) := A(i + 1); j = j + 1;
        fi
        i := i + 1; 
    od

    do k > 0 ->  
        A(n - k) := 0; 
        k := k - 1;
    od

至此，该算法完成，正确性也得到了证明。
