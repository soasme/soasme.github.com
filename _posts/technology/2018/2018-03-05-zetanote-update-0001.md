---
layout: post
category: technology
tags: zetanote
title: Zetanote Update 0001
---

项目地址：https://github.com/soasme/zetanote
(尚未发版)

---

## 初衷

很难说清楚为什么会写 zetanote 这款应用。这几年换了很多笔记应用，例如 evernote, day one, onenote, wiz, simplenote, Notes, Pendo, tiddlerwiki。为什么换了又换，我也不太清楚，每次总有这样那样的理由。最近的一次是切换到 simplenote 上，辅助以一些 Python script 完成笔记的自动化。最近几天把 techshack 的笔记迁移到 zetanote 上，效果意外的好。

树和标签，这两套系统可能是我姿势不对，一直用不好。直接根据关键字检索，我老是找不到想要的东西。我记笔记可能和别人不同，我很在意给笔记添加足够的元信息，这样搜索的时候，可以根据条件选出一批非常相关的笔记来。

所以，我就得到了 zetanote 的最核心功能：使用元信息帮助组织内容。至于元信息是什么，它可以是 anything。
次核心的功能是能构建类 wiki 一样的知识图谱。这样才能消化知识，并随时根据关键词记起它在图谱中的位置，进而找到它。

## 演变

* 2017-12-18, 整理当前的[工作流](https://www.douban.com/note/649464825/)，整理出自己是怎么做笔记的。
* 2017-12-21, 提出一种 `[笔记]` 可以自动新建笔记的系统（后来发现，这是 tiddlerwiki 已经实现的特性）
* 2018-01-04, 对 simplenote 的工作流提出疑问，认清需求：快速链接笔记，按照多种条件组织笔记，能组出知识图谱。
* 2018-01-24, 用户数据，在存储上，可以类似 http header + body。
* 2018-02-06, 实验 JuiceFS，在 docker 中运行，测试单机连接到远端云存储服务。
* 2018-02-07, 从事务保障上考虑觉得数据库存储会更好。提出了类 sql 查询的想法，用于搜索笔记。
* 2018-02-17, 对目前记笔记的全局性不够尝试提出解决办法：
* 2018-02-18, 导数据进入 tiddlerwiki. 觉得使用 tiddlerwiki 也许可以解决问题。好的地方在于路数是对的，不好的地方在于使用不太方便。
* 2018-02-27, 调通 JuiceFS。
* 2018-03-01, zeta 初版。将 techshack 的笔记导到一个 json 文件。使用 tinydb 操作数据。使用 vim 笔记笔记。
* 2018-03-03, zeta instaweb 发布，可以在浏览器中查笔记。
* 2018-03-04, zeta instaweb 可以增改笔记。
* 2018-03-05, 项目第一次总结。

## 未来

有几个大致的走向：

1. 继续在 cli 和 instaweb 上做特性开发，不想做到太重，想把定制流程的这个过程交给用户自己来做，因为千人千面。[sidenote:](https://www.douban.com/note/649464825/)
2. 提供 premium 服务，用户不用 self-hosted。开发 market，用于让用户互相分享工作流。
3. 开发 api 和客户端。

EOF
