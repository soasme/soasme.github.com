---
layout: post
category: technology
tag: sinatra
---

Sinatra Modular Route
===

没有找到简单的Sinatra模块化后的路由方案。
[Stack Overflow](http://stackoverflow.com/questions/2480607/using-cucumber-with-modular-sinatra-apps)上提到了了一种方法：

+ 用 `Rack::Builder` 手动映射路由与控制器

在 Sinatra: Up And Running 一书中提到的做法则是在 `config.ru` 中编写这样的代码：

    require 'sinatra/base'
    Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file }
    map('/example') { run ExampleController }
    map('/') { run ApplicationController }

因为比较不爽写重复的代码，这两种方法都重复写了类名，所以自己想了下，在 `app.rb` 总控的类中去完成自动加载的事情：

    # -*- coding: utf-8 -*-

    require 'sinatra/base'

    class LyricHeart < Sinatra::Base

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
