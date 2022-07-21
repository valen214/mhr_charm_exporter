
#include <iostream>
#include <filesystem>
#include <fstream>
#include <string>

namespace fs = std::filesystem;
using namespace std;

#include "lua.hpp"


#if (defined(_WIN32) || defined(__WIN32__) || defined(WIN32)) && \
  !defined(__SYMBIAN32__)

// #pragma comment(lib, "libcurl.lib") 
// #pragma comment(lib, "lua54.lib") 

// #include <windows.h>
// 
// #define mkdir(dir, mode) _mkdir(dir)

#else

// #pragma comment(lib, "libcurl.a")

#endif


void writeToFile(string path, string content){
  fs::path p(path);
  fs::create_directories(p.parent_path());
  ofstream(p) << content;
}


__declspec(dllexport) int l_saveToFile(lua_State *L){
  const char *file_path = luaL_checkstring(L, 1);
  const char *content = luaL_checkstring(L, 2);

  writeToFile(file_path, content);

  return 0;
}

static const struct luaL_Reg exporter [] = {
  { "saveToFile", l_saveToFile },
  { NULL, NULL }
};

__declspec(dllexport) int luaopen_exporter(lua_State *L){
  luaL_newlib(L, exporter);

  lua_register(L, "saveToFile", l_saveToFile);

  return 1;
}