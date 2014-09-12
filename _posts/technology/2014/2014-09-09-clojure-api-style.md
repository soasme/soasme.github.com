---
layout: post
category: technology
tag: clojure
---

# Clojure API Style

对于大部分 Clojure 流行的库, 大致有如下3种方法可以让开发者导入自己的配置:

## 显式: 函数参数

以 Github 的 Clojure Client [Raynes/tentacles](https://github.com/Raynes/tentacles) 为例.

作为一个需要传入 Token 的函数, Tentacles 选择了让开发者将 Token 作为 `user-events` 最后一个参数:

{% highlight clojure %}
; via :auth
(user-events "Raynes" {:auth "Raynes:REDACTED"})

; via :oauth_token
(user-events "Raynes" {:oauth_token "e72e16c7e42f292c6912e7710c838347ae178b4a"})
{% endhighlight %}

其实现:

{% highlight clojure %}

; ...

(defn query-map
  [entries]
  (into {}
        (for [[k v] entries]
          [(.replace (name k) "-" "_") v])))

; ...

(defn api-call [method end-point positional query]
  (let [query (query-map query)]
    (make-request method end-point positional query)))

; ...

(defn user-events
  [user & [options]]
  (api-call :get "users/%s/received_events" [user] options))

{% endhighlight %}


## 隐式: 动态作用域

以 Memcached Client [soasme/spymemcat](https://github.com/soasme/spymemcat) 为例

开发者在使用的时候, 可以通过 Clojure 的特性: 动态作用域 binding 进行调用:

{% highlight clojure %}

(with-client (client-factory "localhost:11211 localhost:11212"))
  (set "test" 1 3600)
  (get "test"))

{% endhighlight %}

实现:

{% highlight clojure %}
(defmacro with-client
  "Evalute body in the context of a thread-bound client to a memcached server."
  [client & body]
  `(binding [*memcached-client* ~client]
     ~@body))

(defn- client
  "Return current thread-bound memcached client."
  []
  (deref (or *memcached-client*
             (throw no-client-error))))

(defn get
  [key]
  (.get (client) key))
{% endhighlight %}


----------------

显式传参写法简单易读, 但调用稍微麻烦;
隐式作用域调用参数少, 但暴露了内部的数据实现;
到底是显式传参还是动态绑定更好, 没有定论.
大概由于第二种方法比较省参数, 社区似乎比较偏爱这一种.

## 混合式

混合式同时提供了上面两种风格的API. 来看下 [Clojure-clutch/clutch](https://github.com/clojure-clutch/clutch) 的使用:

{% highlight clojure %}

; Style 1

=> (def db (assoc (cemerick.url/url "https://XXX.cloudant.com/" "databasename")
                    :username "username"
                    :password "password"))
#'test-clutch/db
=> (put-document db {:a 5 :b [0 6]})
{:_id "17e55bcc31e33dd30c3313cc2e6e5bb4", :_rev "1-a3517724e42612f9fbd350091a96593c", :a 5, :b [0 6]}

; Style 2

=> (with-db "clutch_example"
     (put-document {:_id "a" :a 5})
     (put-document {:_id "b" :b 6})
     (-> (get-document "a")
       (merge (get-document "b"))
       (dissoc-meta)))
{:b 6, :a 5}
{% endhighlight %}

从实现上看, 大致是这么做的:

{% highlight clojure %}
(defn- with-db*
  [f]
  (fn [& [maybe-db & rest :as args]]
    (let [maybe-db (if (instance? couchdb-class maybe-db)
                     (.url maybe-db)
                     maybe-db)]
      (if (and (thread-bound? #'*database*)
               (not (identical? maybe-db *database*)))
      (apply f *database* args)
      (apply f (utils/url maybe-db) rest)))))

(defmacro ^{:private true} defdbop
  "Same as defn, but wraps the defined function in another that transparently
   allows for dynamic or explicit application of database configuration as well
   as implicit coercion of the first `db` argument to a URL instance."
  [name & body]
  `(do
     (defn ~name ~@body)
     (alter-var-root (var ~name) with-db*)
     (alter-meta! (var ~name) update-in [:doc] str
       "\n\n  When used within the dynamic scope of `with-db`, the initial `db`"
       "\n  argument is automatically provided.")))

(defdbop get-document
  "Returns the document identified by the given id. Optional CouchDB document API query parameters
   (rev, attachments, may be provided as keyword arguments."
  [db id & {:as get-params}]
  ;; TODO a nil or empty key should probably just throw an exception
  (when (seq (str id))
    (couchdb-request :get
      (-> (utils/url db id)
        (assoc :query get-params)))))

(defmacro with-db
  "Takes a URL, database name (useful for localhost only), or an instance of
   com.ashafa.clutch.utils.URL.  That value is used to configure the subject
   of all of the operations within the dynamic scope of body of code."
  [database & body]
  `(binding [*database* (utils/url ~database)]
     ~@body))
{% endhighlight %}

## 实现混合式之1

首先, 需要给出显式传参风格的接口, 配置作为第一个参数传入.
即 `[db id ...]`.

{% highlight clojure %}
(definterface interface
  [config param])
{% endhighlight %}

其次, 提供动态作用域的绑定接口(隐藏实现细节, 开发者只需传入配置即可, 无需了解这个假定的`*database*`)

{% highlight clojure %}
(defmacro with-config
  [config & body]
  `(binding [*config* config]
     ~@body))
{% endhighlight %}

再次, 定制中间层:

{% highlight clojure %}
(defn- with-config*
  [f]
  (fn [config & rest :as args]
    (if (this-is-what-we-want config)
      (apply f config rest)
      (apply f *config* args))))
{% endhighlight %}

最后, 套上中间层:

{% highlight clojure %}
(defmacro definterface
 [...]
 ...
 (alter-var-root (var ~name) with-config*)
 ...
)

{% endhighlight %}



## 实现混合式之2

先给出显式传参的接口, 不过这次给它标记上 `:dynamic` 元数据:

{% highlight clojure %}
(ns example)
(defn ^:dynamic ^:api interface
  [config param])
{% endhighlight %}

再使用 partial 传参:

{% highlight clojure %}
(def public-api (->> (ns-publics *ns*)
                     vals
                     (filter (comp :api meta))
                     doall))
(defmacro with-config
  [config & body]
  `(with-bindings (into {} (for [var @#'example/public-api]
                             [var (partial @var ~config)]))
     ~@body))
{% endhighlight %}

也就好了.

-------

以上两套拳打下来, 都能做到刚中有柔, 柔中有刚, 刚柔并济, 早晨的辣肉松面包挺好吃的:

{% highlight clojure %}

; Style 1

(interface "database://localhost:port" "select by name")

; Style 2
(with-config "database://localhost:port"
  (interface "select by name"))

{% endhighlight %}

Inspired by [À la carte configuration in Clojure APIs](http://cemerick.com/2011/10/17/a-la-carte-configuration-in-clojure-apis/).
