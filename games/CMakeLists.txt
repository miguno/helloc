### raylib example {{{
# Adapted from https://github.com/raysan5/raylib/tree/master/projects/CMake

add_executable(game game.c)
#set(raylib_VERBOSE 1)
target_link_libraries(game raylib)

if (APPLE)
  target_link_libraries(game "-framework IOKit")
  target_link_libraries(game "-framework Cocoa")
  target_link_libraries(game "-framework OpenGL")
endif()
### }}} raylib example
