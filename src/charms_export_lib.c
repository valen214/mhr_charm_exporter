

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <stdio.h>
#include <string.h>

#ifdef __cplusplus

#include <filesystem>
#include <fstream>

void writeToFile(std::string path, std::string content){
  fs::path p(path);
  fs::create_directories(p.parent_path());
  std::ofstream(p) << content;

}

#endif

#if (defined(_WIN32) || defined(__WIN32__) || defined(WIN32)) && \
  !defined(__SYMBIAN32__)

// #pragma comment(lib, "libcurl.lib") 
// #pragma comment(lib, "lua54.lib") 

#include <windows.h> // _mkdir
#define mkdir(dir, mode) _mkdir(dir)

void createParentFolder(const char *path){
  char *parent_path = (char*)malloc(sizeof(char) * (strlen(path) + 5));

  const char *pch1 = strrchr(path, '/');
  const char *pch2 = strchr(path, '\\');

  const char *pch = NULL;

  if(pch1 != NULL && pch2 != NULL){
    pch = pch1 > pch2 ? pch1 : pch2;
  } else if(pch1 != NULL){
    pch = pch1;
  } else if(pch2 != NULL){
    pch = pch2;
  }

  if(pch == NULL){

  } else{
    strncpy(parent_path, path, pch-path+1);
    parent_path[pch-path+1] = '\0';
    _mkdir(parent_path);
  }

  free(parent_path);
}

void writeToFile(const char *path, const char *content){
  createParentFolder(path);
  
  FILE *fptr = fopen(path, "w");
  if(fptr == NULL) return;

  fprintf(fptr, content);
  fclose(fptr);
}


#else

// #pragma comment(lib, "libcurl.a")

#endif

/*
https://developercommunity.visualstudio.com/t/
error-c2872-byte-ambiguous-symbol/93889
*/
__declspec(dllexport) int l_saveToFile(lua_State *L){
  const char *file_path = luaL_checkstring(L, 1);
  const char *content = luaL_checkstring(L, 2);

  writeToFile(file_path, content);

  return 0;
}

static const struct luaL_Reg charms_export_lib [] = {
  { "saveToFile", l_saveToFile },
  { NULL, NULL }
};

__declspec(dllexport) int luaopen_charms_export_lib(lua_State *L){
  luaL_newlib(L, charms_export_lib);

  lua_register(L, "saveToFile", l_saveToFile);

  lua_pushcfunction(L, l_saveToFile);

  return 1;
}