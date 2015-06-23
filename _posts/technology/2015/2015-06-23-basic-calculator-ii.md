---
layout: post
category: technology
title: Basic Calculator II
---

This is a puzzle from [LeetCode](https://leetcode.com/problems/basic-calculator-ii/).

Solution:

> Implement a basic calculator to evaluate a simple expression string.
>
> The expression string contains only non-negative integers, +, -, *, / operators and empty spaces . The integer division should truncate toward zero.
>
> You may assume that the given expression is always valid.
>
> > Some examples:
> > "3+2*2" = 7
> > " 3/2 " = 1
> > " 3+5 / 2 " = 5
>
> Note: Do not use the eval built-in library function.
>
> Credits:
> Special thanks to @ts for adding this problem and creating all test cases.

Basic Thought:

1. Parse
    * to nifix expression
    * to prefix expression
    * to postfix expression
2. Evaluate

I make a quick but dirty solution at first:

* Parse to nigix expression
* Evaluate */ first and Evaluate +- then.

{% highlight python %}
class Solution:

    # @param {string} s
    # @return {integer}
    def calculate(self, s):
        # parse
        s = s.strip()
        tokens = []
        last = None
        token = int(s[0])
        for index, char in enumerate(s[1:]):
            if char == ' ':
                continue
            if char.isdigit():
                token = token * 10 + int(char)
            else:
                tokens.append(token)
                tokens.append(char)
                token = 0
        tokens.append(token)

        for index in range(len(tokens)):
            if tokens[index] == '*':
                tokens[index + 1] = tokens[index - 1] * tokens[index + 1]
                tokens[index] = 0
                tokens[index - 1] = 0
            elif tokens[index] == '/':
                tokens[index + 1] = tokens[index - 1] / tokens[index + 1]
                tokens[index] = 0
                tokens[index - 1] = 0

        total = 0
        sign = 1
        for token in tokens:
            if token == '+':
                sign = 1
                continue
            elif token == '-':
                sign = -1
                continue
            total += (token * sign)
        return total
{% endhighlight %}

I don't like the evaluation part. It's urgly.
A solution based on priority-map is better (assuming tokens have been parsed already):

{% highlight scheme %}
#lang racket
(define (calc tokens)
  (define (level op)
    (cond ((eq? op '+) 1)
          ((eq? op '-) 1)
          ((eq? op '*) 2)
          ((eq? op '/) 2)))
  (define (prior? op1 op2)
    (>= (level op1) (level op2)))
  (define (f op left right)
    (cond ((eq? op '+) (+ left right))
          ((eq? op '-) (- left right))
          ((eq? op '*) (* left right))
          ((eq? op '/) (/ left right))
          (else (error "invalid operator"))))
  (cond ((null? (cdr tokens)) (car tokens))
        ((null? (cdddr tokens)) (f (cadr tokens) (car tokens) (caddr tokens)))
        (else (let* ([left (car tokens)]
                     [op (cadr tokens)]
                     [right (caddr tokens)]
                     [nextexp (cdddr tokens)]
                     [nextop (car nextexp)])
                (if (prior? op nextop)
                    (calc (cons (f op left right) nextexp))
                    (f op left (calc (cddr tokens))))))))
{% endhighlight %}

To be honestly, the nifix expression make evaluation much harder.
Parsing string to a prefix notation makes eval  much like lisp procedure evaluating,
while parsing string to a postfix expression, aka RPN (Reverse Polish notation), just make problem easier.
