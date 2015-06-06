---
layout: post
title: 在Quixote中设置content-type为application/json
category: technology
tag: quixote
---


在[Cookbook](http://quixote.ca/qx/QuixoteCookbook.html) 与[WorldIndex](http://quixote.ca/qx/WordIndex.html)并没有找到比较好的办法，不是我找的姿势不对就是文档写的太次。

解决方案：自定义 `Publisher` 方法，在其中hack.

{% highlight python %} 
    # -*- coding: utf-8 -*-

    from quixote.publish import Publisher

    class CustomPublisher(Publisher):

        def try_publish(self, request):
            """(request : HTTPRequest) -> object

            The master method that does all the work for a single request.
            Exceptions are handled by the caller.
            """
            self.start_request()
            method = request.get_method()
            allowed_methods = self.config.allowed_methods
            if allowed_methods is not None and method not in allowed_methods:
                raise MethodNotAllowedError(allowed_methods)
            path = request.get_environ('PATH_INFO', '')
            if path and path[:1] != '/':
                return redirect(
                    request.get_environ('SCRIPT_NAME', '') + '/' + path,
                    permanent=True)
            components = path[1:].split('/')
            output = self.root_directory._q_traverse(components)

            # hack here. 
            if components and 'api' == components[0]:
                request.response.set_content_type('application/json; charset=utf-8')

            # The callable ran OK, commit any changes to the session
            self.finish_successful_request()
            return output
{% endhighlight %}

and then in `wsgi.py`:

{% highlight python %}
    # -*- coding: utf-8 -*-

    from quixote.wsgi import QWIP
    from website.publisher import CustomPublisher
    from website.views import RootUI

    publisher = CustomPublisher(RootUI())
    application = QWIP(publisher)
{% endhighlight %}

这样凡是以 `/api/` 开头的所有url就会被认为是 `application/json`了.
