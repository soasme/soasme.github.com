---
layout: post
category: life
tag: sparrow
---

parrow多余的签名
===

免费的Sparrow签名档一直有两个签名：

已使用 Sparrow

已使用 Sparrow

很烦人。干掉多余的那个签名的方法是：

打开 `/Applications/Sparrow.app/Contents/Resources/zh_CN.lproj/Composer.strings` 文件，找到这行：

    /* Default signature for account. HTML format. %@ is the signature identifier */
    "Sent with <a href=\"http://www.sparrowmailapp.com/?%@\">Sparrow</a>" = "已使用 <a href=\"http://www.sparrowmailapp.com/?%@\">Sparrow</a>";

修改，变成 

    "Sent with <a href=\"http://www.sparrowmailapp.com/?%@\">Sparrow</a>" = ""; 

即可。
