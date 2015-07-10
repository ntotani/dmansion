local us = require("app.lib.moses")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local ROW = 5
local COL = 3

function MainScene:onCreate()
    local bg = display.newSprite("bg.jpg"):move(display.center):addTo(self)
    bg:setScale(display.height / bg:getContentSize().height)
    local curPos = {
        i = math.ceil(math.random() * ROW),
        j = math.ceil(math.random() * COL)
    }
    local prevTouch = nil
    local thre = 10
    display.newLayer():addTo(self):onTouch(function(e)
        if e.name == "began" then
            prevTouch = e
            return true
        elseif e.name == "moved" and prevTouch then
            if prevTouch.y - e.y > thre then
                if curPos.i > 1 then
                    curPos.i = curPos.i - 1
                    prevTouch = nil
                    dump(curPos)
                else
                    -- invalid up effect
                end
            elseif prevTouch.x - e.x > thre then
                if curPos.j < COL then
                    curPos.j = curPos.j + 1
                    prevTouch = nil
                    dump(curPos)
                else
                    -- invalid right effect
                end
            elseif e.y - prevTouch.y > thre then
                if curPos.i < ROW then
                    curPos.i = curPos.i + 1
                    prevTouch = nil
                    dump(curPos)
                else
                    -- invalid down effect
                end
            elseif e.x - prevTouch.x > thre then
                if curPos.j > 1 then
                    curPos.j = curPos.j - 1
                    prevTouch = nil
                    dump(curPos)
                else
                    -- invalid left effect
                end
            end
        end
    end)
    self:onUpdate(function(dt)
    end)
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

