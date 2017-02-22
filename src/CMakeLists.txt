set(CMAKE_LUA_OUTPUT_EXTENSION ".o")
set(CMAKE_LUA_OUTPUT_EXTENSION_REPLACE 1)

set(CMAKE_LUA_FLAGS " -bg")
# set(CMAKE_LUA_COMPILER ${CMAKE_BINARY_DIR}/lib/luajit/luajit CACHE FILEPATH "The LuaJIT compiler")

set(CMAKE_LUA_COMPILE_OBJECT  "<CMAKE_LUA_COMPILER> <FLAGS> <SOURCE> <OBJECT>")
set(CMAKE_LUA_SOURCE_FILE_EXTENSIONS lua;luah)

message("CMAKE_LUA_COMPILE_OBJECT is ${CMAKE_LUA_COMPILE_OBJECT}")


enable_language(LUA OPTIONAL)

include_directories(
    ${CMAKE_SOURCE_DIR}/lib/luajit/src/
    ${CMAKE_SOURCE_DIR}/lib/luv/src/
    ${CMAKE_SOURCE_DIR}/lib/luv/deps/libuv/include/
    ${CMAKE_SOURCE_DIR}/src/
    )

if(WIN32)
include_directories(
    ${CMAKE_SOURCE_DIR}/src/win
    )
ENDIF()

if(NOT WIN32)
set(CMAKE_C_FLAGS "-Wl,--no-as-needed -Wl,-E -Wall ${CMAKE_C_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lrt -lc -ldl -lm -lpthread ")
ENDIF()

# Lua C FFI Header

set(LUA_HEADERS
    core/lib.h
    core/link.h
    core/clib.h
    core/memory.h
    core/counter.h
    core/packet.h
    lib/ipc/shmem/shmem.h
    )

set(LUA_LUA_HEADERS_SRCS )

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/core)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/lib/io)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/lib/ipc)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/lib/ipc/shmem)

foreach(lua_head ${LUA_HEADERS})
if(WIN32)
    ADD_CUSTOM_COMMAND(
        OUTPUT ${CMAKE_BINARY_DIR}/src/${lua_head}.luah
        COMMAND echo "module\(...,package.seeall\); require\(\"ffi\"\).cdef[=============[" > "${CMAKE_BINARY_DIR}/src/${lua_head}.luah"
        COMMAND cat ${CMAKE_SOURCE_DIR}/src/${lua_head} >> ${CMAKE_BINARY_DIR}/src/${lua_head}.luah
        COMMAND echo "]=============]" >> "${CMAKE_BINARY_DIR}/src/${lua_head}.luah"
        DEPENDS ${CMAKE_SOURCE_DIR}/src/${lua_head}
    )
ELSE()
    ADD_CUSTOM_COMMAND(
        OUTPUT ${CMAKE_BINARY_DIR}/src/${lua_head}.luah
        COMMAND echo \"module\(...,package.seeall\); require\(\\\"ffi\\\"\).cdef[=============[\" > "${CMAKE_BINARY_DIR}/src/${lua_head}.luah"
        COMMAND cat ${CMAKE_SOURCE_DIR}/src/${lua_head} >> ${CMAKE_BINARY_DIR}/src/${lua_head}.luah
        COMMAND echo \"]=============]\" >> "${CMAKE_BINARY_DIR}/src/${lua_head}.luah"
        DEPENDS ${CMAKE_SOURCE_DIR}/src/${lua_head}
    )    
ENDIF()

    list(APPEND LUA_LUA_HEADERS_SRCS ${CMAKE_BINARY_DIR}/src/${lua_head}.luah)

    # update
    STRING(REPLACE "." "_" lua_source_module_name ${lua_head})
    STRING(REPLACE "/" "." lua_source_module_name ${lua_source_module_name})
    STRING(REGEX REPLACE "\\.luah$" "" lua_source_module_name ${lua_source_module_name})
    set_source_files_properties(${CMAKE_BINARY_DIR}/src/${lua_head}.luah
                                PROPERTIES COMPILE_FLAGS "-n ${lua_source_module_name}")
endforeach()

# message(${LUA_LUA_HEADERS_SRCS})

# Lua Module
set(LUA_SRCS
    core/app.lua
    core/config.lua
    core/counter.lua
    core/histogram.lua
    core/startup.lua
    core/main.lua
    core/shm.lua
    core/lib.lua
    core/link.lua
    core/memory.lua
    core/packet.lua
    core/timer.lua
    lib/ctable.lua
    lib/index_set.lua
    lib/json.lua
    lib/ipc/shmem/shmem.lua
    lib/lua/alt_getopt.lua
    lib/lua/class.lua
    lib/lua/StackTracePlus.lua
    lib/lua/strict.lua
    )


IF(WIN32)
  set(JIT_SOURCE_PATH ${CMAKE_SOURCE_DIR}/lib/luajit/src/ )  
  # FIXME: add all the other jit related code.
  set(JIT_SRCS
    ${JIT_SOURCE_PATH}jit/zone.lua
    )

