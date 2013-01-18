---
layout: post
category: technology
tag: svn
---

Locale UTF-8
===

莫名其妙突然用svn的时候遇到任何操作都会报这个warning:

{% highlight bash %} 
    base [trunk:144846] % echo $LC_CTYPE 
    zh_CN.UTF-8
    svn: warning: cannot set LC_CTYPE locale
    svn: warning: environment variable LC_CTYPE is zh_CN.UTF-8
    svn: warning: please check that your locale name is correct
    base [trunk:144846] % echo $LC_ALL 
    en_US.UTF-8
    svn: warning: cannot set LC_CTYPE locale
    svn: warning: environment variable LC_CTYPE is zh_CN.UTF-8
    svn: warning: please check that your locale name is correct
{% endhighlight %}

网上什么乱七八糟的解决方案。
看了下我的机器自己可能突然丢了zh_CN.UTF-8的locale吧，所以应该重新生成就好了

{% highlight bash %} 
    base [trunk:144846] % 
    svn: warning: cannot set LC_CTYPE locale
    svn: warning: environment variable LC_CTYPE is zh_CN.UTF-8
    svn: warning: please check that your locale name is correct
    base [trunk:144846] % sudo locale-gen zh_CN
    Generating locales...
      zh_CN.GB2312... done
    Generation complete.
    svn: warning: cannot set LC_CTYPE locale
    svn: warning: environment variable LC_CTYPE is zh_CN.UTF-8
    svn: warning: please check that your locale name is correct
    base [trunk:144846] % sudo locale-gen zh_CN.UTF-8
    Generating locales...
      zh_CN.UTF-8... done
    Generation complete.
{% endhighlight %}

EOF
