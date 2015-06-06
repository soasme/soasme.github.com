---
layout: post
category: technology
title: Slingshot
tag: clojure
---



Slingshot enhance try and throw for Clojure leveraging Clojure's capabilities.
It provide `try+` and `throw+` that is 100% compatible with Clojure and Java's native try and throw both in source code and at runtime.
Furthermore, we can now throw+ map, records, or anything we want (You are kidding right? It must at least be an Java object.)

Real world example:

{% highlight clojure %}
(interact
   [this command expected_ok expected_err]
   (write this command)
   (let [bin (read this)
         data (string/split bin #" ")
         resp (first data)]
     (cond
      (member? expected_ok resp)
      data

      (member? expected_err resp)
      (throw+ {:type :command-failure :message bin})

      true
      (throw+ {:type :unexpected-response :message bin}))))

  )
{% endhighlight %}

And now I normally use these snippet to help testing my functions.

{% highlight clojure %}
(defn slingshot-exception-class
  "Return the best guess at a slingshot exception class."
  []
  (try
    (Class/forName "slingshot.Stone")
    (catch Exception _
      (let [ei (Class/forName "slingshot.ExceptionInfo")]
        (if (and (resolve 'clojure.core/ex-info)
                 (resolve 'clojure.core/ex-data))
          (Class/forName "clojure.lang.ExceptionInfo")
          ei)))))

(defmacro is-thrown+?
  "clojure.test clause for testing that a slingshot exception is thrown."
  [& body]
  `(is (~'thrown? ~(slingshot-exception-class) ~@body)))

(defmacro is-thrown-with-msg+?
  "clojure.test clause for testing that a slingshot exception is thrown."
  [& body]
  `(is (~'thrown-with-msg? ~(slingshot-exception-class) ~@body)))

(deftest put-body
  (let [bt (beanstalkd-factory)]
    (watch bt "default")
    (testing "Put non-str body"
      (is-thrown+? {:type :type-error :message "Job body must be a String"} (put bt 1234)))))
{% endhighlight %}
