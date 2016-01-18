---
layout: post
category: technology
title: Idea - Flask Permission Management
---

在确认现存的软件包没有符合我的需求的情况下，我不得不硬着头皮撸了一个库。

它的需求还算简单：管理员管理用户组和权限，给人加减权限，给用户组加减权限，给用户组加人踢人。 (一个简化了的 Django Auth Contrib)

应用层在稍作配置后，可以通过装饰器保护一些路由：

{% highlight python %}
@app.route('/post/publish')
@perm.require_permission('post.publish', 'post.admin')
def publish_post():
    return 'Hey, you can publish post!'
{% endhighlight %}

在代码层面它需要的事情就是这么多了。

我把其它管理的部分作为 WEB UI 发布。
这类数据使用数据库管理会比一些在代码中写死的库让我更好受一些。

实现这个 UI 库花了我不太多的时间，感谢 [ng-admin](https://github.com/marmelab/ng-admin), 我只需要专心写好 RESTful API，一些简单的配置让 UI 库的构建变得简单了很多：

![](/images/2016/flask-perm-manipulation.gif)

好在这种工具一般在内部使用，这样的 UI 可以不用面对大量的用户。

这个库零零碎碎地写一点，有一天终于受不了了，花了小半天搞完并交付使用。
能够以我觉得不大的代价 RUN 起来这件事情，我觉得很开心。
