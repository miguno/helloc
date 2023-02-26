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

add_subdirectory(raylib)
