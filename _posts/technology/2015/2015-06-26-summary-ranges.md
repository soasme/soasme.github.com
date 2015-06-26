---
layout: post
category: technology
title: Summary Ranges
---

> Given a sorted integer array without duplicates, return the summary of its ranges.
>
> For example, given `[0,1,2,4,5,7]`, return `["0->2","4->5","7"]`.
>
> Credits:
> Special thanks to @jianchao.li.fighter for adding this problem and creating all test cases.

Before solving it, let's assume first we have got a pair list like this:

    '((0 1) (3 4) (5 6) (8 8) (10 10))

If we apply a formatter function to it:

* if start and end are the same, just transform this number to string;
* otherwise transfer a range '(start end) to a string: "start->end".

This list will just turn it `'("0->1" "3->4" "5->6" "8" "10")` as expected.

The procedure below implements the specification above:

{% highlight scheme %}
(define (format-pairs pairs)
  (map (lambda (p) (if (= (car p) (cadr p))
                       (number->string (car p))
                       (string-append (number->string (car p))
                                      "->"
                                      (number->string (cadr p)))))
       pairs))
{% endhighlight %}

Now, the question is getting easier, we meet a task to turn list
`(0 1 3 4 6 8 10)` to ` '((0 1) (3 4) (6 8) (10 10))`.

A for-loop implementation is not so fast enough, 'cause its cost is O(N).
As far as we know, this is a sorted and non-duplicated number list.
A binary-search algorithm costing O(log(N)) suits this case the best.

Here is the divide and conquer data flow:
{% highlight scheme %}
(0 1 3 4 5 6 8 10) ; 0 ~ 10 missed 2, 7, 9, so, we cannot turn it to (0 10) but divide it in half.
(0 1 3 4) (5 6 8 10) ; divide
(0 1) (3 4) (5 6) (8 10) ; and divide
[(0 1)] [(3 4)] [(5 6)] (8) (10) ; (0 1), (3 4), (5 6) is a range now, others continueing to divide
                      [(8 8)] [(10 10)] ; Basecase touched.
[(0 1) (3 4)] [(5 6) (8 8) (10 10)] ; Conquer
[(0 1) (3 6) (8 8) (10 10)] ; Conquer. Since (3 4) (5 6) are actually in the same range, merge them.
; And now, that seems good enough!
{% endhighlight %}

Implement it is really simple:

{% highlight scheme %}
(define (summary-range-pairs nums)
  (if (continous-range? nums) ; base case condition
      (list (list (car nums) (last nums))) ; base case expression
      (apply merge-range-pairs (map summary-range-pairs (split nums))))) ; divide and conquer
{% endhighlight %}

`(merge-range-pairs p1 p2)` helps us dealing with `(3 4) (5 6)`:

* If start of p2 is next to end of p1, concat them into one pair;
* Otherwise, keep them staying 2 pairs.

Here is a possible implementation:

{% highlight scheme %}
(define (merge-range-pairs p1s p2s)
  (let* ((last-p1 (last p1s))
         (first-p2 (car p2s)))
    (if (continous-pair? last-p1 first-p2)
        (append (butlast p1s)
                (cons (merge-pair last-p1
                                  first-p2)
                      (cdr p2s)))
        (append p1s p2s))))
{% endhighlight %}

We still leave some trivial procedures to implement, there are many ways to have them.
Here is a praticable entire solution:

{% highlight scheme %}
#lang racket

(define (split array)
  (let ((half (quotient (length array) 2)))
    (list (take array half)
          (drop array half))))

(define (butlast array)
  (take array (- (length array) 1)))

(define (continous-range? nums)
  (= (- (length nums) 1) (- (last nums) (car nums))))

(define (continous-pair? p1 p2)
  (or (= (cadr p1) (car p2))
      (= (+ (cadr p1) 1) (car p2))))

(define (continous-seq? s1 s2)
  (= (+ (last s1) 1) (car s2)))

(define (merge-pair p1 p2)
  (list (car p1) (cadr p2)))

(define (merge-range-pairs p1s p2s)
  (let* ((last-p1 (last p1s))
         (first-p2 (car p2s)))
    (if (continous-pair? last-p1 first-p2)
        (append (butlast p1s)
                (cons (merge-pair last-p1
                                  first-p2)
                      (cdr p2s)))
        (append p1s p2s))))

(define (summary-range-pairs nums)
  (if (continous-range? nums)
      (list (list (car nums) (last nums)))
      (apply merge-range-pairs (map summary-range-pairs (split nums)))))

(define (format-pairs pairs)
  (map (lambda (p) (if (= (car p) (cadr p))
                       (number->string (car p))
                       (string-append (number->string (car p))
                                      "->"
                                      (number->string (cadr p)))))
       pairs))

(define (summary-ranges nums)
  (if (null? nums)
      '()
      (format-pairs (summary-range-pairs nums))))

(summary-ranges '()) ; '()
(summary-ranges '(0)) ; '("0")
(summary-ranges '(0 1)) ; '("0->1")
(summary-ranges '(0 1 2)) ; '("0->2")
(summary-ranges '(0 2)) ; '("0" "2")
(summary-ranges '(0 1 3 4)) ; '("0->1" "3->4")
(summary-ranges '(0 1 3 4 6 7 8 10)) ; '("0->1" "3->4" "6->8" "10")
{% endhighlight %}
