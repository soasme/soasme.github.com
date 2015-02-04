---
layout: post
category: note
title: SICP 3.1 Assignment and Local State
---

# SICP 3.1 Assignment and Local State

[Read Book](http://sarabander.github.io/sicp/html/3_002e1.xhtml)

#### Exercise 3.1

An accumulator is a procedure that is called repeatedly with a single numeric argument and accumulates its arguments into a sum. Each time it is called, it returns the currently accumulated sum. Write a procedure make-accumulator that generates accumulators, each maintaining an independent sum. The input to make-accumulator should specify the initial value of the sum; for example

{% highlight scheme %}
(define A (make-accumulator 5))

(A 10)
15

(A 10)
25
{% endhighlight %}

Answer:

{% highlight scheme %}
(define (make-accumulator sum)
  (define (add adder)
    (begin (set! sum (+ sum adder))
           sum))
  add)
{% endhighlight %}

Execute:

{% highlight scheme %}
1 ]=> (define A (make-accumulator 5))

;Value: a

1 ]=> (A 10)

;Value: 15

1 ]=> (A 10)

;Value: 25
{% endhighlight %}

#### Exercise 3.2

In software-testing applications, it is useful to be able to count the number of times a given procedure is called during the course of a computation. Write a procedure make-monitored that takes as input a procedure, f, that itself takes one input. The result returned by make-monitored is a third procedure, say mf, that keeps track of the number of times it has been called by maintaining an internal counter. If the input to mf is the special symbol how-many-calls?, then mf returns the value of the counter. If the input is the special symbol reset-count, then mf resets the counter to zero. For any other input, mf returns the result of calling f on that input and increments the counter. For instance, we could make a monitored version of the sqrt procedure:

{% highlight scheme %}
(define s (make-monitored sqrt))

(s 100)
10

