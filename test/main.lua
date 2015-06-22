
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

local function main()
    --require("app.MyApp"):create():run()
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
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

