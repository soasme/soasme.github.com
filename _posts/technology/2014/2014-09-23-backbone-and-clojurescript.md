---
layout: post
category: technology
tag: clojure
---

# Backbone && Clojurescript

### What is clojurescript?

ClojureScript is a new compiler for Clojure that targets JavaScript.
It is designed to emit JavaScript code which is compatible with the
advanced compilation mode of the Google Closure optimizing compiler.

### Why clojurescipt?

* JavaScript Everywhere. It's the assembly language of web.
* But JavaScript is not robust.
* Clojure is robust.
* Clojurescript: write clojure code, compile it to javascript code!

ref: [Clojurescript Rationale](https://github.com/clojure/clojurescript/wiki/Rationale)

### Backbone.js!

Backbone.js gives structure to web applications by providing models
with key-value binding and custom events, collections with a rich
API of enumerable functions, views with declarative event handling,
and connects it all to your existing API over a RESTful JSON interface.

## Write backbone.js with clojurescript!

### Manage Dependencies

Q: What do we need?

A:

* :dependencies
  + [org.clojure/clojurescript "0.0-2342"]
* :plugins
  + [lein-bower "0.5.1"]
  + [lein-cljsbuild "1.0.3"]
* :bower-dependencies
  + [bootstrap "3.2.0"]
  + [jquery "2.1.1"]
  + [backbone "1.1.2"]
* :bower
  + :directory "resources/public/js/lib"
* cljsbuild

Aggregate all the above (`project.clj`):

{% highlight clojure %}
(defproject beanstalk-console "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [compojure "1.1.8"]
                 [ring/ring-json "0.3.1"]
                 [beanstalk-clj "0.1.2"]
                 [org.clojure/clojurescript "0.0-2342"]]
  :plugins [[lein-ring "0.8.11"]
            [lein-bower "0.5.1"]
            [lein-cljsbuild "1.0.3"]]
  :ring {:handler beanstalk-console.handler/app}
  :bower-dependencies [[bootstrap "3.2.0"]
                       [jquery "2.1.1"]
                       [backbone "1.1.2"]]
  :bower {:directory "resources/public/js/lib"}
  :cljsbuild {
    :builds [{:source-paths ["src-cljs"]
              :compiler {:output-to "resources/public/dist/js/main.js",
                         :optimizations :whitespace
                         :pretty-print true}}]
  }
  :profiles
  {:dev {:dependencies [[javax.servlet/servlet-api "2.5"]
                        [ring-mock "0.1.5"]]}})
{% endhighlight %}

After running `lein deps` and `lein bower install`, we have installed all:

    $ lein bower ls
    beanstalk-console#0.1.0-SNAPSHOT /Users/soasme/space/soft/beanstalk-console
    ├─┬ backbone#1.1.2
    │ └── underscore#1.7.0
    ├─┬ bootstrap#3.2.0
    │ └── jquery#2.1.1
    └── jquery#2.1.1

For now, we have install clojure dependencies, clojurescript, bower dependencies, and
a task for building all the cljs into js. Let's step far!

### Write view (using hiccup)

Notice that, before include `main.js`, it's important to load backbone first.
To include backbone, include underscore first.
To include bootstrap, include jQuery first. :)

{% highlight clojure %}
(ns beanstalk-console.tmpl.home
  (:use [hiccup.page :as page]))

(defn index []
  (page/html5
   [:head
    [:title "Beanstalk Console"]
    [:meta {:charset "utf-8"}]
    [:meta {:name "description" :content "Beanstalk console"}]
    (page/include-css "/resources/js/lib/bootstrap/dist/css/bootstrap.min.css")
    (page/include-js "/resources/js/lib/jquery/dist/jquery.min.js"
                     "/resources/js/lib/bootstrap/dist/js/bootstrap.min.js"
                     "/resources/js/lib/underscore/underscore-min.js"
                     "/resources/js/lib/backbone/backbone.js"
                     "/resources/dist/js/main.js")]
   [:body
    [:nav.navbar.navbar-inverse.navbar-fixed-top {:role "nagivation"}
     [:div.container-fuild
      [:div.navbar-header
        [:button.navbar-toggle.collapsed
         {:data-toggle "collapse",
          :data-target "#navbar",
          :aria-expanded false,
          :aria-controls "navbar"}
         [:span.sr-only "Toggle navigation"]
         [:span.icon-bar]
         [:span.icon-bar]
         [:span.icon-bar]]
        [:a.navbar-brand {:href "#"} "Beanstalk Console"]]]]
    [:div.container-fluid
     [:div.row]]]))
{% endhighlight %}

### Write Controller

{% highlight clojure %}
(ns beanstalk-console.handler
  (:use [ring.middleware params cookies]
        [ring.util.response])
  (:require [compojure.core :refer :all]
            [compojure.handler :as handler]
            [compojure.route :as route]
            [ring.middleware.json :as json-middleware]
            [beanstalk-console.tmpl.home :as tmpl-home]))

(defroutes app-routes
  ; Index Page
  (GET "/" [] (tmpl-home/index))
  (route/resources "/resources")
  (route/not-found "Not Found"))

(def app
  (handler/site app-routes))
{% endhighlight %}

### Write backbone code!

As configured before, all the cljs code should be put into `src-cljs` folder
(`:source-paths ["src-cljs"]`), and all the cljs code will be compiled into
`resources/public/dist/js/main.js` file.

Now we need to create new file `src-cljs/beanstalk-console/main.cljs`:

{% highlight clojure %}
(ns beanstalk-console.main)
(def o {})
(.extend js/_ o Backbone.Events)
(.on o "debug" (fn [msg] (.debug js/console msg)))
(.trigger o "debug" "Hello World")
{% endhighlight %}

This is coming from backbone document:

> Events is a module that can be mixed in to any object, giving the object the ability to bind and trigger custom named events. Events do not have to be declared before they are bound, and may take passed arguments. For example:

    var object = {};

    _.extend(object, Backbone.Events);

    object.on("alert", function(msg) {
      alert("Triggered " + msg);
    });

    object.trigger("alert", "an event");

Run `lein cljsbuild auto`, it will execute all the cljsbuild task and watch modifying:


    beanstalk-console [master●] % lein cljsbuild auto
    Compiling ClojureScript.
    Compiling "resources/public/dist/js/main.js" from ["src-cljs"]...
    Successfully compiled "resources/public/dist/js/main.js" in 10.433 seconds.
    Compiling "resources/public/dist/js/main.js" from ["src-cljs"]...
    Successfully compiled "resources/public/dist/js/main.js" in 0.625 seconds.
    Compiling "resources/public/dist/js/main.js" from ["src-cljs"]...
    Successfully compiled "resources/public/dist/js/main.js" in 0.508 seconds.
    Compiling "resources/public/dist/js/main.js" from ["src-cljs"]...
    Successfully compiled "resources/public/dist/js/main.js" in 0.32 seconds.
    Compiling "resources/public/dist/js/main.js" from ["src-cljs"]...
    Successfully compiled "resources/public/dist/js/main.js" in 0.343 seconds.
    Compiling "resources/public/dist/js/main.js" from ["src-cljs"]...
    Successfully compiled "resources/public/dist/js/main.js" in 0.29 seconds.

Open new console, run `lein ring server-headless` and happy visiting
`http://localhost:3000`!

![Screenshot](/images/2014/cljs-backbone.png)


### Step further!

All in all, it’s really simple exercise.
In the next post, I will introduce you how to write clojure-idiom browser script!
