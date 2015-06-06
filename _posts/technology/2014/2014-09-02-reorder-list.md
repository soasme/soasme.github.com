---
layout: post
category: technology
title: Reorder list
tag:
- clojure
- algorithm
---



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

### Updated

We can write a `map-all` to extend `map` like what `partition-all` to `partiion`:

{% highlight clojure %}
(defn map-all
  [f & colls]
  (letfn [(do-map-all [results f & colls]
            (if-let [args (seq (->> colls (filter seq) (map first)))]
              (let [result (apply f args)
                    results (concat results (list result))]
                (recur results f (map rest colls)))
              results))]
    (apply do-map-all () f colls)))

(println (map-all list '(1 2) '(3 4 5)))
;; => ((1 3) (2 4) (5))

(println (map-all list '(1 2 3 nil) '(4 5)))
;; => ((1 4) (2 5) (3) (nil))
{% endhighlight %}

Thanks @dennis, @xhh a lot!

[1]: https://oj.leetcode.com/problems/reorder-list/
