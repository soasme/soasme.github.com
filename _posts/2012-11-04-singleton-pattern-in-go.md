---
layout: post
tags: go
---

在Go语言中使用单例模式
=====================

在Go语言中的单例模式写法会比Java/Python繁琐一点，但是总的思路是一样的。

- 我们需要隐藏单例类的初始化方法，取而代之用一个 `GetInstance` 的方法。外界能获得单例类对象的唯一途径就是去调用 `GetInstance` 方法。

[国外一篇论文](http://cxwangyi.wordpress.com/2012/01/01/%E7%94%A8go%E8%AF%AD%E8%A8%80%E5%AE%9E%E7%8E%B0design-patterns/) 中介绍了这样的方法:

预备知识: 空接口 `type Any interface{}` 可以做出别的语言所谓的 `Any` 类型, 变量或类型小写将被作为包的私有类型, 外部无法获得



    package main

    import (
        "fmt"
    )

    type Singleton interface {

    }

    type singleton struct {

    }

    var theSingleton Singleton

    func GetSingletonInstance() Singleton {
        if theSingleton == nil {
            theSingleton = new(singleton)
        }
        return theSingleton
    }



    func main() {
        s1 := GetSingletonInstance()
        s2 := GetSingletonInstance()

        if s1 == s2 {
            fmt.Println("s1 is the same instance with s2.")
        }
    }

上述代码中 `Singleton` 是一个interface, 而 `singleton` 则是我们要实现的类, 通过 `theSingleton` 与 `GetSingletonInstance()` 来实现单例模式。

但是，这种写法有个问题。 `main` 中的 `s1` 与 `s2` 并没有获取 `singleton` 类变量和方法的权限，这是因为 `s1` 与 `s2` 是 `Singleton` 的类型，而 `Singleton` 并未规约任何方法, 任何妄图通过 `s1` `s2` 来调用 `singleton` 的方法都会导致错误的行为, 除非调用 `singleton` 的方法在 `Singleton` 中有接口方法声明。这样一个方法就需要重复写两次了。

    type Singleton interface {
        AFunction() (result string)
    }

    type singleton struct {

    }

    func (s singleton) AFunction() (result string) {
        result = "hello world"
        return
    }

如此这般就能实现 `instance` 去调用 `singleton` 的方法了。(其实仍然觉得繁琐，希望可以看到更好的go语言单例实现.)
