---
layout: post
category: technology
tag:
- algorithm
- clojure
---

Single Number[1]
=============

Given an array of integers, every element appears twice except for one. Find that single one.
Your algorithm should have a linear runtime complexity. Could you implement it without using extra memory?

A tricky solution:

{% highlight clojure %}


(defn single-number
  [array]
    (reduce (fn [a b] (bit-xor a b)) array))
    (single-number [1 1 2 3 3 4 4])
{% endhighlight %}

### Bit manipulation

* n ^ n = 0
* 0 ^ n = n

=> 1 ^ 1 ^ 2 ^ 3 ^ 3 = 2

[1]: https://oj.leetcode.com/problems/single-number/
