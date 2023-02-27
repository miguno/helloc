### Unity {{{
add_executable(unity_testsuite unity_tests.c)

target_include_directories(unity_testsuite
    PRIVATE
        "${CMAKE_SOURCE_DIR}/src" # to find `miguno.h`; alternatively, "../src"
)
target_link_libraries(unity_testsuite unity Miguno)

add_test(
  NAME
    unity_testsuite
  COMMAND
    $<TARGET_FILE:unity_testsuite>
)
### }}} Unity
