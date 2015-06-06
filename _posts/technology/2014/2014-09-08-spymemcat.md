---
layout: post
category: technology
title: Spymemcat
tag: clojure
---



A Clojure memcached client library wraps spymemcached.
Source: [soasme/spymemcat](https://github.com/soasme/spymemcat)

## Lein Usage

To use spymemcat, put dependency to `project.clj`:

    [spymemcat "0.1.0"]


## Basic Usage

### Namespace

{% highlight clojure %}
(use 'spymemcat.core)
{% endhighlight %}

### Client

A memcached client using text protocol is default.

{% highlight clojure %}
(def memcached-client (client-factory "localhost:11211"))
{% endhighlight %}

All valid commands should under `with-client` scope:

{% highlight clojure %}
(with-client memcached-client)
  (set "test" 1 3600)
  (get "test"))
{% endhighlight %}

### Store commands

{% highlight clojure %}
(with-client memcached-client
  (set "set-key1" "value" 3600)
  (add "add-key1" "value" 3600)
  (replace "replace-key" "value" 3600)
  (touch "touch-key" 3600))
{% endhighlight %}

### Get commands

{% highlight clojure %}
(with-client memcached-client
  (get "key1") ;= 1
  (gets "key2") ;= {:cas 1 :value 1}
  (get-multi ["key1" "key2"]) ;= {"key1" 1 "key2" 1}
  )
{% endhighlight %}

### Delete command

{% highlight clojure %}
(with-client memcached-client
  (delete "key"))
{% endhighlight %}

## License

Copyright © 2014 Lin Ju (@soasme).

Distributed under the Eclipse Public License either version 1.0 or (at
your option) any later version.
