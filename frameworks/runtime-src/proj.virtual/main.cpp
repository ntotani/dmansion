#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string>

USING_NS_CC;

class AppDelegate : private Application {
    virtual bool applicationDidFinishLaunching() {
        auto engine = LuaEngine::getInstance();
        ScriptEngineManager::getInstance()->setScriptEngine(engine);
        lua_State* L = engine->getLuaStack()->getLuaState();
        lua_module_register(L);
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
    FileUtils::getInstance()->addSearchPath(argv[1]);
    return Application::getInstance()->run();
}

