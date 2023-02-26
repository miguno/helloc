# Include raylib as a dependency. Download and build if needed.
# Use it as `raylib`, e.g. `target_link_libraries(my_target raylib)`.
#
# NOTE: Configuring raylib with its own sub-directory and CMakeLists.txt was
# the only effective way to disable compiler warnings (e.g.,
# `-Wno-sign-conversion`) in this project when building raylib from sources.
#
# Using `add_compile_options()`, which applies its settings universally within
# a sub-directory, was the only approach that worked.  Failed approaches
# included using `target_compile_options()`, `set_source_files_property()`,
# and `set_property(TARGET raylib PROPERTY COMPILE_OPTIONS ...)`.
#
# If you know of a better approach, please create an issue or pull request!

### raylib {{{
# Adapted from https://github.com/raysan5/raylib/tree/master/projects/CMake

# Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

set(RAYLIB_VERSION 4.2.0)
find_package(raylib ${RAYLIB_VERSION} QUIET) # QUIET or REQUIRED
if (NOT raylib_FOUND) # If there's none, fetch and build raylib
  include(FetchContent)
  FetchContent_Declare(
    raylib
    URL https://github.com/raysan5/raylib/archive/refs/tags/${RAYLIB_VERSION}.tar.gz
  )
  FetchContent_GetProperties(raylib)
  if (NOT raylib_POPULATED) # Have we downloaded raylib yet?
    # Suppress certain warnings while building raylib
    add_compile_options(
      -Wno-error
      -Wno-sign-conversion
      -Wno-implicit-int-conversion
      -Wno-implicit-int-float-conversion
      -Wno-implicit-float-conversion
      -Wno-shorten-64-to-32
      -Wno-unused-parameter
      -Wno-unreachable-code
      -Wno-extra-semi
      -Wno-implicit-fallthrough
      -Wno-conditional-uninitialized
      -Wno-sign-compare
      -Wno-float-conversion
      -Wno-float-equal
      -Wno-switch-enum
      -Wno-bad-function-cast
      -Wno-unused-but-set-variable
      -Wno-comma
      -Wno-gnu-binary-literal
      -Wno-unused-function
      -Wno-string-conversion
      -Wno-pedantic
      -Wno-missing-field-initializers
      -Wno-assign-enum
      -Wno-shift-sign-overflow
    )
    if (APPLE)
      add_compile_options(-Wno-deprecated-declarations)
    endif()

    set(FETCHCONTENT_QUIET NO)
    FetchContent_Populate(raylib)
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE) # don't build the examples
    add_subdirectory(${raylib_SOURCE_DIR} ${raylib_BINARY_DIR})
  endif()
endif()
### }}} raylib
