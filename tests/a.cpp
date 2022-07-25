

#include "lua.hpp"

#include <iostream>
#include <filesystem>
#include <fstream>
#include <string>

namespace fs = std::filesystem;

__declspec(dllimport) int l_saveToFile(lua_State *L);

void writeToFile(std::string path, std::string content){
  fs::path p(path);
  fs::create_directories(p.parent_path());
  std::ofstream(p) << content;

  
}

/*
copied from
https://www.lua.org/manual/5.4/manual.html#lua_Alloc
*/
static void *l_alloc(
    void *ud, void *ptr,
    size_t osize, size_t nsize
){
  (void)ud;  (void)osize;  /* not used */
  if (nsize == 0) {
    free(ptr);
    return NULL;
  } else{
    return realloc(ptr, nsize);
  }
}

#include <windows.h>
#include <direct.h>
#include <string.h>
#include <stdio.h>


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
    printf("parent_path: %s\n", parent_path);
  }


  free(parent_path);
}
void main(){
  char *a = "charms_export_lib.dll";
  createParentFolder(a);
}

void main1(){
  writeToFile("C:\\Users/User/Desktop/bc/def/a.txt", "abcdef");

  // void *ud = NULL;
  // lua_State *L = lua_newstate(l_alloc, ud);
}