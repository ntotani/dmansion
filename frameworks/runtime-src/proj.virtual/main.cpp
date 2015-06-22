#include "cocos2d.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string>

USING_NS_CC;

class AppDelegate : private Application {
    virtual bool applicationDidFinishLaunching() { return true; };
    virtual void applicationDidEnterBackground() {};
    virtual void applicationWillEnterForeground() {};
};

int main(int argc, char **argv)
{
    // create the application instance
    AppDelegate app;
    return Application::getInstance()->run();
}
