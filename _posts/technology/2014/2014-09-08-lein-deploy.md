---
layout: post
category: technology
tag: clojure
---

# Deploy clojre jar to clojars

## Step 1: Install gpg and generate key

For Mac:

    brew install gpg

Create a keypair with:

    gpg --gen-key

Check:

    $ gpg --list-keys

                ↓↓↓↓↓↓↓↓
    pub   2048R/2ADFB13E 2013-03-16 [expires: 2014-03-16]
    uid                  Bob Bobson <bob@bobsons.net>
    sub   2048R/8D2344D0 2013-03-16 [expires: 2014-03-16]

Get gpg public key:

    gpg --export -a 2ADFB13E

Copy the entire output (including the BEGIN and END lines), and paste
it into the 'PGP public key' field of Clojars profile.

## Step 2: Configure

Edit (or create if not exist) `~/.lein/profiles.clj`:

{% highlight bash %}
{:signing {:gpg-key "2ADFB13E"}}
{% endhighlight %}

## Step 3: Edit your project.clj

Make sure no `SNAPSHOT` word in project.clj.
and then execute `lein deploy clojars`:

{% highlight bash %}
spymemcat [master] % lein deploy clojars
No credentials found for clojars
See `lein help deploying` for how to configure credentials to avoid prompts.
Username: soasme
Password:
Wrote /Users/soasme/space/soft/spymemcat/pom.xml
Created /Users/soasme/space/soft/spymemcat/target/spymemcat-0.1.0.jar

您需要输入密码，才能解开这个用户的私钥：“Lin Ju (soasme) <soasme@gmail.com>”
2048 位的 RSA 密钥，钥匙号 9F86D5F8，建立于 2014-09-08


您需要输入密码，才能解开这个用户的私钥：“Lin Ju (soasme) <soasme@gmail.com>”
2048 位的 RSA 密钥，钥匙号 9F86D5F8，建立于 2014-09-08

Sending spymemcat/spymemcat/0.1.0/spymemcat-0.1.0.pom (3k)
    to https://clojars.org/repo/
Sending spymemcat/spymemcat/0.1.0/spymemcat-0.1.0.jar (9k)
    to https://clojars.org/repo/
Sending spymemcat/spymemcat/0.1.0/spymemcat-0.1.0.jar.asc (1k)
    to https://clojars.org/repo/
Sending spymemcat/spymemcat/0.1.0/spymemcat-0.1.0.pom.asc (1k)
    to https://clojars.org/repo/
Could not find metadata spymemcat:spymemcat/maven-metadata.xml in clojars (https://clojars.org/repo/)
Sending spymemcat/spymemcat/maven-metadata.xml (1k)
    to https://clojars.org/repo/
{% endhighlight %}
