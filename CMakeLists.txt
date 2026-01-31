# Required version is 3.26 so that we can use a different C standard
# when building flecs.
#
# From https://cmake.org/cmake/help/latest/manual/cmake-compile-features.7.html#supported-compilers:
#
# Changed in version 3.26:
#    The language standard flag is placed before flags specified by other
#    abstractions such as the target_compile_options() command. Prior to CMake
#    3.26, the language standard flag was placed after them.
#
# For example, with cmake <3.26, when setting CMAKE_C_STANDARD to e.g. '23'
# below, the build would add the flag `-std=gnu2x` to compile commands AFTER
# any manually added flags like `-std=gnu99`, which this project must use to
# build flecs (the generated, effective compile commands are defined in
# `{build,build-for-coverage}/compile_commands.json`).
# When that happened, this project would fail to build with errors such as:
#
# flecs.c:45190:20: error: incompatible types when returning type '_Bool' but 'ecs_table_cache_hdr_t *' was expected
# 45190 |             return false;
#       |                    ^~~~~
#
cmake_minimum_required(VERSION 3.22)

# When using a non-Apple compiler (e.g., Homebrew LLVM) on macOS, CMake may
# not set CMAKE_OSX_SYSROOT automatically.  Without it the compiler (and
# clang-tidy) cannot find system headers such as <stdio.h>.
if (APPLE AND NOT CMAKE_OSX_SYSROOT)
    execute_process(
        COMMAND xcrun --show-sdk-path
        OUTPUT_VARIABLE _OSX_SYSROOT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE _XCRUN_RESULT
    )
    if (_XCRUN_RESULT EQUAL 0 AND _OSX_SYSROOT)
        set(CMAKE_OSX_SYSROOT "${_OSX_SYSROOT}" CACHE PATH "macOS SDK path")
        message(STATUS "CMAKE_OSX_SYSROOT was not set, using: ${CMAKE_OSX_SYSROOT}")
    endif ()
endif ()

# Example setups for CMakeLists.txt to get inspired by:
# - https://github.com/duckdb/duckdb/blob/master/CMakeLists.txt

# `-DCMAKE_EXPORT_COMPILE_COMMANDS` generates `build/compile_commands.json`,
# which is needed for tools including clang-tidy and the clangd LSP server.
# https://clangd.llvm.org/installation#compile_commandsjson
# https://clang.llvm.org/docs/JSONCompilationDatabase.html
# https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# https://cmake.org/cmake/help/latest/variable/CMAKE_CONFIGURATION_TYPES.html
# https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html
# https://ninja-build.org/manual.html
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)

# IMPORTANT: Versioning logic here must match the logic in tools/version.sh!
project(helloc VERSION "0.1.0.0" # Keep VERSION setting on the same line as project(...) for `tools/version.sh`
        LANGUAGES C
        DESCRIPTION "My template project for C development")

MESSAGE(STATUS "Project version: ${PROJECT_VERSION}")
# Make PROJECT_VERSION available as a preprocessor definition, so we can access
# the version information from within our source code.
add_definitions(-DPROJECT_VERSION="${PROJECT_VERSION}")

# https://cmake.org/cmake/help/latest/prop_tgt/C_STANDARD.html
if (NOT CMAKE_C_STANDARD)
    set(CMAKE_C_STANDARD 23)
    set(CMAKE_C_STANDARD_REQUIRED ON)
    message(STATUS "Setting C standard to C${CMAKE_C_STANDARD}")
endif ()
set(CMAKE_C_EXTENSIONS OFF)
message(STATUS "Disabling compiler-specific C extensions")

# Detect host architecture
set(OS_ARCH "amd64")
string(REGEX MATCH "(arm64|aarch64)" IS_ARM "${CMAKE_SYSTEM_PROCESSOR}")
if (IS_ARM)
    set(OS_ARCH "arm64")
endif()
MESSAGE(STATUS "Host architecture: ${OS_ARCH}")

# Detect host operating system
set(OS_NAME "unknown")
if (APPLE)
    set(OS_NAME "osx")
elseif (WIN32)
    set(OS_NAME "windows")
elseif (UNIX AND NOT APPLE)
    set(OS_NAME "linux") # We ignore other OS like BSD in the current logic.
endif()
MESSAGE(STATUS "Host operating system: ${OS_NAME}")

# CMake
MESSAGE(STATUS "cmake version: ${CMAKE_VERSION}")

# When using a non-Apple clang (e.g., Homebrew LLVM) on macOS, it doesn't
# know the SDK location. Set CMAKE_OSX_SYSROOT so that system headers like
# <math.h> and frameworks like SDL2 are found by the compiler, clangd, and
# clang-tidy.
if (APPLE AND NOT CMAKE_OSX_SYSROOT)
    execute_process(
        COMMAND xcrun --show-sdk-path
        OUTPUT_VARIABLE CMAKE_OSX_SYSROOT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE _XCRUN_RESULT
    )
    if (_XCRUN_RESULT EQUAL 0 AND CMAKE_OSX_SYSROOT)
        set(CMAKE_OSX_SYSROOT "${CMAKE_OSX_SYSROOT}" CACHE PATH "macOS SDK path")
        message(STATUS "CMAKE_OSX_SYSROOT (macOS SDK) was not set, using: ${CMAKE_OSX_SYSROOT}")
    endif ()
endif ()

# Use ccache to speed up builds, if available.
if (NOT DEFINED USE_CCACHE)
    set(USE_CCACHE AUTO CACHE STRING "Use ccache if found when invoking compiler")
endif ()

# Add `./cmake` to the module path.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CCache) # CCache.cmake
include(CompilerSettings) # CompilerSettings.cmake

# External libraries we will link to (e.g., Unity)
add_subdirectory(external)

# Location of our source files
add_subdirectory(src)
add_subdirectory(examples)

# Location of our test files
enable_testing()
add_subdirectory(test)
