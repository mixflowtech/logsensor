cmake_minimum_required (VERSION 2.8.11)
project (snabb)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")


if(WIN32)
	set(CMAKE_LUA_COMPILER ${CMAKE_BINARY_DIR}/lib/luajit/luajit CACHE FILEPATH "The LuaJIT compiler")
ELSE()
	# On Linux inplace luajit not work.
	set(CMAKE_LUA_COMPILER ${CMAKE_SOURCE_DIR}/lib/luajit/usr/local/bin/luajit CACHE FILEPATH "The LuaJIT compiler")
ENDIF()

set(MAKE make)
set(LUAJIT_CFLAGS ${CMAKE_SOURCE_DIR}/gcc-preinclude.h)

#	$(Q) $(CC) $(DEBUG) -Wl,--no-as-needed -Wl,-E -Werror -Wskip=unused-function -Wall -o $@ $^ \
# 	    ../lib/luajit/src/libluajit.a \
#

# set(CMAKE_C_FLAGS "-Wl,--no-as-needed -Wl,-E -Werror -Wall ${CMAKE_C_FLAGS}")

#add_custom_target(
#   luajit
#   COMMAND $(MAKE) PREFIX=`pwd`/usr/local CFLAGS="$(LUAJIT_CFLAGS)" && $(MAKE) DESTDIR=`pwd` install
#   WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/lib/luajit
#)

# Ugly warnings
IF(MSVC)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /OPT:REF /OPT:NOICF")
ENDIF()

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/lib/luajit/usr/local)
add_subdirectory (lib/luajit)

ADD_CUSTOM_TARGET(
    make_ln_luajit
    echo "make a ln -s to luajit"
    COMMAND ln -fs luajit-2.1.0-beta1 luajit
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/lib/luajit/usr/local/bin
    DEPENDS luajit)

if(NOT WIN32)
# copy file
file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/src/syscall/linux)
file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/src/syscall/linux/x64)
file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/src/syscall/shared)

add_custom_target(copy_ljsyscall)

add_custom_command(TARGET copy_ljsyscall PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E
                   copy ${CMAKE_SOURCE_DIR}/lib/ljsyscall/syscall.lua   ${CMAKE_SOURCE_DIR}/src/ )
add_custom_command(TARGET copy_ljsyscall PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E
                   copy ${CMAKE_SOURCE_DIR}/lib/ljsyscall/syscall/*.lua   ${CMAKE_SOURCE_DIR}/src/syscall/ )
add_custom_command(TARGET copy_ljsyscall PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E
                   copy ${CMAKE_SOURCE_DIR}/lib/ljsyscall/syscall/linux/*.lua   ${CMAKE_SOURCE_DIR}/src/syscall/linux/ )
add_custom_command(TARGET copy_ljsyscall PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E
                   copy ${CMAKE_SOURCE_DIR}/lib/ljsyscall/syscall/linux/x64/*.lua   ${CMAKE_SOURCE_DIR}/src/syscall/linux/x64/ )
add_custom_command(TARGET copy_ljsyscall PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E
                   copy ${CMAKE_SOURCE_DIR}/lib/ljsyscall/syscall/shared/*.lua   ${CMAKE_SOURCE_DIR}/src/syscall/shared/ )
ENDIF()

# do copy file task here
set(WITH_LUA_ENGINE "LuaJIT")
set(LUA_BUILD_TYPE "System")
set(LUAJIT_FOUND True)
set(LUAJIT_INCLUDE_DIR  ${CMAKE_SOURCE_DIR}/lib/luajit/src/)
set(LUAJIT_LIBRARIES    ${CMAKE_BINARY_DIR}/lib/luajit/luajit-static.lib)
set(BUILD_MODULE ON)
SET(WITH_SHARED_LUA OFF)
add_subdirectory (lib/luv)

add_subdirectory (src)
