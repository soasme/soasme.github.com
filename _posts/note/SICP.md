---
layout: post
category: note
---

# SICP note

## 第三章

#### 练习 3.1

累加器: 反复调用数值参数, 是各个参数累加到一个和数中.
过程 make-accumulator 生成的累加器维持一个独立的和.

{% highlight scheme %}
(define (make-accumulator sum)
  (define (add adder)
    (begin (set! sum (+ sum adder))
           sum))
  add)
{% endhighlight %}

{% highlight scheme %}
1 ]=> (define A (make-accumulator 5))

;Value: a

1 ]=> (A 10)

;Value: 15

1 ]=> (A 10)

;Value: 25
{% endhighlight %}
