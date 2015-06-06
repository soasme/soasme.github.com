---
layout: post
category: technology
title: Evaluate Reverse Polish Notation
tag:
- clojure
- algorithm
---



### Problem

> Evaluate the value of an arithmetic expression in Reverse Polish Notation.
>
> Valid operators are +, -, *, /. Each operand may be an integer or another expression.
>
> Some examples:
>
>  * ["2", "1", "+", "3", "*"] -> ((2 + 1) * 3) -> 9
>
>  * ["4", "13", "5", "/", "+"] -> (4 + (13 / 5)) -> 6

### Solution

{% highlight clojure %}
(defn evaluate-reverse-polish-notation
  [tokens]
  (defn helper [tks stack]
      (if (empty? tks)
        ; base case
        (if (= (count stack) 1)
          (peek stack)
          (throw (Exception. (str "Broken notation: " (count stack)))))
        ; making progress
        (let [e (read-string (first tks))]
          (if (number? e)
            ; number: push into stack
            (helper
             (next tks)
             (conj stack (int e)))

            ; operator: apply to top 2 elems and then push into stack
            (helper (next tks)
                    (conj (pop (pop stack))
                          ((eval e) (peek stack)
                           (peek (pop stack)))))))))
  (helper tokens '()))

(evaluate-reverse-polish-notation ["2", "1", "+", "3", "*"])
;= 9
{% endhighlight %}

Helper:

    (helper ["2" "1" "+" "3" "*"] '())
    (helper ["1" "+" "3" "*"] '(1))
    (helper ["+" "3" "*"] '(1 2))
    (helper ["3" "*"] '(3))
    (helper ["*"] '(3 3))
    (helper [] '(9))
    => 9

### Clojure Stack

Stacks are collections that classically support last-in, first-out (LIFO) semantics;
that is, the most recent item added to a stack is the first one that can be pulled
off of it. Clojure doesn’t have a distinct stack data structure, but it does support
a stack ab- straction via three operations:

* conj, for pushing a value onto the stack (conveniently reusing the collection-gen- eralized operation)
* pop, for obtaining the stack with its top value removed
* peek, for obtaining the value on the top of the stack

Both lists and vectors can be used as stack, where the top of the stack is the end
of each respective data structure where conj can efficiently operate.

(Above is from `Clojure Programming`).


### Documentation

    user=> (doc peek)
    -------------------------
    clojure.core/peek
    ([coll])
      For a list or queue, same as first, for a vector, same as, but much
      more efficient than, last. If the collection is empty, returns nil.
    nil
    user=> (doc pop)
    -------------------------
    clojure.core/pop
    ([coll])
      For a list or queue, returns a new list/queue without the first
      item, for a vector, returns a new vector without the last item. If
      the collection is empty, throws an exception.  Note - not the same
      as next/butlast.
    nil
    user=> (doc conj)
    -------------------------
    clojure.core/conj
    ([coll x] [coll x & xs])
      conj[oin]. Returns a new collection with the xs
        'added'. (conj nil item) returns (item).  The 'addition' may
        happen at different 'places' depending on the concrete type.
    nil
