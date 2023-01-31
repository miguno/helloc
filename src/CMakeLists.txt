add_library (Miguno miguno.c miguno.h)

add_executable (main main.c)
target_link_libraries (main Miguno)

add_executable (malloc-tutorial malloc-tutorial.c)
# * `-Wno-deprecated-declarations`: required to be able to use `sbrk`, which is
#   deprecated (at least on macOS); see also `man sbrk`
target_compile_options(malloc-tutorial PRIVATE -Wno-deprecated-declarations)
if(UNIX)
    # asprintf() is part of stdio.h, but it is not part of the C Standard. It
    # requires `define #_GNU_SOURCE` when compiling on Gnu-based systems.
    # Otherwise, compilation fails with:
    #
    #  error: implicit declaration of function 'asprintf' is invalid in C99
    #
    target_compile_definitions(malloc-tutorial PRIVATE _GNU_SOURCE)
endif()
