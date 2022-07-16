#ifdef __cplusplus
  #include "lua.hpp"
#else
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
#endif

#include <stdio.h>
#include <stdlib.h>


#ifdef __cplusplus
extern "C"{
#endif


#if (defined(_WIN32) || defined(__WIN32__) || defined(WIN32)) && \
  !defined(__SYMBIAN32__)

// #pragma comment(lib, "libcurl.lib") 
// #pragma comment(lib, "lua54.lib") 

#else

#pragma comment(lib, "libcurl.a")

#endif


__declspec(dllexport) int l_saveToFile(lua_State *L){
  const char *file_path = luaL_checkstring(L, 1);
  const char *content = luaL_checkstring(L, 2);

  FILE *fptr = fopen(file_path, "w");
  if(fptr == NULL) return 1;

  fprintf(fptr, content);
  fclose(fptr);

  return 0;
}

static const struct luaL_Reg exporter [] = {
  {"saveToFile", l_saveToFile},
  {NULL, NULL}
};

__declspec(dllexport) int luaopen_exporter(lua_State *L){

  luaL_newlib(L, exporter);

  lua_register(L, "saveToFile", l_saveToFile);

  return 1;
}


#ifdef __cplusplus
}
#endif