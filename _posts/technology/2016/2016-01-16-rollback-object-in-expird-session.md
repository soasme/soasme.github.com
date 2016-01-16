---
layout: post
category: technology
title: Rollback Objects in Expired Session
---

我们的代码仓库大量地应用了装饰器`rollback_on_failure`, 已保证在出错时函数可以回滚事务。
以下是其实现：

{% highlight python %}
def rollback_on_failure(db):
    def deco(f):
        @wraps(f)
        def _(*args, **kwargs):
            try:
                return f(*args, **kwargs)
            except:
                db.session.rollback()
                raise
        return _
    return deco
{% endhighlight %}

在一次报错中，我发现它无法应用在一种情况里。
假设我们有这样的函数：

{% highlight python %}
@rollback_on_failure(db)
def reduce_stock(id, stock):
    obj = Model.query.get(id)
    obj.stock = Model.stock - stock
    db.session.add(obj)
    try:
        db.session.commit()
    except OperationalError:
        raise InsufficientStock(dict(id=obj.id, stock=obj.stock, other=obj.other))
{% endhighlight %}

当代码进入 OperationalError 分支时，这段代码其实是有问题的。
因为数据库的报错，SQLAlchemy 将此次 Session 标为过期，我们无法再从 obj 里获取数据

正确的写法是：

{% highlight python %}
def reduce_stock(id, stock):
    obj = Model.query.get(id)
    obj.stock = Model.stock - stock
    db.session.add(obj)
    try:
        db.session.commit()
    except OperationalError:
        db.session.rollback()
        raise InsufficientStock(id)
{% endhighlight %}

* 首先应该回滚事务，结束当前Session，此时获取数据才有意义
* 如果要获取最新的stock, 应该在事务结束后，在控制层获取
