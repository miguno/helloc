cmake_minimum_required(VERSION 3.22)

# `-DCMAKE_EXPORT_COMPILE_COMMANDS` generates `build/compile_commands.json`,
# which is needed for several tools including clang-tidy and the clangd LSP
# server.
# https://clangd.llvm.org/installation#compile_commandsjson
# https://clang.llvm.org/docs/JSONCompilationDatabase.html
# https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# https://cmake.org/cmake/help/latest/variable/CMAKE_CONFIGURATION_TYPES.html
# https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html
# https://ninja-build.org/manual.html
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)

project(helloc C)

# https://cmake.org/cmake/help/latest/prop_tgt/C_STANDARD.html
set(CMAKE_C_STANDARD 17)

# Add `./cmake` to the module path.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(AddIfFlagCompiles)

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
# 1. Valgrind is incompatible with ASan.  Set ENABLE_ASAN to OFF when you want
#    to use valgrind.
# 2. Valgrind does not properly read DWARF5 as used by clang 14.  Until the bug
#    is fixed, you must add `-gdwarf-4` to CMAKE_C_FLAGS_* to make its output
#    compatible with valgrind.
#    https://bugs.kde.org/show_bug.cgi?id=452758
#
# For Debug builds, see generated `build/build-Debug.ninja`   & `build/CMakeFiles/impl-Debug.ninja`
add_if_flag_compiles(-O0 -g3                    CMAKE_C_FLAGS_DEBUG)
# For Release builds, see generated `build/build-Release.ninja` & `build/CMakeFiles/impl-Release.ninja`
add_if_flag_compiles(-O3 -g -D_FORTIFY_SOURCE=2 CMAKE_C_FLAGS_RELEASE)
# `-fno-omit-frame-pointer`: nicer stack traces in error messages
add_if_flag_compiles(-fno-omit-frame-pointer CMAKE_C_FLAGS_DEBUG)
add_if_flag_compiles(-fno-omit-frame-pointer CMAKE_C_FLAGS_RELEASE)

if (CMAKE_C_COMPILER_ID MATCHES "GNU" AND APPLE)
  # gcc on Apple Silicon is missing AddressSanitizer/UBSanitizer,
  # see https://github.com/Homebrew/discussions/discussions/3384
  MESSAGE(STATUS "Compiler is GCC on macOS. Disabling ASan and UBSan, because they are unsupported on Apple Silicon.")
  set(CMAKE_C_FLAGS_DEBUG "-O0 -g3 -fno-omit-frame-pointer")
  option(ENABLE_ASAN  "Enable AddressSanitizer" OFF)
  option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" OFF)
elseif (CMAKE_C_COMPILER_ID MATCHES "GNU")
  MESSAGE(STATUS "Compiler is GCC. Enabling ASan and UBSan.")
  option(ENABLE_ASAN  "Enable AddressSanitizer" ON)
  option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" ON)
elseif (CMAKE_C_COMPILER_ID MATCHES "Clang")
  MESSAGE(STATUS "Compiler is Clang. Enabling ASan and UBSan.")
  option(ENABLE_ASAN  "Enable AddressSanitizer" ON)
  option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" ON)
else()
  MESSAGE(STATUS "Compiler is unknown (neither Clang nor GCC). Disabling ASan and UBSan.")
  option(ENABLE_ASAN  "Enable AddressSanitizer" OFF)
  option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" OFF)
endif()

# https://clang.llvm.org/docs/AddressSanitizer.html
if (ENABLE_ASAN)
  # IMPORTANT: ASan is apparently only compatible with `-O0`, so we enable it only for our Debug builds.
  #
  # NOTE: To enable leak detection on macOS, you must explicitly run your
  #       binary with `ASAN_OPTIONS=detect_leaks=1 my_binary ...`.
  add_if_flag_compiles(-fsanitize=address CMAKE_C_FLAGS_DEBUG)
endif()

# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
if (ENABLE_UBSAN AND CMAKE_C_COMPILER_ID MATCHES "Clang")
  MESSAGE(STATUS "Compiler is Clang. Using full set of UBSan settings.")
  add_if_flag_compiles(
    -fsanitize=undefined,float-divide-by-zero,integer,implicit-conversion,local-bounds,nullability
    CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE)
elseif (ENABLE_UBSAN AND CMAKE_C_COMPILER_ID MATCHES "GNU")
  MESSAGE(STATUS "Compiler is GCC. Using limited set of UBSan settings.")
  add_if_flag_compiles(
    -fsanitize=undefined,float-divide-by-zero
    CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE)
endif()

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
add_if_flag_compiles(-Wall COMPILE_OPTIONS)
add_if_flag_compiles(-Wextra COMPILE_OPTIONS)
add_if_flag_compiles(-pedantic COMPILE_OPTIONS)
add_if_flag_compiles(-Werror COMPILE_OPTIONS)
add_if_flag_compiles(-Wconversion COMPILE_OPTIONS)
add_if_flag_compiles(-Warray-bounds COMPILE_OPTIONS)
add_if_flag_compiles(-Wimplicit-fallthrough COMPILE_OPTIONS)
add_if_flag_compiles(-Wswitch-enum COMPILE_OPTIONS)
add_if_flag_compiles(-Wbad-function-cast COMPILE_OPTIONS)
add_if_flag_compiles(-Wfloat-equal COMPILE_OPTIONS)
add_if_flag_compiles(-Wpointer-arith COMPILE_OPTIONS)
add_if_flag_compiles(-fPIE COMPILE_OPTIONS)

# For customizing gcc, use `MATCHES "GNU"` or `STREQUAL "GNU"`.
if (CMAKE_C_COMPILER_ID MATCHES "Clang")
  # Notably, we set additional compiler flags that are not supported by gcc.
  add_if_flag_compiles(-Warray-bounds-pointer-arithmetic COMPILE_OPTIONS)
  add_if_flag_compiles(-Wconditional-uninitialized COMPILE_OPTIONS)
  add_if_flag_compiles(-Wloop-analysis COMPILE_OPTIONS)
  add_if_flag_compiles(-Wshift-sign-overflow COMPILE_OPTIONS)
  add_if_flag_compiles(-Wcomma COMPILE_OPTIONS)
  add_if_flag_compiles(-Wassign-enum COMPILE_OPTIONS)
  add_if_flag_compiles(-Wformat-type-confusion COMPILE_OPTIONS)
  add_if_flag_compiles(-Widiomatic-parentheses COMPILE_OPTIONS)
  add_if_flag_compiles(-Wunreachable-code-aggressive COMPILE_OPTIONS)
  add_if_flag_compiles(-Wthread-safety COMPILE_OPTIONS)
  add_if_flag_compiles(-Wthread-safety-beta COMPILE_OPTIONS)
  add_if_flag_compiles(-Wno-newline-eof COMPILE_OPTIONS)
endif()

# Linker options used across Debug/Release/... builds are defined here.
#
# * `-Wl,-pie`: Passes the `-pie` option to the linker. Required when using
#               the compile option `-fPIE`.
#
add_link_options(-Wl,-pie)
# Enable color output of unity tests
add_compile_definitions(UNITY_OUTPUT_COLOR)

# External libraries we will link to (e.g., Unity)
add_subdirectory(external)

# Location of our source files
add_subdirectory(src)
add_subdirectory(examples)

# Location of our test files
enable_testing()
add_subdirectory(test)
