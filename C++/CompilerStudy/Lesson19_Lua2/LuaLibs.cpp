
#include "pch.h"
#include "LuaLibs.h"
#include "ByteCode.h"

void runfile(int argc, char *argv[]) {
    LuaVM::create();

    openLib_buildin();

    auto func = loadFile("test.lua");
    {
        ofstream fo("disassembly.txt");
        disassemble(fo, static_cast<LuaFunction*>(func.getFunction())->meta.get());
    }
    vector<LuaValue> args, rets;
    callFunc(func, args, rets);

    LuaVM::destroy();
}
