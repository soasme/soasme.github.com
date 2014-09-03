---
layout: post
category: technology
tag:
- clojure
- algorithm
---

# Tail Call Optimization

尾递归最优是指当递归的中心条件满足时，编译器不以消耗内存栈的方式来优化递归调用.

前几天写的程序用到了递归:

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
{% endhighlight %}

想起来, Clojure 是不支持自动尾递归优化的.
在 Clojure 中, 要想做到尾递归优化, 是需要自己做些手脚的.

而且, 这个手脚做起来意外的简单:

{% highlight diff %}
diff --git a/core.clj b/core.clj
index b445084..320649d 100644
--- a/core.clj
+++ b/core.clj
@@ -45,12 +45,12 @@
         (let [e (read-string (first tks))]
           (if (number? e)
             ; number: push into stack
-            (helper
+            (recur
              (next tks)
              (conj stack (int e)))

             ; operator: apply to top 2 elems and then push into stack
-            (helper (next tks)
+            (recur (next tks)
                     (conj (pop (pop stack))
                           ((eval e) (peek stack)
                            (peek (pop stack)))))))))
{% endhighlight %}

需要注意的是, recur 只能用在 loop 或者 function 上.
Clojure 做的事情是编译的时候在 loop / function 开始的地方设置 label, 在 recur 的地方使用 `goto label`.
也就是说, recur 实际上将尾递归变成了循环.
