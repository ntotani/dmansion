#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string>

USING_NS_CC;

VirtualDirector* vd = nullptr;

int set_delta_time_glue(lua_State* L)
{
    vd->setDeltaTime(lua_tonumber(L, 1));
    return 0;
}

class AppDelegate : private Application {
    virtual bool applicationDidFinishLaunching() {
        vd = VirtualDirector::create();
        auto engine = LuaEngine::getInstance();
        ScriptEngineManager::getInstance()->setScriptEngine(engine);
        lua_State* L = engine->getLuaStack()->getLuaState();
        lua_module_register(L);
        lua_getglobal(L, "_G");
        lua_register(L, "setDeltaTime", set_delta_time_glue);
        if (engine->executeScriptFile("test/main.lua"))
        {
            return false;
        }
        return true;
    };
    virtual void applicationDidEnterBackground() {};
    virtual void applicationWillEnterForeground() {};
};

int main(int argc, char **argv)
{
    // create the application instance
    AppDelegate app;
    FileUtils::getInstance()->setDefaultResourceRootPath(argv[1]);
    FileUtils::getInstance()->addSearchPath(argv[1]);
    return Application::getInstance()->run();
}

