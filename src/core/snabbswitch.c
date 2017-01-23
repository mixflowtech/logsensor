/* Use of this source code is governed by the Apache 2.0 license; see COPYING. */

#include <stdio.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
// #include "luv_pub.h"
#include <stdint.h>

#if UINTPTR_MAX != UINT64_MAX
#error "64-bit word size required. See doc/porting.md."
#endif

int argc;
char** argv;

/*
static int l_bar( lua_State *L )
{
   puts("l_bar called.");
   return 0;
}

void luaopen_foo( lua_State *L )
{
   static const struct luaL_Reg foo[] = {
      { "bar", l_bar },
      { NULL, NULL }
   };
   luaL_newlib( L, foo );   // create table containing `bar`
   lua_setglobal(L, "foo"); // assign that table to global `foo`
}
*/

int main(int snabb_argc, char **snabb_argv)
{
  int n = 0;
  /* Store for use by LuaJIT code via FFI. */
  argc = snabb_argc;
  argv = snabb_argv;
  lua_State* L = luaL_newstate();
  luaL_openlibs(L);
  // FIXME: make libuv static linked?
  // n = luaopen_luv(L);
  // luaopen_foo(L);
  // printf("load %d ===", n);
  n = luaL_dostring(L, "require \"core.startup\"");
  if(n) {
     printf("%s\n", lua_tostring(L, -1));
  }
  return n;
}

