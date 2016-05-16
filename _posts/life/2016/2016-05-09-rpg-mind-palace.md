---
layout: post
category: life
title: RPG 记忆宫殿
---

这是一个脑洞很大的设定。 首先，这是一个记忆工具。 它的工作原理是记忆宫殿。 对，就是卷福装逼大杀器。 滚，我去记忆宫殿遨游惹。 它不基于现实生活的场景。 而是进入角色扮演游戏里。 随便乱逛，打打怪记东西。 想象一下，你就走着走着。 然后你操起了你的碧血剑。 一刀下去，怪物喷出鲜血。 口中大叫，单词：ponder。 一刀下去，怪物没有犹豫。 捂着伤口说，释义：沉思。 一刀下去，怪物吃着便当。 你又走着走着，遇到村民。 靠近他，他根本不让你走。 一把抓住你，单词：ovum。 你嘴角微微翘起来，卵子。 他说卵子，你便径自走开。

---

Updated 5.11

调研了可能的构建记忆宫殿的方法。
例如，曾经豆瓣的阿花城就很合适。
但是木有开源实现，自己写一个有很烦。
OpenStreetMap 是一个 GIS 的 WEB 应用，但是解析略繁琐。
我的结论是，使用 Tiled 或者 TMX Libraries 来绘制 TMX 地图。
这种技术在 2D 游戏里最为常见

---

Updated 5.13

午后醒来研究了下刷子和贴图，随手绘制了下一张图，感觉处于可用的状态
![](/images/2016/rpg-map-v1.png)

---

Updated 5.15

由于外出去看妈妈和侄女，木有大进展。
尝试用 Swift + SpriteKit 的方式来加载地图，使用的库叫 JSTiledMap。
使用了 OBJ-C 的 Header Bridge，将其导入给 Swift 使用。

[Read More](https://www.raywenderlich.com/29458/how-to-make-a-tile-based-game-with-cocos2d-2-x)

{% highlight swift %}
import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        // load first scene tmx map
        let tiledmap = JSTileMap(named: "first-scene.tmx");

        // center map on scene's anchor point
        tiledmap.position = CGPointMake(160, 80);

        // add map to scene.
        self.addChild(tiledmap);
    }
}
{% endhighlight %}

但是感觉使用 Swift 写，将来写 NPC 之类的行为很难受，找了个叫 Love2D 的框架。
使用一个叫 STI 的库，可以蛮方便导入地图：

{% highlight lua %}
local sti = require "sti"

function love.load()
    map = sti.new("assets/first-scene.lua")
end

function love.update(dt)
    map:update(dt)
end

function love.draw()
    map:draw()
end
{% endhighlight %}


