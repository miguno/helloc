### Unity {{{
add_library(unity "")

target_sources(unity
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/unity.c
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/unity.h
        ${CMAKE_CURRENT_LIST_DIR}/unity_internals.h
)

target_include_directories(unity PUBLIC ${CMAKE_CURRENT_LIST_DIR})
### }}} Unity