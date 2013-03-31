---
layout: post
category: technology
tag: gem
---



临时解决gem无法安装的问题
===

就是这么个情况。

{% highlight=ruby %}

    ~ % gem install cramp
    ERROR:  Could not find a valid gem 'cramp' (>= 0), here is why:
    Unable to download data from https://rubygems.org/ - SSL_connect returned=1 errno=0 state=SSLv3 read server key exchange B: bad ecpoint (https://rubygems.org/latest_specs.4.8.gz)

    ~ % gem source -a http://rubygems.org/
    https://rubygems.org is recommended for security over http://rubygems.org/

    Do you want to add this insecure source? [yn]  y

    http://rubygems.org/ added to sources

    ~ % gem install cramp
    Fetching: activesupport-3.0.20.gem (100%)
    Successfully installed activesupport-3.0.20
    Fetching: rack-1.3.10.gem (100%)
    Successfully installed rack-1.3.10
    Fetching: eventmachine-1.0.3.gem (100%)
    Building native extensions.  This could take a while...

{% endhighlight %}
