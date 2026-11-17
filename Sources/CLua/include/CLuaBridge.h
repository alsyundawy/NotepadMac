//
//  CLuaBridge.h
//  NotepadMac
//
//  Swift-friendly C bridge helpers for Lua function-like macros
//

#ifndef CLuaBridge_h
#define CLuaBridge_h

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#ifdef __cplusplus
extern "C" {
#endif

static inline void lua_open_all_libs(lua_State * _Nonnull L) {
    luaL_openselectedlibs(L, ~0, 0);
}

static inline int32_t lua_registry_index(void) {
    return LUA_REGISTRYINDEX;
}

static inline int32_t lua_upvalue_index(int i) {
    return lua_upvalueindex(i);
}

static inline const char * _Nullable lua_to_string(lua_State * _Nonnull L, int idx) {
    return lua_tolstring(L, idx, NULL);
}

static inline lua_Integer lua_to_integer(lua_State * _Nonnull L, int idx) {
    return lua_tointegerx(L, idx, NULL);
}

static inline void lua_pop_stack(lua_State * _Nonnull L, int n) {
    lua_settop(L, -(n) - 1);
}

static inline int lua_do_string(lua_State * _Nonnull L, const char * _Nonnull s) {
    return (luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0));
}

static inline int lua_is_boolean(lua_State * _Nonnull L, int idx) {
    return (lua_type(L, idx) == LUA_TBOOLEAN);
}

static inline int lua_is_nil(lua_State * _Nonnull L, int idx) {
    return (lua_type(L, idx) == LUA_TNIL);
}

static inline int lua_is_noneornil(lua_State * _Nonnull L, int idx) {
    return (lua_type(L, idx) <= 0);
}

#ifdef __cplusplus
}
#endif

#endif /* CLuaBridge_h */
