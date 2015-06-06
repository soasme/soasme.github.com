---
layout: post
title: 使用Golang生成随机数
category: technology
tags: go
---


`main` 中的代码用来计算生成指定数字所需要的次数，最后打印出来的是平均次数。

`random` 中的 `ch` 在被 `tmp` 读取前写入是堵塞的，而写入哪一个又是随机的。不知道这个随机是真随机还是伪随机。

好吧，运行出来要一段时间，还是看不出来。这种写法太蛋疼了，生成随机数用让出时间片的办法来做，虽然Go语言的 `goroutine` 是个很高效的东西，但是用在这种地方确实还是很大的一笔开销。


    package main

    import "fmt"

    func random(length int) ( num int ) {
        num = 0
        ch := make(chan int, 1)

        for i := 0; i < length; i++{
            select {
            case ch <- 0:
            case ch <- 1:
            case ch <- 2:
            case ch <- 3:
            case ch <- 4:
            case ch <- 5:
            case ch <- 6:
            case ch <- 7:
            case ch <- 8:
            case ch <- 9:
            }
            tmp := <-ch
            num = num*10 + tmp
        }
        return
    }


    func main() {

        assigned_number := 1
        count_total := 0
        for c:=0; c<10000; c++ {
            i := 0
            for ; ; i++ {
                r := random(4)
                if r == assigned_number {
                    break
                }
            }
            count_total += i
        }

        fmt.Println( count_total/10000 )
    }
