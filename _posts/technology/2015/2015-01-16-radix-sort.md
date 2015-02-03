---
layout: post
category: technology
tag: algorithm
---

# Busket

## What is radix sort?

a non-comparative integer sorting algorithm.

## Related Puzzle: Single Number Problem

Puzzle: Given an array of integers, every element appears three times except for one. Find that single one.

A solution in relationship with radix sort:

{% highlight java %}
public class Solution {
    public int singleNumber(int[] A) {
        int[] count = new int[32];
        int result = 0;
        for (int i = 0; i < 32; i++) {
            for (int j = 0; j < A.length; j++) {
                if ((A[j] & (1 << i)) != 0) {
                    count[i]++;
                }
            }
            result |= ((count[i] % 3) << i);
        }
        return result;
    }
}
{% endhighlight %}

Group some element into busket, and then do operation on them.

BTW, Another complicated solution :

A possible solution:

{% highlight java %}
public class Solution {
    public int singleNumber(int[] A) {
        int a = 0, b = 0, c = 0;
        for (int i = 0; i < A.length; i++) {
            b |= (a & A[i]);
            a ^= A[i];
            c = a & b;
            a &= ~c;
            b &= ~c;
        }
        return a;
    }
}
{% endhighlight %}

Solution one is much more general, cause' it suites all find-n-same-element problem.
