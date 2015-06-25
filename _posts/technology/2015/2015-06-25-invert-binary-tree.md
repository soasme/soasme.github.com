---
layout: post
category: technology
title: Invert Binary Tree
---

Invert a binary tree.

         4
       /   \
      2     7
     / \   / \
    1   3 6   9

to

         4
       /   \
      7     2
     / \   / \
    9   6 3   1

This problem was inspired by this original tweet by Max Howell:

> Google: 90% of our engineers use the software you wrote (Homebrew), but you can’t invert a binary tree on a whiteboard so fuck off.

本来想在地铁上找到题目练练脑子的, 挑错题目了...确实有点太简单了 = =

{% highlight python %}
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
    # @param {TreeNode} root
    # @return {TreeNode}
    def invertTree(self, root):
        if not root:
            return
        tmp = root.left
        root.left = self.invertTree(root.right)
        root.right = self.invertTree(tmp)
        return root
 {% endhighlight %}

一次AC.