(s 'how-many-calls?)
1
{% endhighlight %}

Answer:

{% highlight scheme %}
(define (make-monitored f)
  (let ((count 0))
    (define (how-many-calls?)
      count)
    (define (monitor param)
      (begin (set! count (+ count 1))
             (f param)))
    (define (reset-count)
      (begin (set! count 0)
             0))
    (define (dispatch symbol)
      (cond ((eq? symbol 'how-many-calls?) (how-many-calls?))
            ((eq? symbol 'reset-count) (reset-count))
            (else (monitor symbol))))
    dispatch))

{% endhighlight %}

Execute:

{% highlight scheme %}
1 ]=> (define s (make-monitored sqrt))

;Value: s

1 ]=> (s 100)

;Value: 10

1 ]=> (s 400)

;Value: 20

1 ]=> (s 'how-many-calls?)

;Value: 2

1 ]=> (s 'reset-count)

;Value: 0

1 ]=> (s 'how-many-calls?)

;Value: 0
{% endhighlight %}

#### Exercise 3.3

Modify the make-account procedure so that it creates password-protected accounts. That is, make-account should take a symbol as an additional argument, as in

{% highlight scheme %}
(define acc
  (make-account 100 'secret-password))
{% endhighlight %}

The resulting account object should process a request only if it is accompanied by the password with which the account was created, and should otherwise return a complaint:

{% highlight scheme %}
((acc 'secret-password 'withdraw) 40)
60

((acc 'some-other-password 'deposit) 50)
"Incorrect password"
{% endhighlight %}

Answer:

{% highlight scheme %}
(define (make-account balance password)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds."))
  (define (deposit amount)
    (begin (set! balance (+ balance amount))
           balance))
  (define (dispatch input-password method)
    (if (eq? password input-password)
        (cond ((eq? method 'withdraw) withdraw)
              ((eq? method 'deposit) deposit)
              (else (error "Unknown request -- MAKE-ACCOUNT" method)))
        (error "Incorrent password" method)))
  dispatch)
{% endhighlight %}

Execute:

{% highlight scheme %}
1 ]=> (define acc (make-account 100 'secret-password))

;Value: acc

1 ]=> ((acc 'secret-password 'withdraw) 50)

;Value: 50

1 ]=> ((acc 'wrong-password 'withdraw) 50)

;Incorrent password withdraw
;To continue, call RESTART with an option number:
; (RESTART 1) => Return to read-eval-print level 1.
{% endhighlight %}

#### Exercise 3.4

Modify the make-account procedure of Exercise 3.3 by adding another local state variable so that, if an account is accessed more than seven consecutive times with an incorrect password, it invokes the procedure call-the-cops.

Answer:

{% highlight scheme %}
(define (make-account balance password)
  (let ((wrong-times 0))
    (define (withdraw amount)
      (if (>= balance amount)
          (begin (set! balance (- balance amount))
                 balance)
          "Insufficient funds."))
    (define (deposit amount)
      (begin (set! balance (+ balance amount))
             balance))
    (define (call-the-cops)
      (display "Cops are on the way."))
    (define (verify-password user-password input)
      (if (eq? user-password input)
          (begin (set! wrong-times 0)
                 #t)
          (begin (set! wrong-times (+ wrong-times 1))
                 (if (>= wrong-times 7)
                     (call-the-cops))
                 #f)))
    (define (dispatch input-password method)
      (if (verify-password password input-password)
          (cond ((eq? method 'withdraw) withdraw)
                ((eq? method 'deposit) deposit)
                (else (error "Unknown request -- MAKE-ACCOUNT" method)))
          (lambda (x) (display "Incorrent password"))))
    dispatch))
{% endhighlight %}

Execute:

{% highlight scheme %}
1 ]=> (define acc (make-account 100 'secret-password))

;Value: acc

1 ]=> ((acc 'incorrect-password 'withdraw) 100)
Incorrent password
;Unspecified return value

1 ]=> ((acc 'incorrect-password 'withdraw) 100)
Incorrent password
;Unspecified return value

1 ]=> ((acc 'incorrect-password 'withdraw) 100)
Incorrent password
;Unspecified return value

1 ]=> ((acc 'incorrect-password 'withdraw) 100)
Incorrent password
;Unspecified return value

1 ]=> ((acc 'incorrect-password 'withdraw) 100)
Incorrent password
;Unspecified return value

1 ]=> ((acc 'incorrect-password 'withdraw) 100)
Incorrent password
;Unspecified return value

1 ]=> ((acc 'incorrect-password 'withdraw) 100)
Cops are on the way.Incorrent password
;Unspecified return value
{% endhighlight %}

#### Exercise 3.5

Monte Carlo integration is a method of estimating definite integrals by means of Monte Carlo simulation. Consider computing the area of a region of space described by a predicate P(x,y) that is true for points (x,y) in the region and false for points not in the region. For example, the region contained within a circle of radius 3 centered at (5, 7) is described by the predicate that tests whether (x−5)^2+(y−7)^2≤3^2. To estimate the area of the region described by such a predicate, begin by choosing a rectangle that contains the region. For example, a rectangle with diagonally opposite corners at (2, 4) and (8, 10) contains the circle above. The desired integral is the area of that portion of the rectangle that lies in the region. We can estimate the integral by picking, at random, points (x,y) that lie in the rectangle, and testing P(x,y) for each point to determine whether the point lies in the region. If we try this with many points, then the fraction of points that fall in the region should give an estimate of the proportion of the rectangle that lies in the region. Hence, multiplying this fraction by the area of the entire rectangle should produce an estimate of the integral.

Implement Monte Carlo integration as a procedure estimate-integral that takes as arguments a predicate P, upper and lower bounds x1, x2, y1, and y2 for the rectangle, and the number of trials to perform in order to produce the estimate. Your procedure should use the same monte-carlo procedure that was used above to estimate π. Use your estimate-integral to produce an estimate of π by measuring the area of a unit circle.


Answer:

{% highlight scheme %}
(define (monte-carlo trials experiment)
  (define (iter trials-remaining trials-passed)
    (cond ((= trials-remaining 0) (/ trials-passed trials))
          ((experiment) (iter (- trials-remaining 1) (+ trials-passed 1)))
          (else (iter (- trials-remaining 1) trials-passed))))
  (iter trials 0))
(define (random-in-range low high)
  (let ((range (- high low)))
    (+ low (random range))))
(define (estimate-integral P x1 x2 y1 y2 trials)
  (define (experiment)
    (P (random-in-range x1 x2) (random-in-range y1 y2)))
  (monte-carlo trials experiment))
(define (P x y)
  (< (+ (square (- x 5.0))
         (square (- y 7.0)))
      (square 3.0)))

; circle-area is equal to (* monte-carlo-result rectangle-area)
; => (* (pi) (square 3.0)) is equal to (* monte-carlo-result (* (- 8 2) (- 10  4)))
; =>
(define (pi)
  (/ (* (estimate-integral P 2.0 8.0 4.0 10.0 10000) 36)
      (square 3.0)))
{% endhighlight %}

Execute:

{% highlight scheme %}
1 ]=> (pi)

;Value: 3.174

1 ]=> (pi)

;Value: 3.1136

1 ]=> (pi)

;Value: 3.1748
{% endhighlight %}
