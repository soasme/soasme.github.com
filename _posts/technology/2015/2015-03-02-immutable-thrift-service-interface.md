---
layout: post
category: technology
title: Immutable thrift service interface
tag:
- pattern
- microservice
---



## About Immutable Infrastructure

* Automate the setup and deployment for every part and every layer of your infrastructure.
* Never change any part of your system once it is deployed. If you need to change it, deploy a new system

## About Thrift service

Remote procedure call refers to the technique of making a local call and having it execute on a remote service somewhere.
Thrift make it easy to define and create a remote procedure call service.
Checkout [Thrift: the missing guide](http://diwakergupta.github.io/thrift-missing-guide/) to explore basic usage.

## Question: But when we meet the problem of API amending?

There are some backward compatible changes that will not make inpact on existing callers:

* Adding new methods or structs
* Adding a non-required field to a struct
* Changing a method return type from void to anything else
* Removing an exception from a method signature
* Adding an argument to a method with or without a default value

and some are imcompatible changes:

* Removing a field from a struct
* Renaming a struct
* Removing an argument from a method
* Changing the order of arguments in a method
* Changing the namespace
* Removing or renaming a method
* Changing the type of an argument in a method
* Changing the declared type of a return value, or changing it to void
* Adding an exception to a method (with a non-void return type)

If we want to make our thrift service always backward compatible, make it immutable!

## Immutable interface

Don't doing imcompatible changes, instead of adding a new method, keeping legacy method existing but deprecated until no callers.
