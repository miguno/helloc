include(AddIfFlagCompiles)

# For shared libraries or PIE executables (cf `-fPIC`)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

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
if ((CMAKE_C_COMPILER_ID MATCHES "Clang") OR (CMAKE_C_COMPILER_ID MATCHES "GNU"))
    ### Debug builds
    # See generated `build/build-Debug.ninja` & `build/CMakeFiles/impl-Debug.ninja`
    add_if_flag_compiles(-O0 CMAKE_C_FLAGS_DEBUG)
    add_if_flag_compiles(-g3 CMAKE_C_FLAGS_DEBUG)
    add_if_flag_compiles(-fno-omit-frame-pointer CMAKE_C_FLAGS_DEBUG)

    ### Release builds
    # See generated `build/build-Release.ninja` & `build/CMakeFiles/impl-Release.ninja`
    add_if_flag_compiles(-O3 CMAKE_C_FLAGS_RELEASE)
    add_if_flag_compiles(-g CMAKE_C_FLAGS_RELEASE)
    add_if_flag_compiles(-D_FORTIFY_SOURCE=2 CMAKE_C_FLAGS_RELEASE)
    add_if_flag_compiles(-fno-omit-frame-pointer CMAKE_C_FLAGS_RELEASE)

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
    add_if_flag_compiles(-Wbad-function-cast COMPILE_OPTIONS)
    add_if_flag_compiles(-Wfloat-equal COMPILE_OPTIONS)
    add_if_flag_compiles(-Wimplicit-fallthrough COMPILE_OPTIONS)
    add_if_flag_compiles(-Wpointer-arith COMPILE_OPTIONS)
    add_if_flag_compiles(-Wshadow COMPILE_OPTIONS)
    add_if_flag_compiles(-Wswitch-enum COMPILE_OPTIONS)
    add_if_flag_compiles(-fPIE COMPILE_OPTIONS)

    # Clang-only compile options
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
    endif ()
elseif (CMAKE_C_COMPILER_ID MATCHES "MSVC")
    # NOTE: add_if_flag_compiles() does not work with flags set with `/`, like `/fsanitize=...`.

    ### Debug builds
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /Od")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /DEBUG")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /Zi")
    # Enable additional security checks
    # https://learn.microsoft.com/en-us/cpp/build/reference/sdl-enable-additional-security-checks
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /sdl")

    ### Release builds
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /O2")
endif ()

# Parse environment variables
if (DEFINED ENV{ENABLE_ASAN})
    set(ENABLE_ASAN $ENV{ENABLE_ASAN})
endif ()
if (DEFINED ENV{ENABLE_UBSAN})
    set(ENABLE_UBSAN $ENV{ENABLE_UBSAN})
endif ()

if (DEFINED ENABLE_ASAN)
    MESSAGE(STATUS "ENABLE_ASAN was already set by user (${ENABLE_ASAN}), skipping auto-configuration")
else ()
    if (CMAKE_C_COMPILER_ID MATCHES "GNU" AND APPLE)
        # gcc on Apple Silicon is missing AddressSanitizer/UBSanitizer,
        # see https://github.com/Homebrew/discussions/discussions/3384
        MESSAGE(STATUS "Compiler is GCC on macOS. Disabling ASan, because it is unsupported on Apple Silicon.")
        set(ENABLE_ASAN OFF)
    elseif (CMAKE_C_COMPILER_ID MATCHES "Clang" AND APPLE)
        # The combination of clang with SDL2 triggers ASan problems on macOS,
        # so we have to disable ASan, unfortunately. :-(
        MESSAGE(STATUS "Compiler is Clang on macOS. Disabling ASan, because it causes issues with SDL2.")
        set(ENABLE_ASAN OFF)
    elseif (CMAKE_C_COMPILER_ID MATCHES "GNU")
        MESSAGE(STATUS "Compiler is GCC. Enabling ASan.")
        set(ENABLE_ASAN ON)
    elseif (CMAKE_C_COMPILER_ID MATCHES "Clang")
        if (WIN32)
            MESSAGE(STATUS "Compiler is Clang on Windows. Disabling ASan.")
            set(ENABLE_ASAN OFF)
        else ()
            MESSAGE(STATUS "Compiler is Clang. Enabling ASan.")
            set(ENABLE_ASAN ON)
        endif ()
    elseif (CMAKE_C_COMPILER_ID MATCHES "MSVC")
        MESSAGE(STATUS "Compiler is MSVC. Enabling ASan.")
        set(ENABLE_ASAN ON)
    else ()
        MESSAGE(STATUS "Compiler is unknown (neither Clang, GCC, nor MSVC). Disabling ASan.")
        set(ENABLE_ASAN OFF)
    endif ()
