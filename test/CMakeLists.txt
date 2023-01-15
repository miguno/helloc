### Criterion {{{
add_executable(criterion_testsuite criterion_tests.c)

find_package(Criterion REQUIRED)

target_include_directories(criterion_testsuite
    # SYSTEM is required here to prevent clang-tidy to check the included headers
    SYSTEM PRIVATE
        ${CRITERION_INCLUDE_DIRS}
        "${CMAKE_SOURCE_DIR}/src" # to find `miguno.h`; alternatively, "../src"
)
target_link_libraries (criterion_testsuite ${CRITERION_LIBRARIES} Miguno)

# To let us run tests via `cd build && ninja test`
add_test(criterion_testsuite criterion_testsuite)
### }}} Criterion


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
