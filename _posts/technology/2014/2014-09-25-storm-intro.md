---
layout: post
category: technology
tag: storm
---

# Storm Intro

Storm is a distributed realtime computation system, which provides
a set of general primitives for doing **REALTIME** computation.
Storm makes it easy to reliably process unbounded streams of data
unlike what Hadoop did via batch processing.

Storm can be used in:

* Realtime Analytics
* Online Machine Learning
* Continuous Computation
* Distributed RPC
* ETL
* etc.

Note: Storm cares about consuming streaming of data and processing
these streams in arbitrarily complex ways, not about queueing and
data storing.


## Terms

* spout: the input stream from a file(or a socket, via HTTP, or thrift call, etc.)
* bolt: a component that processing data from spout or other bolt
* topology: the way spout and bolt compose.

![Topology, Bolt, Spout](http://storm.apache.org/images/topology.png)

In a storm cluster, nodes are organized into a master node that
runs continuously. The master node has an alias name of `Nimbus`,
which is responsible for distributing code around the cluster,
assigning tasks to each worker node, and monitoring for faulures.
Worker nodes run a daemon called Supervisor, which executes a portion
of a topology. Worker nodes are run across on different machines.

Storm keep all cluster states in Zookeeper or on local disk.
Underneath, Storm makes use of zeromq.

## Pros

Within all these design concepts and decisions, there are some really
nice properties that makes Storm unique:

* Simple to program

  If you’ve ever tried doing real-time processing from scratch, you’ll understand how painful it can become. With Storm, complexity is dramatically reduced.

* Support for multiple programming languages

  It’s easier to develop in a JVM-based language, but Storm supports any language as long as you use or implement a small intermediary library.

* Fault-tolerant

  The Storm cluster takes care of workers going down, reassigning tasks when necessary.

* Scalable

  All you need to do in order to scale is add more machines to the cluster. Storm will reassign tasks to new machines as they become available.

* Reliable

  All messages are guaranteed to be processed at least once. If there are errors, mes- sages might be processed more than once, but you’ll never lose any message.

* Fast

  Speed was one of the key factors driving Storm’s design.

* Transactional

  You can get exactly once messaging semantics for pretty much any computation.

## Operation Modes

There are two ways to run Storm:

### Local Mode

Run on local machine in a single JVM for development, testing and
debuging.

### Remote Mode

Run on Storm cluster, that is, in production environment.


## Let's start!

Note: focus in local mode, which means that the development and test topologies
are completely in process on local machine. Nimbus is my computer.

Now I am about to create an empty topology (no spout, no bolt) and then submit it
to nimbus (local machine), print the cluster instance.

Install zeromq:

    $ brew install zeromq

Install zookeeper:

    $ brew install zookeeper

Configure dependency:

Add `[storm "0.9.0.1"]` to `:dependency` in `project.clj`.
Run `lein deps`.

Write a script:

{% highlight clojure %}
(ns example.main
  (:import (backtype.storm Config
                           LocalCluster
                           topology.TopologyBuilder
                           tuple.Fields)))

(defn -main
  [& args]
  (let [conf (doto (Config.)
               (.put Config/TOPOLOGY_MAX_SPOUT_PENDING 1)
               (.put "logFile" (first args))
               (.setDebug false))
        builder (doto (TopologyBuilder.)
                  )
        cluster (doto (LocalCluster.)
                  (.submitTopology "This-is-an-empty-Topology"
                                   conf
                                   (.createTopology builder)))]
    (println cluster)
    (.shutdown cluster)))
{% endhighlight %}

In main function, I create the topology and a LocalCluster instance.
In conjunction with Config instance, LocalCluster allows us to try
out different cluster configurations.

I create the topology using a TopologyBuilder. In addition, spouts
and bolts are defined via topology. I'll explain it later.

Actually, the above is in a more java-idiom way. Let's try using
Clojure DSL for storm:

{% highlight clojure %}
(ns example.main
  (:use [backtype.storm clojure config]))

(defn -main
  [& args]
  (let [conf {TOPOLOGY-DEBUG true, TOPOLOGY-MAX-SPOUT-PENDING 1, "logFile" (first args)}
        topos (topology {} {})
        cluster (local-cluster)
        _ (.submitTopology cluster "APIv2-Monitor-Topology" conf topos)]
    (println cluster)
    (.shutdown cluster)))
{% endhighlight %}

Test running script:

    % lein run -m api-monitor.main
    ... (staring INFO log)
    2526 [main] INFO  backtype.storm.daemon.nimbus - Setting new assignment for topology id APIv2-Monitor-Topology-1-1411654899: #backtype.storm.daemon.common.Assignment{:master-code-dir "/var/folders/2g/xtwm8ql505v4cn4wtxlr2tch0000gn/T//1df83451-5360-493b-8f4d-8c81c73b814c/nimbus/stormdist/APIv2-Monitor-Topology-1-1411654899", :node->host {"c1cf6ccf-4782-4a7e-8cd5-80437e16f633" "localhost"}, :executor->node+port {[1 1] ["c1cf6ccf-4782-4a7e-8cd5-80437e16f633" 4]}, :executor->start-time-secs {[1 1] 1411654900}}
    #<LocalCluster backtype.storm.LocalCluster@338ff9a1>
    ... (shuting down INFO log)

## Real World Clojure Project

As mentioned before, storm comes with a Clojure DSL for defining
spouts, bolts, and topologies.

The rest of post, I will introduce you some pieces of clojure DSL:

* define spout
* define bolt
* define topology
* run topology in local mode

### Spout

`defspout` is used for defining spouts in Clojure.
The signature for defspout looks like the following:

{% highlight clojure %}
(defspout name output-declaration *option-map & impl)
{% endhighlight %}

Here’s an example defspout implementation from storm-starter:

{% highlight clojure %}
(defspout sentence-spout ["sentence"]
  [conf context collector]
  (let [sentences
        ["a little brown dog" "the man petted the dog"
         "four score and seven years ago"
         "an apple a day keeps the doctor away"]]
    (spout
     (nextTuple
      []
      (Thread/sleep 100)
      ;(log-message "DEBUG>>>>>>>>>>" (rand-nth sentences))
      (emit-spout! collector
                   [(rand-nth sentences)]))
     (ack
      [id]
      ;; You only need to define this method for reliable spouts
      ;; (such as one that reads off of a queue like Kestrel)
      ;; This is an unreliable spout, so it does nothing here
      ))))
{% endhighlight %}

### Bolt

`defbolt` is used for defining bolts in Clojure.
The signature for defbolt looks like the following:

{% highlight clojure %}
(defbolt name output-declaration *option-map & impl)
{% endhighlight %}

#### Sample bolts

{% highlight clojure %}
(defbolt split-sentence ["word"]
  [tuple collector]
  (let [words (.split (.getString tuple 0) " ")]
    (doseq [w words]
      (emit-bolt! collector [w] :anchor tuple))
    (ack! collector tuple)))
{% endhighlight %}

#### Prepared bolts

To do more complex bolts, such as ones that do joins and streaming aggregations, the bolt needs to store state. You can do this by creating a prepared bolt which is specified by including {:prepare true} in the option map. Consider, for example, this bolt that implements word counting:

{% highlight clojure %}
(defbolt word-count ["word" "count"]
  {:prepare true}
  [conf context collector]
  (let [counts (atom {})]
    (bolt (execute
           [tuple]
           (let [word (.getString tuple 0)]
             (swap! counts
                    (partial merge-with +) {word 1})
             (emit-bolt! collector
                         [word (@counts word)]
                         :anchor tuple)
             (ack! collector tuple))))))
{% endhighlight %}

### Topology

To define a topology, use the topology function
 topology takes in two arguments: a map of “spout specs” and a map of “bolt specs”. Each spout and bolt spec wires the code for the component into the topology by specifying things like inputs and parallelism.

{% highlight clojure %}
(defn -main
  [& args]
  (let [conf {TOPOLOGY-DEBUG true, TOPOLOGY-MAX-SPOUT-PENDING 1, "logFile" (first args)}
        topos (topology
               {"1" (spout-spec sentence-spout)}
               {"3" (bolt-spec
                     {"1" :shuffle}
                     split-sentence
                     :p 5)
                "4" (bolt-spec
                     {"3" ["word"]}
                     word-count
                     :p 6)})
        cluster (local-cluster)
        _ (.submitTopology cluster "APIv2-Monitor-Topology" conf topos)]
    (Thread/sleep 10000)
    (.shutdown cluster)))
{% endhighlight %}

### Run Topology

!

    $ lein run -m api-monitor.main "hi"
    ... (boot log)
    5031 [Thread-32-4] INFO  backtype.storm.daemon.executor - Processing received message source: 3:2, stream: default, id: {}, ["years"]
    5031 [Thread-26-4] INFO  backtype.storm.daemon.task - Emitting: 4 default ["seven" 3]
    5032 [Thread-32-4] INFO  backtype.storm.daemon.task - Emitting: 4 default ["years" 3]
    5032 [Thread-26-4] INFO  backtype.storm.daemon.executor - Processing received message source: 3:2, stream: default, id: {}, ["ago"]
    5032 [Thread-26-4] INFO  backtype.storm.daemon.task - Emitting: 4 default ["ago" 3]
    5127 [Thread-42-1] INFO  backtype.storm.daemon.task - Emitting: 1 default ["four score and seven years ago"]
    5128 [Thread-22-3] INFO  backtype.storm.daemon.executor - Processing received message source: 1:1, stream: default, id: {}, ["four score and seven years ago"]
    5128 [Thread-22-3] INFO  backtype.storm.daemon.task - Emitting: 3 default ["four"]
    5128 [Thread-22-3] INFO  backtype.storm.daemon.task - Emitting: 3 default ["score"]
    5128 [Thread-28-4] INFO  backtype.storm.daemon.executor - Processing received message source: 3:5, stream: default, id: {}, ["four"]
    5128 [Thread-22-3] INFO  backtype.storm.daemon.task - Emitting: 3 default ["and"]
    5129 [Thread-28-4] INFO  backtype.storm.daemon.task - Emitting: 4 default ["four" 4]
    5129 [Thread-22-3] INFO  backtype.storm.daemon.task - Emitting: 3 default ["seven"]
    5129 [Thread-28-4] INFO  backtype.storm.daemon.executor - Processing received message source: 3:5, stream: default, id: {}, ["score"]
    5129 [Thread-30-4] INFO  backtype.storm.daemon.executor - Processing received message source: 3:5, stream: default, id: {}, ["and"]
    5129 [Thread-22-3] INFO  backtype.storm.daemon.task - Emitting: 3 default ["years"]
    5129 [Thread-28-4] INFO  backtype.storm.daemon.task - Emitting: 4 default ["score" 4]
    5129 [Thread-26-4] INFO  backtype.storm.daemon.executor - Processing received message source: 3:5, stream: default, id: {}, ["seven"]
    5129 [Thread-30-4] INFO  backtype.storm.daemon.task - Emitting: 4 default ["and" 4]
    5129 [Thread-22-3] INFO  backtype.storm.daemon.task - Emitting: 3 default ["ago"]
    5129 [Thread-26-4] INFO  backtype.storm.daemon.task - Emitting: 4 default ["seven" 4]

Note: There is still a fatal bug for storm itself to run on clojure 1.6.0,
plz stay clojure 1.5.1 until new storm version released If you meet
the error :

    291 [Thread-8] ERROR backtype.storm.event - Error when processing event
    java.lang.IllegalStateException: Attempting to call unbound fn: #'backtype.storm.util/some?


## Resource

Code above is hosted in https://gist.github.com/3f45ec3f3456583cd257

Thanks:

* http://storm.apache.org/documentation/Clojure-DSL.html
* http://storm.apache.org/documentation/Tutorial.html
* https://github.com/nathanmarz/storm-starter
* Book: Get started with storm