endif ()

if (DEFINED ENABLE_UBSAN)
    MESSAGE(STATUS "ENABLE_UBSAN was already set by user (${ENABLE_UBSAN}), skipping auto-configuration")
else ()
    if (CMAKE_C_COMPILER_ID MATCHES "GNU" AND APPLE)
        # gcc on Apple Silicon is missing AddressSanitizer/UBSanitizer,
        # see https://github.com/Homebrew/discussions/discussions/3384
        MESSAGE(STATUS "Compiler is GCC on macOS. Disabling UBSan, because it is unsupported on Apple Silicon.")
        set(ENABLE_UBSAN OFF)
    elseif (CMAKE_C_COMPILER_ID MATCHES "GNU")
        MESSAGE(STATUS "Compiler is GCC. Enabling UBSan.")
        set(ENABLE_UBSAN ON)
    elseif (CMAKE_C_COMPILER_ID MATCHES "Clang")
        MESSAGE(STATUS "Compiler is Clang. Enabling UBSan.")
        set(ENABLE_UBSAN ON)
    elseif (CMAKE_C_COMPILER_ID MATCHES "MSVC")
        MESSAGE(STATUS "Compiler is MSVC. Disabling UBSan.")
        set(ENABLE_UBSAN OFF)
    else ()
        MESSAGE(STATUS "Compiler is unknown (neither Clang, GCC, nor MSVC). Disabling UBSan.")
        set(ENABLE_UBSAN OFF)
    endif ()
endif ()

if ("$ENV{VALGRIND}" STREQUAL "1")
    # Valgrind is incompatible with ASan.
    MESSAGE(STATUS "Disabling ASan because you want to run valgrind against the binaries.")
    set(ENABLE_ASAN OFF)
    # Older versions of valgrind do not properly read DWARF5 as used by clang 14.
    # Unless you are using valgrind 3.20.0+, you must add `-gdwarf-4` to
    # CMAKE_C_FLAGS_* to make clang's output compatible with valgrind.
    # https://bugs.kde.org/show_bug.cgi?id=452758
    # TODO: Only set this when using clang, but not when using gcc
    MESSAGE(STATUS "Configuring clang to output DWARF4 instead of DWARF5 to make it compatible with valgrind (see https://bugs.kde.org/show_bug.cgi?id=452758)")
    add_if_flag_compiles(-gdwarf-4 CMAKE_C_FLAGS_DEBUG)
endif ()

# https://clang.llvm.org/docs/AddressSanitizer.html
if (ENABLE_ASAN AND ((CMAKE_C_COMPILER_ID MATCHES "Clang") OR (CMAKE_C_COMPILER_ID MATCHES "GNU")))
    # IMPORTANT: ASan is apparently only compatible with `-O0`, so we enable it only for our Debug builds.
    #
    # NOTE: To enable leak detection on macOS, you must explicitly run your
    #       binary with `ASAN_OPTIONS=detect_leaks=1 my_binary ...`.
    add_if_flag_compiles(-fsanitize=address CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE)
elseif (ENABLE_ASAN AND CMAKE_C_COMPILER_ID MATCHES "MSVC")
    # NOTE: add_if_flag_compiles() does not work with flags set with `/`, like `/fsanitize=...`.
    MESSAGE(STATUS "NOTE: Enabling ASan with MSVC is incompatible with edit-and-continue (a.k.a. 'hot reload', 'live code editing'), incremental linking, and RTC")
    MESSAGE(STATUS "NOTE: Details at https://learn.microsoft.com/en-us/cpp/sanitizers/asan?view=msvc-170")
    # https://stackoverflow.com/questions/66531482/application-crashes-when-using-address-sanitizer-with-msvc/66532115#66532115
    MESSAGE(STATUS "NOTE: Make sure that the folder containing clang_rt.asan_dynamic-x86_64.dll and its *.dll siblings is in %PATH%")
    MESSAGE(STATUS "NOTE: Example: 'c:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.37.32822\\bin\\Hostx64\\x64\\'")
    MESSAGE(STATUS "NOTE: Example: 'c:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.37.32822\\lib\\x64\\'")
    MESSAGE(STATUS "NOTE: Example: 'c:\\Program Files\\LLVM\\lib\\clang\\17\\lib\\windows\\'")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}     /fsanitize=address")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /fsanitize=address")
