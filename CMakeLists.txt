cmake_minimum_required(VERSION 3.22)

# Setup vcpkg script with CMake. Should be placed before project() call.
#
# My configuration expects you have already set the VCPKG_ROOT environment
# variable in your shell environment.  Alternatively, you can set it here with:
#
#       set(VCPKG_ROOT "/path/to/my/vcpkg")
#
# Other useful variables:
# * CMAKE_CURRENT_SOURCE_DIR (e.g., `set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR} ...`)
set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")

# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html
# Setting to 'clang' ensures that cmake doesn't auto-search for `cc`, which
# on a default macOS system with XCode alongside homebrew's llvm/clang package
# will wrongly pick the system clang (which installs a copy of the clang binary
# at /usr/bin/cc and /Library/Developer/CommandLineTools/usr/bin/cc) rather
# than homebrew's (which does not install its own `cc` binary).
set(CMAKE_C_COMPILER clang)

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
# See generated `build/build-Debug.ninja`, `build/CMakeFiles/impl-Debug.ninja`
set(CMAKE_C_FLAGS_DEBUG   "-Og -g3")
# See generated `build/build-Release.ninja` & `build/CMakeFiles/impl-Release.ninja`
set(CMAKE_C_FLAGS_RELEASE "-O3 -g -D_FORTIFY_SOURCE=2")

# Common settings used across Debug/Release/... builds are defined here.
#
# Explanation:
# * `-Wall`              : Turn on recommended compiler warnings
# * `-pedantic`          : Issue warnings demanded by strict conformance to the
#                          standard
# * `-Werror`            : Turn warnings into errors
# * `-fPIE -Wl,-pie`     : Needed to enable full ASLR for executables.
#                          `-fPIE` is for the compiler, whereas `-Wl,...`
#                          passes the `-pie` option to the linker.
#
# When building a shared library:
# * `-shared -fPIC`      : Disable text relocations for shared libraries
#
# https://clang.llvm.org/docs/UsersManual.html#command-line-options
# https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html
add_compile_options(-Wall -Wextra -pedantic -Werror -Wno-newline-eof -fPIE)
add_link_options(-Wl,-pie)
# Enable color output of unity tests
add_compile_definitions(UNITY_OUTPUT_COLOR)

# Add `./cmake` to the module path.
# Contains e.g. `FindCriterion.cmake` to find the Criterion headers and library.
# https://github.com/Snaipe/Criterion/blob/bleeding/dev/cmake/CMakeLists.txt
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# vcpkg dependencies, see vcpkg.json
find_path(STB_INCLUDE_DIRS "stb_ds.h")

# External, non-vcpkg-managed libraries we will link to (e.g., Unity)
add_subdirectory(external)

# Location of our source files
add_subdirectory(src)

# Location of our test files
enable_testing()
add_subdirectory(test)
