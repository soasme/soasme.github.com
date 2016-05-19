---
layout: post
category: life
title: RPG 记忆宫殿
---

Created 5.09

这是一个脑洞很大的设定。 首先，这是一个记忆工具。 它的工作原理是记忆宫殿。 对，就是卷福装逼大杀器。 滚，我去记忆宫殿遨游惹。 它不基于现实生活的场景。 而是进入角色扮演游戏里。 随便乱逛，打打怪记东西。 想象一下，你就走着走着。 然后你操起了你的碧血剑。 一刀下去，怪物喷出鲜血。 口中大叫，单词：ponder。 一刀下去，怪物没有犹豫。 捂着伤口说，释义：沉思。 一刀下去，怪物流着鲜血。

---

Updated 5.11

调研了可能的构建记忆宫殿的方法。
例如，曾经豆瓣的阿花城就很合适。
但是木有开源实现，自己写一个又很烦。
OpenStreetMap 是一个 GIS 的 WEB 应用，但是解析略繁琐。
我的结论是，使用 Tiled 或者现成的 TMX Libraries 来绘制 TMX 地图。
这种技术在 2D 游戏里最为常见。

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

---

Updated 5.17

晚上编程时间很有限，但是单元测试不能省。

{% highlight bash %}
$ make test
busted src
●●●●●●●●●●●●●●●●
16 successes / 0 failures / 0 errors / 0 pending : 0.005402 seconds
{% endhighlight %}

---

Updated 5.18

为了顺便响应潮流，我打算在新项目中用 redux 来写游戏逻辑。
由于完全没有找到 redux 的 lua 实现，我必须自己手动撸一个。
好在 redux 本身并没有什么逻辑，写起来可能会很快。
另外，我决定在 redux.lua 还没撸出来之前，先写写业务逻辑，以后再整合。

具体来说，目前看起来代码像这样子:

Reducer:

{% highlight lua %}
function camera.reducer(state, action)
    if action.type == 'MOVE_CAMERA' then
        local dx = action.dx or 0
        local dy = action.dy or 0
        return assign(state, {
            x = state.x + dx,
            y = state.y + dy,
        })
    end
end
{% endhighlight %}

Component:

{% highlight lua %}
function camera.update(dt)
    store.dispatch({
        type = 'SET_CAMERA_POSITION',
        x = store.player.x - love.graphics.getWidth() / 2,
        y = store.player.y - love.graphics.getHeight() / 2,
    })
end

function camera.draw(children)
    -- Set camera
    love.graphics.push()
    love.graphics.rotate(-store.camera.rotation)
    love.graphics.scale(1 / store.camera.scaleX, 1 / store.camera.scaleY)
    love.grahpics.translate(-store.camera.x, -store.camera.y)

    -- Render children nodes
    if children then
        for _, child in pairs(children) do
            child()
        end
    end

    -- Unset camera
    love.grahpics.pop()
end
{% endhighlight %}

游戏的代码组织就是很简单的两个目录:

- src/components: 放置绘制逻辑，具体来说，draw 函数根据全局的状态树渲染当前界面，根据监听的事件以及love2d定义的钩子调用 store.dispatch 用于触发事件。
- src/reducers: 放置业务逻辑，具体来说，reducer 函数响应事件并生成新的状态。
- src/store: 定义一颗全局状态树。

运行情况：

![](/images/2016/rpg-mind-palace-move-camera.gif)
