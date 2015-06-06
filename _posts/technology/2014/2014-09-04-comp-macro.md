---
layout: post
category: technology
title: Macro `->`
tag: clojure
---




Method chaining, also known as named parameter idiom, is a common syntax for invoking multiple method calls in object-oriented programming languages. Each method returns an object, allowing the calls to be chained together in a single statement.

In Clojure, macro `->` is interesting to implement method chaining.

Let's try to express `10 days ago`!

{% highlight clojure %}
(-> 10 days ago)
{% endhighlight %}

Which is exactly the same as:

{% highlight clojure %}
(ago (days 10))
{% endhighlight %}

How about `lein new app`:

{% highlight clojure %}
(-> lein new app)
{% endhighlight %}

Express html node action:

{% highlight clojure %}
(-> element turn-bigger slide-down and-then hide)
{% endhighlight %}


### Clojure Doc

    ->
    macro
    Usage: (-> x & forms)
    Threads the expr through the forms. Inserts x as the
    second item in the first form, making a list of it if it is not a
    list already. If there are more forms, inserts the first form as the
    second item in second form, etc.
    Added in Clojure version 1.0