ENDIF()

if(NOT WIN32)
  set(LUA_SRCS
    ${LUA_SRCS}   
    jit/zone.lua
    )

  set(LUA_SRCS
    ${LUA_SRCS}     
    syscall/shared/types.lua
    syscall.lua
    syscall/abi.lua
    syscall/bit.lua
    syscall/compat.lua
    syscall/ffitypes.lua
    syscall/helpers.lua
    syscall/lfs.lua
    syscall/libc.lua
    syscall/methods.lua
    syscall/syscalls.lua
    syscall/types.lua
    syscall/util.lua
    syscall/linux/c.lua
    syscall/linux/cgroup.lua
    syscall/linux/constants.lua
    syscall/linux/errors.lua
    syscall/linux/fcntl.lua
    syscall/linux/ffi.lua
    syscall/linux/ioctl.lua
    syscall/linux/netfilter.lua
    syscall/linux/nl.lua
    syscall/linux/nr.lua
    syscall/linux/sockopt.lua
    syscall/linux/syscalls.lua
    syscall/linux/types.lua
    syscall/linux/util.lua
    syscall/linux/x64/constants.lua
    syscall/linux/x64/ffi.lua
    syscall/linux/x64/ioctl.lua
    syscall/linux/x64/nr.lua
    )
ENDIF()

foreach(lua_source ${LUA_SRCS})
    STRING(REPLACE "/" "." lua_source_module_name ${lua_source})
    STRING(REGEX REPLACE "\\.lua$" "" lua_source_module_name ${lua_source_module_name})
    # MESSAGE( STATUS "Including dir " ${lua_source} ${lua_source_module_name} )
    SET_SOURCE_FILES_PROPERTIES(${lua_source} PROPERTIES LANGUAGE LUA )
    # SET_SOURCE_FILES_PROPERTIES(${lua_source} PROPERTIES OUTPUT_NAME "${lua_source}.o" )
    set_source_files_properties(${lua_source}
                                PROPERTIES COMPILE_FLAGS "-n ${lua_source_module_name}")
endforeach()

foreach(lua_source ${JIT_SRCS})
    STRING(REPLACE ${JIT_SOURCE_PATH} "" lua_source_module_name ${lua_source})
    STRING(REPLACE "/" "." lua_source_module_name ${lua_source_module_name})
    STRING(REGEX REPLACE "\\.lua$" "" lua_source_module_name ${lua_source_module_name})
    # MESSAGE( STATUS "Including dir " ${lua_source} ${lua_source_module_name} )
    SET_SOURCE_FILES_PROPERTIES(${lua_source} PROPERTIES LANGUAGE LUA )
    # SET_SOURCE_FILES_PROPERTIES(${lua_source} PROPERTIES OUTPUT_NAME "${lua_source}.o" )
    set_source_files_properties(${lua_source}
                                PROPERTIES COMPILE_FLAGS "-n ${lua_source_module_name}")
endforeach()

# C code
set(C_SRCS
    )

if(NOT WIN32)
  set(C_SRCS
    ${C_SRCS}
    arch/avx2.c
    arch/sse2.c   
    core/lib.c
    core/memory.c
    lib/checksum.c
    lib/ipc/shmem/shmem.c
    )    
set_source_files_properties(arch/avx2.c
                                PROPERTIES COMPILE_FLAGS " -O2 -mavx2 ")
set_source_files_properties(arch/sse2.c
                                PROPERTIES COMPILE_FLAGS " -O2 -msse2 ")

ENDIF()

add_executable (snabb core/snabbswitch.c ${C_SRCS} ${LUA_LUA_HEADERS_SRCS} ${LUA_SRCS} ${JIT_SRCS} )
# Link the executable to the Hello library. Since the Hello library has
# public include directories we will use those link directories when building
# helloDemo

if(WIN32)
# add_custom_target(copy_luajit_jit)
file(COPY ${CMAKE_SOURCE_DIR}/lib/luajit/src/jit DESTINATION ${CMAKE_BINARY_DIR}/lib/luajit/lua ) 

#add_custom_command(TARGET copy_luajit_jit PRE_BUILD
#                   COMMAND ${CMAKE_COMMAND} -E
#                   copy ${CMAKE_SOURCE_DIR}/lib/ljsyscall/syscall.lua   ${CMAKE_SOURCE_DIR}/src/ )

# add_dependencies(snabb copy_luajit_jit)
ENDIF()

if(NOT WIN32)
add_dependencies(snabb copy_ljsyscall)
ENDIF()

add_dependencies(snabb luajit luv )
if(WIN32)
target_link_libraries(snabb ${CMAKE_BINARY_DIR}/lib/luajit/luajit-static.lib)
ELSE()
target_link_libraries(snabb ${CMAKE_BINARY_DIR}/lib/luajit/libluajit-static.a)
ENDIF()
# target_link_libraries (snabb LINK_PUBLIC luajit)