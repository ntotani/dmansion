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
    self.enemy = display.newSprite("enemy.png"):move(display.center):hide():addTo(self)
    self.miniMap = cc.DrawNode:create():addTo(self)
    self:drawMiniMap()

    local prevTouch = nil
    local thre = 10
    display.newLayer():addTo(self):onTouch(function(e)
        if e.name == "began" then
            prevTouch = e
            return true
        elseif e.name == "moved" and prevTouch then
            local dir = nil
            if prevTouch.y - e.y > thre then
                if self.curPos.i > 1 then
                    dir = {i = -1, j = 0}
                else
                    -- invalid up effect
                end
            elseif prevTouch.x - e.x > thre then
                if self.curPos.j < COL then
                    dir = {i = 0, j = 1}
                else
                    -- invalid right effect
                end
            elseif e.y - prevTouch.y > thre then
                if self.curPos.i < ROW then
                    dir = {i = 1, j = 0}
                else
                    -- invalid down effect
                end
            elseif e.x - prevTouch.x > thre then
                if self.curPos.j > 1 then
                    dir = {i = 0, j = -1}
                else
                    -- invalid left effect
                end
            end
            if dir then
                self.curPos.i = self.curPos.i + dir.i
                self.curPos.j = self.curPos.j + dir.j
                prevTouch = nil
                self:drawMiniMap()
                if us.isEqual(self.curPos, self.enemyPos) then
                    self.enemy:show()
                else
                    self.enemy:hide()
                end
            end
        end
    end)
    self:onUpdate(function(dt)
    end)
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

return MainScene

