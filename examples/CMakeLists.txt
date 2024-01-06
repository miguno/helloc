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

# A demo app that demonstrates how to integrate and use a single-header library
# (https://github.com/zpl-c/zpl)
add_executable (single-header-demo single-header-demo.c)
target_link_libraries(single-header-demo PRIVATE zpl)
set_target_properties(single-header-demo PROPERTIES C_EXTENSIONS ON)

add_executable (uppercase uppercase.c)

