---
layout: post
category: technology
title: Href Today
---

最近两周在写一个 Side Project: [Href Today](https://www.href.today/topics/2/issues).

## 初衷

* Blog 的素材太少，难以利用
* Pocket 的知识消化率很低，没有沉淀

## 愿景

* 可以很好地将对 Pocket 收藏的素材做深度阅读，又能以文字的形式沉淀下来。
* 这些内容可以随时扩展为一篇高质量的博客。
* 由于深度阅读很耗费精力，因此每天能阅读的量很有限，我觉得每天五篇撑死。

## So?

写了一个自用的学习工具，以 5 篇 url 思考心得做聚合，生成一期。

## 现状

鉴于过去数年来写废了无数个项目，我在一天内快速写完架子后便上线到 Heroku 了，此后转到了 AWS。
它使用了以下 Python 包：

* Flask 作为 Web 框架，
* 使用 Flask-SQLAlchemy 搭配 Postgresql 作为数据库，
* 使用 Flask-Cache 搭配 Redis 作为缓存。
* 使用 Flask-Nav 配置导航栏(扩展了它使它能支持我想要的样式)
* 使用 Flask-Bootstrap 快速写模板（目前只有 1200 行 HTML 代码，没有一行 css）
* 使用 Flask-User 快速搭建了用户系统，大概花了一个小时吧
* 使用 Sentry 收集错误
* 使用 Flask-Admin 管理数据库
* 使用 Flask-OAuthlib 提供 OAuth2 验证

为了避免自己再写废这个项目，我花了一些心思。

* 花了 $20 买了一个我觉得非常合适的域名，因为本来就是来给自己对几个特定的链接做深度的阅读
* 做了一个还算不太难看的 ico，但 Logo 还没做出来
* 为了看上去严肃认真，我今天为它加上了 `Lets Encrypt`，现在它只能通过 HTTPS 访问
* 保持上线的节奏，每天都能上线 10 次左右
* 在能用第三方库的情况下，绝不自己造车轮（目前这个项目大概只有1500行代码）
* 保证项目只做核心功能：阅读，思考，但会提供一些自动化工具保证流程可以得到简化
