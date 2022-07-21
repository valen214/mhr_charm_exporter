

#ifdef __cplusplus
  #include "lua.hpp"
#else
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
#endif

#include <iostream>
#include <filesystem>
#include <fstream>
#include <string>

namespace fs = std::filesystem;
using namespace std;

__declspec(dllimport) int l_saveToFile(lua_State *L);

void writeToFile(string path, string content){
  fs::path p(path);
  fs::create_directories(p.parent_path());
  ofstream(p) << content;

  
}


void main(){
  writeToFile("C:\\Users/User/Desktop/bc/def/a.txt", "abcdef");
}