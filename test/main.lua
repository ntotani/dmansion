local luaunit = require("test.lib.luaunit")

function testSample()
    local scene = cc.Scene:create()
    display.runScene(scene)
    cc.Director:getInstance():mainLoop() -- run scene

    local node = cc.Node:create()
    scene:addChild(node)
    node:runAction(cc.MoveTo:create(5, cc.p(10, 0)))
    cc.Director:getInstance():mainLoop() -- first tick

    setDeltaTime(5)
    cc.Director:getInstance():mainLoop() -- animation
    luaunit.assertEquals(node:getPositionX(), 10)
end

TestMainScene = {
    setUp = function(self)
        local randSeq = {2, 2, 2, 3}
        self.target = require("app.views.MainScene"):create(nil, "MainScene", {
            random = function()
                table.insert(randSeq, table.remove(randSeq, 1))
                return randSeq[#randSeq]
            end
        })
        self.target:showWithScene()
        cc.Director:getInstance():mainLoop() -- run scene
    end,
    testExist = function(self)
        luaunit.assertFalse(tolua.isnull(self.target))
    end,
    testFlickUp = function(self)
        self:flick(100, 100, 100, 50)
        luaunit.assertEquals(self.target.curPos.i, 1)
        self:flick(100, 100, 100, 50)
        luaunit.assertEquals(self.target.curPos.i, 1)
    end,
    testFlickRight = function(self)
        self:flick(100, 100, 50, 100)
        luaunit.assertEquals(self.target.curPos.j, 3)
        self:flick(100, 100, 50, 100)
        luaunit.assertEquals(self.target.curPos.j, 3)
    end,
    testFlickDown = function(self)
        self.target.curPos.i = 4
        self:flick(100, 100, 100, 150)
        luaunit.assertEquals(self.target.curPos.i, 5)
        self:flick(100, 100, 100, 150)
        luaunit.assertEquals(self.target.curPos.i, 5)
    end,
    testFlickLeft = function(self)
        self:flick(100, 100, 150, 100)
        luaunit.assertEquals(self.target.curPos.j, 1)
        self:flick(100, 100, 150, 100)
        luaunit.assertEquals(self.target.curPos.j, 1)
    end,
    flick = function(self, sx, sy, dx, dy)
        touchBegin(0, sx, sy)
        touchMove(0, dx, dy)
        touchEnd(0, dx, dy)
    end,
    testEnemy = function(self)
        luaunit.assertFalse(self.target.enemy:isVisible())
        self:flick(100, 100, 50, 100)
        luaunit.assertTrue(self.target.enemy:isVisible())
        self:flick(100, 100, 150, 100)
        luaunit.assertEquals(self.target.curPos.j, 3)
    end,
}

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

os.exit(luaunit.LuaUnit.run('-v'))

