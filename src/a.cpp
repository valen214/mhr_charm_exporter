

#ifdef __cplusplus
  #include "lua.hpp"
#else
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
#endif

__declspec(dllimport) int l_saveToFile(lua_State *L);

void main(){
  FILE *fptr = fopen("D:\\temp.txt", "w");
  if(fptr == NULL) return;

  fprintf(fptr, "Hello World");
  fclose(fptr);
}