---
layout: post
category: technology
tag: algorithm
---

> Question: There are 2 sorted arrays X and Y of size n each. Write an algorithm to find the median of the array obtained after merging the above 2 arrays(i.e. array of length 2n). The complexity should be O(log(n))

### Formal Deduction

![](/images/2015/median-of-two-sorted-arrays.jpg)

### Code

{% highlight python %}
def median_of_2_sorted_arrays(X, Y):
    assert len(X) == len(Y)
    if len(X) == 1:
        return (X[0] + Y[0]) / 2.0
    if len(X) == 2:
        return (max(X[0], Y[0]) + min(X[1], Y[1])) / 2.0
    mid_x = X[len(X) / 2]
    mid_y = Y[len(Y) / 2]
    if mid_x == mid_y:
        return mid_x
    elif mid_x > mid_y:
        return median_of_2_sorted_arrays(
                X[0:len(X) / 2 + 1], Y[len(Y) / 2: len(Y)]
        )
    elif mid_x < mid_y:
        return median_of_2_sorted_arrays(
                X[len(X) / 2: len(X)], Y[0:len(Y) / 2 + 1]
        )
{% endhighlight %}
