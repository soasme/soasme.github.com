---
layout: post
category: technology
tags: go
title: 一些Go语言的特性
---


都在代码里了。

    package main

    import (
        "fmt"
    )

    const (
        first = iota
        middle
        last
    )

    type Bird struct {
        Height int
    }

    func (b Bird) Talk() (words string) {
        words = "bee"
        return
    }

    func (b *Bird) Fly(height int) {
        b.Height = height
    }

    type Duck struct {
        Bird
    }

    func (this Duck) Talk() (words string) {
        words = "gaga gaga"
        return
    }

    func (this *Duck) Fly() {
        this.Height = 1
    }


    func calculate(method string, args ...int) int {
        var result int
        for i := range(args) {
            result += i
            fmt.Println( result, i)
        }
        return result
    }

    func will_cause_panic() {
        defer func() {
            if r:= recover(); r != nil {
                fmt.Println( "Programe fatal @", r)
            }
        }()

        func() {
            panic("tmp assigned 1")
        }()
    }

    func main() {
        will_cause_panic()

        fmt.Println("calculaet add",  calculate("add", 1, 2, 3, 4, 5) )

        bird := new(Bird)

        fmt.Println( bird.Talk() )
        bird.Fly(100)
        fmt.Println( bird.Height )
        fmt.Println( first, middle, last)

        duck := new(Duck)
        fmt.Println( duck.Talk() )
        duck.Fly()
        fmt.Println( duck.Height )

        arr := [3]int{1, 2, 3}
        fmt.Println( arr )

        arr[0], arr[2] = arr[2], arr[0]
        fmt.Println( arr )

        for k, v := range arr {
            fmt.Print( k, v)
        }
        for k, v := range(arr) {
            fmt.Print( k, v)
        }

        fmt.Println( arr[1:] )

        arr_by_make := make([]int, 5)
        fmt.Println(arr_by_make)

        m := make(map[string] string)
        m["name"] = "soasme"
        m["github"] = "http://github.com/" + m["name"]
        m["nothing"] = "dummy"
        fmt.Println(m)

        delete(m, "nothing")
        fmt.Println(m)

        _, dummy_ok := m["nothing"]
        if ! dummy_ok {
            fmt.Println("nothing not in m")
        }

    }
