local us = require("app.lib.moses")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local ROW = 5
local COL = 3

function MainScene:onCreate(ctx)
    self.curPos = {
        i = math.ceil(ctx.random(ROW)),
        j = math.ceil(ctx.random(COL))
    }
    self.enemyPos = {
        i = math.ceil(ctx.random(ROW)),
        j = math.ceil(ctx.random(COL))
    }

    local bg = display.newSprite("bg.jpg"):move(display.center):addTo(self)
    bg:setScale(display.height / bg:getContentSize().height)

    self.enemy = cc.Node:create():addTo(self)
    display.newSprite("enemy.png"):move(display.center):addTo(self.enemy)
    cc.Label:createWithSystemFont("@SakeRice", "", 24):move(display.cx, display.cy + 250):addTo(self.enemy):enableShadow(cc.c4b(0, 0, 0, 255))
    local gauge = cc.DrawNode:create():addTo(self.enemy)
    gauge:drawSolidRect(cc.p(20, display.cy + 220), cc.p(display.width - 20, display.cy + 235), cc.c4f(1, 1, 1, 1))
    gauge:drawSolidRect(cc.p(22, display.cy + 222), cc.p(display.width - 22, display.cy + 233), cc.c4f(1, 0, 0, 1))
    local console = cc.DrawNode:create():addTo(self.enemy)
    console:drawSolidRect(cc.p(10, 60), cc.p(display.width - 10, 160), cc.c4f(1, 1, 1, 1))
    console:drawSolidRect(cc.p(15, 65), cc.p(display.width - 15, 155), cc.c4f(0, 0, 0, 1))
    self.message = cc.Label:createWithSystemFont("@SakeRiceがあらわれた", "", 14):align(cc.p(0, 1), 25, 150):addTo(self.enemy)
    self.attackBtn = cc.Menu:create(cc.MenuItemImage:create("attack.png", "attack.png"):onClicked(function()
        self.attackBtn:hide()
        local dmg = ctx.random(3, 7)
        self.message:setString("@SakeRiceに" .. dmg .. "ダメージ")
        local speed = 30
        local maxHp = 10
        local hp = 10
        gauge:onUpdate(function(dt)
            hp = hp - speed * dt
            hp = math.max(maxHp - dmg, hp)
            gauge:clear()
            gauge:drawSolidRect(cc.p(20, display.cy + 220), cc.p(display.width - 20, display.cy + 235), cc.c4f(1, 1, 1, 1))
            gauge:drawSolidRect(cc.p(22, display.cy + 222), cc.p(display.width - 22, display.cy + 233), cc.c4f(0, 0, 0, 1))
            gauge:drawSolidRect(cc.p(22, display.cy + 222), cc.p((display.width - 22 - 22) * hp / maxHp + 22, display.cy + 233), cc.c4f(1, 0, 0, 1))
            if hp <= maxHp - dmg then
                gauge:onUpdate(function()end)
                touchLayer:onTouch(function()
                end)
            end
        end)
    end)):move(display.cx, 40):addTo(self.enemy)

    self.miniMap = cc.DrawNode:create():addTo(self)
    self:drawMiniMap()

    self.prevTouch = nil
    self.touchLayer = display.newLayer():addTo(self):onTouch(us.bind(self.onTouch, self))
end

function MainScene:drawMiniMap()
    self.miniMap:clear()
    local len = 9
    local idx2pos = function(idx) return idx.j * len * 2, display.height - idx.i * len * 2 end
    for i = 1, ROW do
        for j = 1, COL do
            local x, y = idx2pos({i = i, j = j})
            self.miniMap:drawSolidRect(cc.p(x, y - len), cc.p(x + len, y), cc.c4f(0, 0, 0, 1))
        end
    end
    local curX, curY = idx2pos(self.curPos)
    self.miniMap:drawPoint(cc.p(curX + len / 2, curY - len / 2), len / 2, cc.c4f(1, 0, 0, 1))
end

function MainScene:flickEffect()
    local effect = display.newSprite("bg.jpg"):move(display.center):addTo(self)
    local prevScale = display.height / effect:getContentSize().height
    effect:setScale(prevScale)
    local dt = 0.3
    effect:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.FadeOut:create(dt),
            cc.ScaleTo:create(dt, prevScale * 2)
        ),
        cc.RemoveSelf:create()
    ))
end

function MainScene:onTouch(e)
    local thre = 10
    if e.name == "began" then
        self.prevTouch = e
        return true
    elseif e.name == "moved" and self.prevTouch then
        local dir = nil
        if self.prevTouch.y - e.y > thre then
            if self.curPos.i > 1 then
                dir = {i = -1, j = 0}
            else
                -- invalid up effect
            end
        elseif self.prevTouch.x - e.x > thre then
            if self.curPos.j < COL then
                dir = {i = 0, j = 1}
            else
                -- invalid right effect
            end
        elseif e.y - self.prevTouch.y > thre then
            if self.curPos.i < ROW then
                dir = {i = 1, j = 0}
            else
                -- invalid down effect
            end
        elseif e.x - self.prevTouch.x > thre then
            if self.curPos.j > 1 then
                dir = {i = 0, j = -1}
            else
                -- invalid left effect
            end
        end
        if dir then
            self.curPos.i = self.curPos.i + dir.i
            self.curPos.j = self.curPos.j + dir.j
            self.prevTouch = nil
            if us.isEqual(self.curPos, self.enemyPos) then
                self.touchLayer:removeTouch()
                self.miniMap:clear()
                self.enemy:show()
            else
                self:drawMiniMap()
                self.enemy:hide()
            end
        end
    end
end

return MainScene

