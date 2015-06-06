---
layout: post
title: Sinatra Modular Route
category: technology
tag: sinatra
---


没有找到简单的Sinatra模块化后的路由方案。
[Stack Overflow](http://stackoverflow.com/questions/2480607/using-cucumber-with-modular-sinatra-apps)上提到了了一种方法：

+ 用 `Rack::Builder` 手动映射路由与控制器

在 Sinatra: Up And Running 一书中提到的做法则是在 `config.ru` 中编写这样的代码：

    require 'sinatra/base'
    Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file }
    map('/example') { run ExampleController }
    map('/') { run ApplicationController }

这两种方法都重复了类名，子控制器继承了总控制器，继而使用map来映射。

自己想了下，其实可以在 `app.rb` 总控的类中去完成自动加载的事情，各个控制器是以中间件的形式进行调用的：

    # -*- coding: utf-8 -*-

    require 'sinatra/base'

    class Application < Sinatra::Base

      Dir.glob("#{ File.dirname(__FILE__) }/app/controllers/*_controller.rb") do |f|
        if f =~ /(\w+)_controller.rb/
          require f
          eval "use #{ $1.capitalize }Controller"
        end
      end

      configure do
      end
    end

以上
