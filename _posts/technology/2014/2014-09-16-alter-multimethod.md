---
layout: post
category: technology
tag: clojure
---

# Alter multimethod

### Multimethod

A multimethod is created using a defmulti form, and
implementations of a multime- thod are provided by
defmethod forms. The mnemonic is that they come in
the same order as in the word multimethod itself:
first you define the multiple dispatch then the methods
to which calls are dispatched.

{% highlight clojure %}
(defmulti delete
  (fn [instance & rest]
    (type instance)))

(defmethod delete Beanstalkd
  [beanstalkd jid]
  (interact beanstalkd
            (beanstalkd-cmd :delete jid)
            ["DELETED"]
            ["NOT_FOUND"]))

(defmethod delete Job
  [job]
  (delete (.consumer job) (.jid job)))
{% endhighlight %}

### Alter (alter-var-root)

Atomically alters the root binding of var v by applying f to its
current value plus any args

{% highlight clojure %}
(defn sqr [n]
  "Squares a number"
  (* n n))

user=> (sqr 5)
25

user=> (alter-var-root
         (var sqr)                     ; var to alter
         (fn [f]                       ; fn to apply to the var's value
           #(do (println "Squaring" %) ; returns a new fn wrapping old fn
                (f %))))

user=> (sqr 5)
Squaring 5
25
{% endhighlight %}

### Multimethod + Alter

It's wrong simply calling `(alter-var-root a-multi-fn newfn)`.

    Caused by: java.lang.ClassCastException: clojure.lang.MultiFn cannot be cast to clojure.lang.Var

The function wraped by defmulti is not actually fn but a `MultiFn`.
There's a table in MultiFn; dispatch key as table key; dispatch
function as table value.

{% highlight clojure %}
=> (methods delete)
{beanstalk_clj.core.Job #<core$eval882$fn__883 beanstalk_clj.core$eval882$fn__883@71345af1>,
beanstalk_clj.core.Beanstalkd #<core$with_beanstalkd_STAR_$fn__699 beanstalk_clj.core$with_beanstalkd_STAR_$fn__699@5a4bb836>}
{% endhighlight %}

As we can use `remove-method` to amend this table:
{% highlight clojure %}
=> (remove-method delete Beanstalkd)
{beanstalk_clj.core.Job #<core$eval882$fn__883 beanstalk_clj.core$eval882$fn__883@ea6e48f>}
{% endhighlight %}

That says, we need not alter the fn definition but assoc table value.

#### How to alter

Since clojure standard library miss `add-method` for MultiFn,
we have to write it outself just like `remove-method` `methods` that
already exists.

This is clojure language's definition of MultiFn:

{% highlight java %}
public MultiFn addMethod(Object dispatchVal, IFn method) {
	rw.writeLock().lock();
	try{
		methodTable = getMethodTable().assoc(dispatchVal, method);
		resetCache();
		return this;
	}
	finally {
		rw.writeLock().unlock();
	}
}
{% endhighlight %}

We just need to wrap it like this:

{% highlight clojure %}
(defn add-method
  [^clojure.lang.MultiFn multifn dispatch-val method]
  (. multifn addMethod dispatch-val method))
{% endhighlight %}

Now it's so easy for us to alter a new function in multifn!

{% highlight clojure %}
(defn- with-beanstalkd*
  [f]
   (fn [& [beanstalkd & rest :as args]]
     (if (and (thread-bound? #'*beanstalkd*)
              (not (identical? *beanstalkd* beanstalkd)))
       (apply f *beanstalkd* args)
       (apply f beanstalkd rest))))

(defn inject-beanstalkd
  [multifn]
  (let [f ((methods multifn) Beanstalkd)]
    (add-method multifn Beanstalkd (with-beanstalkd* f))))

(defmacro ^:private defmethod-beanstalkd
  [name & body]
  `(do
     (defmethod ~name Beanstalkd ~@body)
     (inject-beanstalkd ~name)))
{% endhighlight %}

### Usage

{% highlight clojure %}
defmulti delete
  (fn [instance & rest]
    (type instance)))

(defmethod-beanstalkd delete
  [beanstalkd jid]
  (interact beanstalkd
            (beanstalkd-cmd :delete jid)
            ["DELETED"]
            ["NOT_FOUND"]))

(defmethod delete Job
  [job]
  (delete (.consumer job) (.jid job)))
{% endhighlight %}
