### Unity {{{
add_library(unity STATIC
    unity.c
)

target_compile_options(unity PRIVATE
    -Wno-switch-enum
    -Wno-float-equal
)
target_include_directories(unity PUBLIC ${CMAKE_CURRENT_LIST_DIR})
### }}} Unity

### zpl {{{
### https://github.com/zpl-c/zpl
# stb_ds.h is a header-only library, but still a library, so it should be added
# as a library.
# NOTE: You must add it as INTERFACE.  You cannot add it as PUBLIC or PRIVATE.
# * PRIVATE:   cares about itself only and does not allow inheritance
# * INTERFACE: cares about others only and allows inheritance
# * PUBLIC:    cares about everyone and allows inheritance
# More details at https://leimao.github.io/blog/CMake-Public-Private-Interface/
add_library(zpl INTERFACE)
target_include_directories(zpl INTERFACE ${CMAKE_CURRENT_LIST_DIR})
set_target_properties(zpl PROPERTIES C_EXTENSIONS ON)
### }}} zpl
