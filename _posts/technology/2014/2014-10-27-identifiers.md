---
layout: post
category: technology
tag: clojure
---

# 标识

自然标识(Natural Key, Natural Identifier): 是实体中存在的, 真实世界里被广泛接受的, 用来独一无二地识别自身的标识. 关键词: 独一无二, 自身存在. [1] 一个实体里有这样的标识, 在数据库设计中一般会被用来做主键(Primary Key).

替代标识(Synthetic Key, Surrogate Identifier): 亦用于独一无二地标识一个实体, 然而, 此标识并不存在于实体中. 这是外部系统为此实体自动生成的, 即便如此, 这个标识还是可以为实体内外所使用并进行识别. 例子: 数据库的自增主键 (autoincrement primary key). [2]

举个栗子: `<User id=3770153 name="soasme">` 这样一个实体, `3770153` 这个 id 是数据库生成的, 对于系统来说是个有意义的标识符, 然而对我来说, 这个数字完全没有意义, 我的名字 soasme 是有意义的. 在这里, id 便是替代标识, name 便是自然标识. [3]


二者为相对的概念. 单从定义来说, 替代标识乃外源数据, 至少需要一个中间层对其进行操作. 复杂性源于此.

再以正则为例, `([a-c])x\1x\1` 可以匹配 `axaxa`, `bxbxb`, `cxcxc`. 然而, 我们推崇高阶组合, 以及更符合语义的方式做自描述:

{% highlight clojure %}
user=> (exec (regex [(chars {\a \c}) \x (any :as :any) \x (any :as :any)]) "axaxa")
{:any "a", nil "axaxa"}
{% endhighlight %}

此处, 对反向引用 (BackReference) 而言, 一个标识符是必须的, 上例中的 `\1`, `:any` 都是.
然而, 替代标识对于这个逻辑来说, 并不是必须的.
这不妨碍我们将 标识实体 这个关注点隔离到更小的层面----一个独立的步骤去:

{% highlight clojure %}
user=> (defn abcx-regex [f] [(chars {\a \c}) \x (f) \x (f)])

user=> (exec (abcx-regex (partial any :as :any)) "axaxa")
{:any "a", nil "axaxa"}

user=> (exec (abcx-regex any "axaxa")
{:nil "axaxa"}
{% endhighlight %}

我们引入中间层来隔离标识.
这样的思考方式让我们去努力的思考

* 到底什么样的数据是可以自标识的?
* 什么样的数据是值得添加替代标识的?
* 为什么值得添加?
* 将标识隔离到多大的层面?

这有助于我们更好地地设计系统内外的数据结构, 抽象这个世界.


Inspired by "Clojure Programming".

[1]: http://books.google.com.sg/books?id=QWLpAgAAQBAJ&pg=PA170&lpg=PA170&dq=Natural+identifiers&source=bl&ots=eJtYAS4BKy&sig=9_9RalPwKlr1D5TGd4ZQdJQL8io&hl=zh-CN&sa=X&ei=rKVMVOCCOaapmgWm9ILABA&ved=0CEIQ6AEwBA#v=onepage&q=Natural%20identifiers&f=false
[2]: http://en.wikipedia.org/wiki/Surrogate_key
[3]: http://ayende.com/blog/4061/nhibernate-natural-id
[4]: http://www.clojurebook.com/
