---
layout: post
category: technology
tag: storm
---

# Storm Intro

Storm is a distributed realtime computation system, which provides
a set of general primitives for doing **REALTIME** computation.
Storm makes it easy to reliably process unbounded streams of data
unlike what Hadoop did via batch processing. Storm can be used in:

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

## Real World Example.

### Spout

TODO

### Bolt

TODO

### Topology

TODO

### Run Topology

#### LocalCluster
#### StormSubmitter
#### DRPC Topology

