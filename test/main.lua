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
        self.target = require("app.views.MainScene"):create(nil, "MainScene", {random = function() return 1 end})
        self.target:showWithScene()
        cc.Director:getInstance():mainLoop() -- run scene
    end,
    testExist = function(self)
        luaunit.assertFalse(tolua.isnull(self.target))
    end,
    testFlickDown = function(self)
        touchBegin(0, 100, 100)
        touchMove(0, 100, 150)
        luaunit.assertEquals(self.target.curPos.i, 2)
    end,
}

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

os.exit(luaunit.LuaUnit.run('-v'))

