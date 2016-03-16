---
layout: post
category: technology
title: Fis && Flask
---


很遗憾，Python Web 框架貌似没有一个能在静态文件编译这个领域做到 Rails Assets 那个程度。
我们的前端选型是选择熊厂的 fis。我觉得凑合还能用吧。

最近在做部署系统，希望将构建流程能从部署中分离。
这意味着我们需要做静态资源的提前编译。

鉴于 fis 目前只能提供对特定文件类型全局地加 CDN 域名，不撸一点东西，不太可能能做到打出环境无关的包来：提前编译的静态资源，要么全都带域名，要么全不带域名。

而我们在不同的环境是会配置不同的 CDN 域名的。这意味着我们将需要对不同的 CDN 域名构建出不同的产物。

---

需求：

* fis 构建的静态资源全部不带域名；
* 编译的 html 是 flask 的模板，其中对静态资源的引用可以通过上下文动态生成带域名的链接。

---

解决方案：

* `fis release` 取消 `--domains` 选项，编译出不带域名的静态资源。
* 所有的静态资源构建到 static 目录，并通过 `/static` 访问这些资源。
* 所有的模板构建到 templates 目录，在 Flask 路由函数中通过 `render_template` 访问这些资源。
* 在 templates 目录里面的所有 `html` 文件中，将 css/js 的链接修改为 `url_for` 调用，通过撸 fis 插件完成。

{% highlight javascript %}
    fis.config.set('modules.postprocessor.html', function (content, file, conf) {
      // replace js/img src
      reg = /<(script|img|style|embed)(.+?)src=["']?\s*?\/static\/([^"']+)\s*?["']?(.*?)>/g;
      var c = content.replace(reg, function(m, p1, p2, p3, p4, value) {
        return "<" + p1 + p2 + 'src="{{ url_for(\'static\', filename=\'' + p3 +'\') }}"' + p4 + '>';
      });
      // replace css link
      reg2 = /<link(.+?)href=["']?\s*?\/static\/([^"']+)\s*?["']?(.*?)>/g;
      var d = c.replace(reg2, function(m, p1, p2, p3, value) {
        return "<link" + p1 + 'href="{{ url_for(\'static\', filename=\'' + p2 +'\') }}"' + p3 + '>';
      });
      return d;
    });
{% endhighlight %}

通过这个配置，我们可以将

{% highlight html %}
    <link rel="stylesheet" href="/merchant/css/com/com.scss"/>
{% endhighlight %}

改写为


{% highlight html %}
    <link rel="stylesheet" href="{ { url_for('static', filename='merchant/css/com/com_4a87286.css') } }"/>
{% endhighlight %}


* 通过额外使用的 Flask-CDN 插件，在配置文件中配置不同环境的 CDN_DOMAIN, 以上模板中的 `url_for` 将产生：

{% highlight html %}
    <!-- development -->
    <link rel="stylesheet" href="/static/merchant/css/com/com_4a87286.css"/>

    <!-- staging -->
    <link rel="stylesheet" href="http://7xl1k8.com2.z0.glb.qiniucdn.com/static/merchant/css/com/com_4a87286.css"/>

    <!-- production -->
    <link rel="stylesheet" href="https://dn-shop-static.qbox.me/static/merchant/css/com/com_4a87286.css"/>
{% endhighlight %}


---

这个方案基本上达到了 DRY 的目的。

警告：以上方案为快速 Hack，谨慎使用。
