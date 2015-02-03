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
