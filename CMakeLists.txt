cmake_minimum_required(VERSION 3.22)

# `-DCMAKE_EXPORT_COMPILE_COMMANDS` generates `build/compile_commands.json`,
# which is needed for the clangd LSP server.
# https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#clangd
# https://clangd.llvm.org/installation#compile_commandsjson
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# https://cmake.org/cmake/help/latest/variable/CMAKE_CONFIGURATION_TYPES.html
# https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html
# https://ninja-build.org/manual.html
set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo" CACHE STRING "" FORCE)

project(helloc C)

# https://cmake.org/cmake/help/latest/prop_tgt/C_STANDARD.html
set(CMAKE_C_STANDARD 17)

# Compiler options for different builds, e.g. Debug vs. Release
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS_CONFIG.html
# * `-g3` : Generate abundant debugging information
# * `-O2` : Optimize code for speed/space efficiency
# * `-D_FORTIFY_SOURCE=2`: Detect runtime buffer overflows (requires `-O2` or higher)
#
# Sanitizer related flags:
# * `-fsanitize=address`: for ASan https://clang.llvm.org/docs/AddressSanitizer.html
#                         NOTE: ASan is only compatible with `-O0` it seems.
#                         NOTE: On macOS, you must explicitly run your binary
#                         with `ASAN_OPTIONS=detect_leaks=1 main ...` to enable
#                         leak detection.
# * `-fsanitize=undefined`: for UBSan https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
# * `-fno-omit-frame-pointer`: nicer stack traces in error messages
#
# Valgrind users:
# 1. Valgrind is incompatible with ASan.  Remove the ASan compiler option
#    (`-fsanitize=address`) when you want to use valgrind.
# 2. Valgrind does not properly read DWARF5 as used by clang 14.  Until the bug
#    is fixed, you must add `-gdwarf-4` to CMAKE_C_FLAGS_* to make its output
#    compatible with valgrind.
#    https://bugs.kde.org/show_bug.cgi?id=452758
#
# See generated `build/build-Debug.ninja`, `build/CMakeFiles/impl-Debug.ninja`
set(CMAKE_C_FLAGS_DEBUG   "-O0 -g3 -fsanitize=address,undefined,float-divide-by-zero,integer,implicit-conversion,local-bounds,nullability -fno-omit-frame-pointer")
# See generated `build/build-Release.ninja` & `build/CMakeFiles/impl-Release.ninja`
set(CMAKE_C_FLAGS_RELEASE "-O3 -g -D_FORTIFY_SOURCE=2")

# Compile options used across Debug/Release/... builds are defined here.
#
# Explanation:
# * `-Wall`              : Turn on recommended compiler warnings
# * `-pedantic`          : Issue warnings demanded by strict conformance to the
#                          standard
# * `-Werror`            : Turn warnings into errors
# * `-fPIE -Wl,-pie`     : Needed to enable full ASLR for executables.
#                          When `-fPIE` is used for the compiler, you must also
#                          set `-Wl,-pie` for the linker.
#
# When building a shared library:
# * `-shared -fPIC`      : Disable text relocations for shared libraries
#
# https://clang.llvm.org/docs/UsersManual.html#command-line-options
# https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html
# https://airbus-seclab.github.io/c-compiler-security/clang_compilation.html
add_compile_options( # shared by all compilers supported by this project
    -Wall
    -Wextra
    -pedantic
    -Werror
    -Wconversion
    -Warray-bounds
    -Wimplicit-fallthrough
    -Wswitch-enum
    -Wbad-function-cast
    -Wfloat-equal
    -Wpointer-arith
    -fPIE
)
# For customizing gcc, use `MATCHES "GNU"` or `STREQUAL "GNU"`.
if ("${CMAKE_C_COMPILER_ID}" MATCHES "Clang")
add_compile_options(
    # Notably, we set additional compiler flags that are not supported by gcc.
    -Warray-bounds-pointer-arithmetic
    -Wconditional-uninitialized
    -Wloop-analysis
    -Wshift-sign-overflow
    -Wcomma
    -Wassign-enum
    -Wformat-type-confusion
    -Widiomatic-parentheses
    -Wunreachable-code-aggressive
    -Wthread-safety
    -Wthread-safety-beta
    -Wno-newline-eof
)
endif()

# Linker options used across Debug/Release/... builds are defined here.
#
# * `-Wl,-pie`: Passes the `-pie` option to the linker. Required when using
#               the compile option `-fPIE`.
#
add_link_options(-Wl,-pie)
# Enable color output of unity tests
add_compile_definitions(UNITY_OUTPUT_COLOR)

# Add `./cmake` to the module path.
# Contains e.g. `FindCriterion.cmake` to find the Criterion headers and library.
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# External libraries we will link to (e.g., Unity)
add_subdirectory(external)

# Location of our source files
add_subdirectory(src)
add_subdirectory(examples)

# Location of our test files
enable_testing()
add_subdirectory(test)