endif ()

# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
if (ENABLE_UBSAN AND CMAKE_C_COMPILER_ID MATCHES "Clang")
    if (WIN32)
        # On Windows, Clang's UBSan libraries are only available as non-debug
        # builds. That is, debug builds of these libraries are missing:
        #
        # - clang_rt.ubsan_standalone_cxx-x86_64.lib
        # - clang_rt.ubsan_standalone-x86_64.lib
        #
        # Trying to run a debug build with UBSan enabled triggers errors like:
        #
        #   lld-link: error: /failifmismatch: mismatch detected for '_ITERATOR_DEBUG_LEVEL':
        #   >>> libcpmtd.lib(xmtx.obj) has value 2
        #   >>> clang_rt.ubsan_standalone_cxx-x86_64.lib(ubsan_type_hash_win.cpp.obj) has value 0
        #
        # https://learn.microsoft.com/en-us/cpp/standard-library/iterator-debug-level?view=msvc-170
        MESSAGE(STATUS "Compiler is Clang on Windows. Using full set of UBSan settings, but only for Release builds.")
        add_if_flag_compiles(
                -fsanitize=undefined,float-divide-by-zero,integer,implicit-conversion,local-bounds,nullability
                CMAKE_C_FLAGS_RELEASE)
    else ()
        MESSAGE(STATUS "Compiler is Clang. Using full set of UBSan settings.")
        add_if_flag_compiles(
                -fsanitize=undefined,float-divide-by-zero,integer,implicit-conversion,local-bounds,nullability
                CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE)
    endif ()
elseif (ENABLE_UBSAN AND CMAKE_C_COMPILER_ID MATCHES "GNU")
    MESSAGE(STATUS "Compiler is GCC. Using limited set of UBSan settings.")
    add_if_flag_compiles(
            -fsanitize=undefined,float-divide-by-zero
            CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE)
endif ()

# Linker options used across Debug/Release/... builds are defined here.
#
# * `-Wl,-pie`: Passes the `-pie` option to the linker. Required when using
#               the compile option `-fPIE`.
if ((CMAKE_C_COMPILER_ID MATCHES "Clang") OR (CMAKE_C_COMPILER_ID MATCHES "GNU"))
    if (APPLE)
        set(EXTERNAL_COMMAND_RETURN_CODE 1)
        execute_process(
                # Prints version of XCode, e.g. "15.0.0.0.1.1694021235"
                COMMAND sh -c "pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version | awk '{ print $2 }'"
                OUTPUT_VARIABLE EXTERNAL_COMMAND_OUTPUT
                RESULT_VARIABLE EXTERNAL_COMMAND_RETURN_CODE
                OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if ((EXTERNAL_COMMAND_RETURN_CODE EQUAL 0) AND (EXTERNAL_COMMAND_OUTPUT VERSION_GREATER_EQUAL "15.0"))
            # * `-ld_classic`: Requires XCode 15.0+. Prevents the following
            #                  (harmless) warning on macOS when using gcc:
            #                       ld: warning: ignoring duplicate libraries: '-lgcc'
            #                  Details at https://stackoverflow.com/questions/77164140/
            add_link_options(-Wl,-pie,-ld_classic)
        else ()
            add_link_options(-Wl,-pie)
        endif ()
    elseif (WIN32)
        add_link_options(-Wl)
    else ()
        add_link_options(-Wl,-pie)
    endif ()
elseif (CMAKE_C_COMPILER_ID MATCHES "MSVC")
    if (ENABLE_ASAN)
        # /INCREMENTAL is not supported when using ASan
        # https://learn.microsoft.com/en-us/cpp/build/reference/incremental-link-incrementally
        add_link_options(/INCREMENTAL:NO)
    endif ()
endif ()

# Enable color output of unity tests
add_compile_definitions(UNITY_OUTPUT_COLOR)
