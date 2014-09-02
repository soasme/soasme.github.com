---
layout: post
category: technology
tag:
- clojure
- algorithm
---

# Reorder list

### Problem [1]

> Given a singly linked list L: L0→L1→…→Ln-1→Ln,
> reorder it to: L0→Ln→L1→Ln-1→L2→Ln-2→…

> You must do this in-place without altering the nodes' values.

> For example,
> Given `{1,2,3,4}`, reorder it to `{1,4,2,3}`.

### Idea

1. split from middle (fast-slow-pointer in java usually); ({1 2 3 4} => {1 2} {3 4})
2. reverse the after one ({3 4} => {4 3});
3. weave.

Notice that if list length is odd, clojure map doesn't work well:

{% highlight clojure %}
user=> (mapcat list '(1 2) '(3))
(1 3)
{% endhighlight %}

Here we use

* split-at
* reverse
* concat
* mapcat
* count
* drop

### Solution

{% highlight clojure %}
(defn reorder-list
  [coll]
  (let [cnt (count coll)
        [left right] (split-at (/ cnt 2) coll)
        reversed-right (reverse right)]
    (concat (mapcat list left reversed-right)
            (if (> (count reversed-right) (count left))
              (drop (count left) reversed-right)
              (drop (count reversed-right) left)))))
(reorder-list '(1 2 3 4))
;= (1 4 2 3)
(reorder-list '(1 2 3 4 5))
;= (1 5 2 4 3)
{% endhighlight %}

### Improvements

Seeking for better solution now :(
I think the concat part is urgly.

[1]: https://oj.leetcode.com/problems/reorder-list/
