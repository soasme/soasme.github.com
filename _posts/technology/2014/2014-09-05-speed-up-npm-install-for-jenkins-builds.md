---
layout: post
category: technology
title: Speed up `npm install` for jenkins builds
tag: jenkins
---



We waste a large amount of time to wait every single jenkins job installing
it's npm dependencies. This is awful to watch and it takes precious time
that should rather be spent running the build.

The basic idea is to create a jenkins job to pre-build node_modules.

![Create job](/images/2014/2014-09-06-create-job.png)

Set parameter:

![Parameter](/images/2014/2014-09-06-parameter-setting.png)

And execute shell at last:

{% highlight bash %}
git reset --hard $BRANCH_HEAD
PACKAGE_JSON_HASH=`git log --format="%H" -1 package.json`
BUILD_TAR_FILE=$REMOTE_DIR"$PACKAGE_JSON_HASH".tar.gz
if [ ! -e $BUILD_TAR_FILE ]; then
  npm install --registry $REGISTRY && mkdir -p $REMOTE_DIR && tar czf $BUILD_TAR_FILE node_modules/
fi
{% endhighlight %}

----

Now we have a prebuild node_modules tar package in remote folder.
Everytime we trigger build, just copy tar file, untar file.
npm install will recognise it and ignore the remote fetching.

[1]: http://blog.travis-ci.com/2013-12-05-speed-up-your-builds-cache-your-dependencies/
