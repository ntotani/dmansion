local us = require("app.lib.moses")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local TILE_SIZE = 48
local ROOM_SIZE = 5
local FLOOR_TILES = us.map(us.range(1, ROOM_SIZE * 3), function(i)
    return us.map(us.range(1, ROOM_SIZE * 3), function() return 0 end)
end)
us.each({0, 1}, function(_, i)
    us.each({0, 1}, function(_, j)
        us.each(us.range(1, ROOM_SIZE), function(k)
            us.each(us.range(1, ROOM_SIZE), function(l)
                FLOOR_TILES[i * ROOM_SIZE * 2 + k][j * ROOM_SIZE * 2 + l] = 8 * 19
            end)
            local a = ROOM_SIZE + k
            local b = math.ceil(ROOM_SIZE / 2) + j * ROOM_SIZE * 2
            if i == 0 then
                FLOOR_TILES[a][b] = 8 * 19
            else
                FLOOR_TILES[b][a] = 8 * 19
            end
        end)
    end)
end)

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
            if e > 0 then
                display.newSprite(frames[e + 1]):move(size * (j - 0.5), size * (#idx - i + 0.5)):addTo(layer)
            end
        end)
    end)
    return layer
end

local function pix2idx(x, y)
    if type(x) == "table" then
        y = x.y
        x = x.x
    end
    local i = math.floor(y / TILE_SIZE)
    local j = math.floor(x / TILE_SIZE)
    return {i = #FLOOR_TILES - i - 1, j = j}
end

local function idx2pix(i, j)
    if type(i) == "table" then
        j = i.j
        i = i.i
    end
    return {x = (j + 0.5) * TILE_SIZE, y = (#FLOOR_TILES - i - 0.5) * TILE_SIZE}
end

local function calcPath(from, to)
    local memo = us(FLOOR_TILES):map(function(i, line)
        return us(line):map(function(j, e)
            return {dist = #FLOOR_TILES * #FLOOR_TILES[1], dir = nil}
        end):value()
    end):value()
    memo[from.i + 1][from.j + 1].dist = 0
    local queue = { from }
    local dirs = {{-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, -1}}
    while #queue > 0 do
        local cur = table.remove(queue, 1)
        if cur.i == to.i and cur.j == to.j then
            break
        end
        us(dirs):map(function(_, e)
            local dist = math.abs(e[1]) + math.abs(e[2]) > 1 and 1.1 or 1
            return {i = cur.i + e[1], j = cur.j + e[2], dist = dist}
        end):filter(function(_, e)
            return e.i >= 0 and e.i < #FLOOR_TILES and e.j >= 0 and e.j < #FLOOR_TILES[1]
        end):filter(function(_, e)
            return FLOOR_TILES[e.i + 1][e.j + 1] > 0
        end):each(function(_, e)
            if memo[e.i + 1][e.j + 1].dist > memo[cur.i + 1][cur.j + 1].dist + e.dist then
                memo[e.i + 1][e.j + 1].dist = memo[cur.i + 1][cur.j + 1].dist + e.dist
                memo[e.i + 1][e.j + 1].dir = cur
                queue[#queue + 1] = {i = e.i, j = e.j}
            end
        end)
    end
    local path = {to}
    while memo[path[#path].i + 1][path[#path].j + 1].dir do
        path[#path + 1] = memo[path[#path].i + 1][path[#path].j + 1].dir
    end
    return us.reverse(path)
end

function MainScene:onCreate()
    local tileData = {}
    for _, line in ipairs(FLOOR_TILES) do
        for _ = 1, 3 do
            local lineData = {}
            for _, e in ipairs(line) do
                for _ = 1, 3 do
                    lineData[#lineData + 1] = e
                end
            end
            tileData[#tileData + 1] = lineData
        end
    end
    local mapLayer = map("tile.png", 16, tileData):addTo(self)
    display.newSprite(getFrames("move_obj4.png", 16)[7]):move(idx2pix(2, 2)):addTo(mapLayer)
    local boyFrames = getFrames("hero.png", 96)
    local boy = display.newSprite(boyFrames[1]):move(idx2pix(12, 2)):addTo(mapLayer)
    boy:setScale(0.5)
    boy:playAnimationForever(display.newAnimation({boyFrames[1], boyFrames[2], boyFrames[3], boyFrames[2]}, 0.25))
    boy.hp = 10
 
    local bear = display.newSprite("bear.png"):addTo(mapLayer)
    bear.pos = {i = 10, j = 2}
    local bearPos = idx2pix(bear.pos)
    bear:move(bearPos.x, bearPos.y + 24)
    bear.hp = 10
    local souls = getFrames("soul.png", 96)

    local lvGauge = cc.Label:createWithSystemFont("Lv: 1", "PixelMplus12", 24):align(cc.p(0, 1), 10, display.height):addTo(self)
    local hpGauge = cc.Label:createWithSystemFont("HP: 10", "PixelMplus12", 24):align(cc.p(1, 1), display.width - 10, display.height):addTo(self)
    local draw = cc.DrawNode:create():addTo(self):hide()
    draw:drawSolidRect(cc.p(17, 517), cc.p(343, 603), cc.c4f(1, 1, 1, 1))
    draw:drawSolidRect(cc.p(20, 520), cc.p(340, 600), cc.c4f(0, 0, 0, 1))
    local mes = cc.Label:createWithSystemFont("うわああああああああ", "PixelMplus12", 24):move(display.cx, 560):addTo(self):hide()
    display.newLayer():addTo(self):onTouch(function(e)
        local idx = pix2idx(cc.pSub(e, cc.p(mapLayer:getPosition())))
        if idx.i < 0 or idx.i >= #FLOOR_TILES or idx.j < 0 or idx.j >= #FLOOR_TILES[1] or FLOOR_TILES[idx.i + 1][idx.j + 1] <= 0 then
            return
        end
        draw:hide()
        mes:hide()
        local path = calcPath(pix2idx(cc.p(boy:getPosition())), idx)
        local acts = {}
        for _, e in ipairs(path) do
            if not bear or e.i ~= bear.pos.i or e.j ~= bear.pos.j then
                acts[#acts + 1] = cc.MoveTo:create(0.2, idx2pix(e))
            else
                acts[#acts + 1] = cc.CallFunc:create(function()
                    local dmg = math.floor(math.random() * 1)
                    bear.hp = bear.hp - dmg
                    mes:setString("クマに" .. dmg .. "ダメージ")
                    draw:show()
                    mes:show()
                    if bear.hp <= 0 then
                        bear:removeSelf()
                        bear = nil
                    end
                end)
                acts[#acts + 1] = cc.DelayTime:create(0.5)
                acts[#acts + 1] = cc.CallFunc:create(function()
                    if bear and bear.hp > 0 then
                        local dmg = math.floor(math.random() * 10)
                        boy.hp = boy.hp - dmg
                        hpGauge:setString("HP: " .. boy.hp)
                        mes:setString("@blankblankに" .. dmg .. "ダメージ")
                        if boy.hp <= 0 then
                            boy:hide()
                            local soul = display.newSprite(souls[1]):move(boy:getPosition()):addTo(mapLayer)
                            soul:playAnimationForever(display.newAnimation({souls[1], souls[2], souls[3]}, 0.25))
                            soul:setScale(0.5)
                        end
                    end
                end)
                break
            end
        end
        boy:runAction(cc.Sequence:create(acts))
    end)
    self:onUpdate(function(dt)
        mapLayer:move(display.cx - boy:getPositionX(), display.cy - boy:getPositionY())
    end)
end

return MainScene

