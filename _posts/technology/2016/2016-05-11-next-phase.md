---
layout: post
category: technology
tag: architecure
title: Next Phase
---

I am designing architecture that can support service development of our company in the next years.

We are running a monolithic application last year, with tons of modules tangled with each other.
I am trying to split big code base into many small but easily maintained services and use a gateway to build them all.

Although I am not mature at architecture, the system design decision has to be made.
This is a graph of my ideal architecture for our system in the next phase:

<img src='http://g.gravizo.com/g?
    digraph G {
    gateway -> service1;
    gateway -> service2;
    gateway -> service3;
    gateway -> service4;
    service1 -> message_broker;
    service2 -> message_broker;
    service3 -> message_broker;
    service4 -> message_broker;
    message_broker -> service1;
    message_broker -> service2;
    message_broker -> service3;
    message_broker -> service4;
    }
'>


### gateway

The gateway, like glue, combines all the services.
It should not have complex logic.

All it does is to call services and build their results into, JSON HTTP in our use case, a final result.

### microservices

Microservices are fine grained abstractions.
Each service should only care the logic it is responsible.
Each service should make sure the ACID of transaction.
Services are NOT ALLOWED TO CALL EACH OTHER.
They can only communicate with each other through message broker.

### message broker

Message broker receives the message emitted from a service,
and then dispatches message to those services who subscribed that message type.
Each message should contains message type, so that we can recognize it.
Subscribers should register subscription to message broker.

## Implement

* Nginx instance as user request load balancer
* Another Nginx instance as microservices load balancer
* A tornado application as gateway
* Microservices are driven by multiple web frameworks
  * Flask
  * Django
  * Spring
  * etc.
* [Rio](https://github.com/soasme/rio) instance as message broker

## Summary

I want a simple architecture, which needs only a few system components.
I think this architecture is a simple one.

After all, I have to admit that it still misses some components:

* service tracing
* service log collection
* service health monitoring
* service discovery (we are pushing hosts to /etc/hosts now)

It still leaves loads of questions to me.
The architecture, to my certain knowledge, is not a one-day work.
I will add missing components, collect solutions on solving problems during next phase,
and draw another blueprint at that time. :)
