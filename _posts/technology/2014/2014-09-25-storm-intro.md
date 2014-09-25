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

### Spout

TODO

### Bolt

TODO

### Topology

TODO

### Run Topology

TODO
