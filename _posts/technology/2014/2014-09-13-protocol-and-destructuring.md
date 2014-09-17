---
layout: post
category: technology
tag: clojure
---
# Protocal and destruturing

Unfortunately, we cannot use destruturing or rest arguments
in the specification of those methods within the `def protocol`
from.

I want to write an interface:

{% highlight clojure %}
(defprotocol BeanstalkOperation
 (put [beanstalkd body & {:keys [priority delay ttr]
                          :or {priority default-priority
                               delay 0
                               ttr default-ttr}}]))
{% endhighlight %}

But it is illegal! The compilication will be failed:

    Caused by: java.lang.IllegalArgumentException: Can't define method not in interfaces: put

However, because protocols generate a JVM interface, which
cannot support all the argument structure variations that
Clojure functions provide, methodName is taken to be a
method that accepts 2 arguments, not 3, not 4, not 5!
