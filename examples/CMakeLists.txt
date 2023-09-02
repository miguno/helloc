add_executable (malloc-tutorial malloc-tutorial.c)
# * `-Wno-deprecated-declarations`: required to be able to use `sbrk`, which is
#   deprecated (at least on macOS); see also `man sbrk`
target_compile_options(malloc-tutorial PRIVATE -Wno-deprecated-declarations)
if (UNIX)
  # asprintf() is part of stdio.h, but it is not part of the C Standard. It
  # requires `define #_GNU_SOURCE` when compiling on Gnu-based systems.
  # Otherwise, compilation fails with:
  #
  #  error: implicit declaration of function 'asprintf' is invalid in C99
  #
  target_compile_definitions(malloc-tutorial PRIVATE _GNU_SOURCE)
endif()

add_executable (uppercase uppercase.c)

# A demo app that demonstrates how to integrate and use a single-header library
# (https://github.com/zpl-c/zpl)
add_executable (single-header-demo single-header-demo.c)
target_link_libraries(single-header-demo PRIVATE zpl)

# A demo app that demonstrates how to build a simple game with raylib
# (https://github.com/raysan5/raylib)
add_executable (game game.c)
target_link_libraries(game raylib)
# Link appropriate frameworks when on macOS
if (APPLE)
  target_link_libraries(game "-framework IOKit")
  target_link_libraries(game "-framework Cocoa")
  target_link_libraries(game "-framework OpenGL")
endif()
