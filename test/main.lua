
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

local function main()
    local scene = cc.Scene:create()
    cc.Director:getInstance():runWithScene(scene)
    cc.Director:getInstance():mainLoop() -- run scene

    local node = cc.Node:create()
    scene:addChild(node)
    node:runAction(cc.MoveTo:create(5, cc.p(10, 0)))
    cc.Director:getInstance():mainLoop() -- first tick

    setDeltaTime(5)
    cc.Director:getInstance():mainLoop() -- animation
    assert(node:getPositionX() == 10, "node should move right")

    local ms = require("app.views.MainScene"):create(nil, "MainScene", {random = function() return 1 end})
    ms:showWithScene()
    cc.Director:getInstance():mainLoop() -- run scene
    assert(not tolua.isnull(ms))
    touchBegin(0, 100, 100)
    touchMove(0, 100, 150)
    assert(ms.curPos.i == 2, "flick down")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

