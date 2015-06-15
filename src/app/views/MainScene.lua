local us = require("app.lib.moses")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local function getFrames(name, size)
    local texture = display.loadImage(name)
    local wid = texture:getPixelsWide()
    local hei = texture:getPixelsHigh()
    local frames = {}
    for i = 0, (wid * hei) / (size * size) - 1 do
        local sf = display.newSpriteFrame(texture, cc.rect((i % (wid / size)) * size, math.floor(i / (wid / size)) * size, size, size))
        cc.SpriteFrameCache:getInstance():addSpriteFrame(sf, name .. i)
        frames[#frames + 1] = sf
    end
    return frames
end

local function map(name, size, idx)
    local frames = getFrames(name, size)
    local layer = display.newLayer()
    us(idx):each(function(i, line)
        us(line):each(function(j, e)
            display.newSprite(frames[e + 1]):move(size * (j - 0.5), size * (#idx - i + 0.5)):addTo(layer)
        end)
    end)
    return layer
end

local function pix2idx(x, y)
    if type(x) == "table" then
        y = x.y
        x = x.x
    end
    local i = math.floor(y / 32)
    local j = math.floor(x / 32)
    return {i = i, j = j}
end

local function idx2pix(i, j)
    if type(i) == "table" then
        j = i.j
        i = i.i
    end
    return {x = j * 32 + 16, y = i * 32 + 16}
end

function MainScene:onCreate()
    local row = 20
    local col = 11
    map("tile.png", 16, us.map(us.range(row * 2), function(i)
        return us.map(us.range(col * 2), function()
            return 8 * 19
        end)
    end)):addTo(self)
    display.newSprite(getFrames("move_obj4.png", 16)[7]):move(idx2pix(8, 3)):addTo(self)
    local boyFrames = getFrames("hero.png", 96)
    local boy = display.newSprite(boyFrames[1]):move(idx2pix(10, 5)):addTo(self)
    boy:playAnimationForever(display.newAnimation({boyFrames[1], boyFrames[2], boyFrames[3], boyFrames[2]}, 0.25))
    
    local draw = cc.DrawNode:create():addTo(self):hide()
    draw:drawSolidRect(cc.p(20, 520), cc.p(340, 600), cc.c4f(0, 0, 0, 1))
    local mes = cc.Label:createWithSystemFont("うわああああああああ", "PixelMplus12", 24):move(display.cx, 560):addTo(self):hide()
    display.newLayer():addTo(self):onTouch(function(e)
        local idx = pix2idx(e)
        if idx.i == 8 and idx.j == 3 then
            draw:show()
            mes:show()
            return
        end
        draw:hide()
        mes:hide()
        local pix = idx2pix(idx)
        boy:moveTo({time = 0.5, x = pix.x, y = pix.y})
    end)
end

return MainScene

