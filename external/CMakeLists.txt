### Unity {{{
add_library(unity STATIC
    unity.c
)

target_include_directories(unity PUBLIC ${CMAKE_CURRENT_LIST_DIR})
### }}} Unity
