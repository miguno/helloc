# Load environment variables from `.env` file.
set dotenv-load

project_version := `./tools/version.sh`
project_dir := justfile_directory()
build_dir := project_dir + "/build"
build_debug_dir := project_dir + "/cmake-build-debug"
coverage_build_dir := project_dir + "/build-for-coverage"
coverage_report_dir := project_dir + "/coverage-report"
src_dir := build_dir + "/src"
examples_dir := build_dir + "/examples"
test_dir := build_dir + "/test"
docs_dir := project_dir + "/generated-docs"

# `os()` documented at https://just.systems/man/en/chapter_30.html
gcc := if os() == "macos" { env_var('COVERAGE_GCC_MACOS') } else { env_var('COVERAGE_GCC_LINUX') }
gcov := if os() == "macos" { env_var('COVERAGE_GCOV_MACOS') } else { env_var('COVERAGE_GCOV_LINUX') }

# You should set the environment variable CMAKE_BUILD_PARALLEL_LEVEL according
# to the number of available CPU cores on your machine.
# https://cmake.org/cmake/help/latest/envvar/CMAKE_BUILD_PARALLEL_LEVEL.html
num_build_workers := env_var_or_default("CMAKE_BUILD_PARALLEL_LEVEL", "12")

# print available just recipes
default:
    @just --list --justfile {{justfile()}}

# build for Debug
build:
    mkdir -p {{build_dir}} && \
    CMAKE_BUILD_PARALLEL_LEVEL={{num_build_workers}} \
    cmake --build {{build_dir}} --config Debug --target all

# print clang details, including environment and architecture
clang-details:
    clang -E -x c - -v < /dev/null

# run a clangd check on a single file
clangd-check filename:
    clangd --check={{filename}} --log=verbose 2>&1

# clean
clean:
    rm -rf {{build_dir}}
    rm -rf {{build_debug_dir}}
    rm -rf {{coverage_build_dir}}
    rm -rf {{coverage_report_dir}}
    rm -rf {{docs_dir}}

# configure a build
configure:
    # https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
    # https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html
    #
    # The `CC` environment variable is pre-defined in the `.env` file, but you
    # can override it in the shell environment; e.g., `CC=gcc just configure`.
    # Set compiler with CC to 'clang' to ensure that macOS does not pick up
    # the default XCode clang version, which has a `cc` symlink or hardcopy,
    # which cmake prefers.
    CC="$CC" cmake -B {{build_dir}} -S . -G "Ninja Multi-Config"

[private]
configure-valgrind:
    VALGRIND=1 CC="$CC" cmake -B {{build_dir}} -S . -G "Ninja Multi-Config"

# generate code coverage report
coverage:
    @echo "Generating code coverage report ..."
    @echo "gcc is {{gcc}}"
    CC={{gcc}} GCOV={{gcov}} ./tools/coverage.sh

# test with ctest (requires adding tests via `add_test()` in CMakeLists.txt)
ctest *args: build
    @echo "Running tests via ctest ..."
    (cd {{build_dir}} && ninja test {{args}})

# clean, compile, build for Debug
do: clean configure build

# create a docker image (requires Docker)
docker-image-create:
    @echo "Creating a docker image ..."
    ./tools/docker/create_image.sh

# size of the docker image (requires Docker)
docker-image-size:
    docker images $DOCKER_IMAGE_NAME

# run the docker image (requires Docker)
docker-image-run:
    @echo "Running container from docker image ..."
    ./tools/docker/start_container.sh

# generated documentation (requires Doxygen)
docs:
    rm -rf {{docs_dir}} && \
    doxygen Doxyfile && \
    echo "---------------------------------------------------------------" && \
    echo "HTML docs are at {{docs_dir}}/html/index.html" && \
    echo "---------------------------------------------------------------"

# run a Debug binary from the examples
examples-run binary *args: build
    #!/usr/bin/env sh
    # Setting LIBGL_ALWAYS_INDIRECT to 0 fixes the following error when running
    # an application using raylib on Windows 11 in WSL 2:
    #
    #    WARNING: GLFW: Error: 65543 Description: GLX: Failed to create context: GLXBadFBConfig
    #    WARNING: GLFW: Failed to initialize Window
    #    FATAL: Failed to initialize Graphic Device
    #
    # Excursus:
    # 1. Indirect rendering means that the GLX protocol will be used to transmit
    #    OpenGL commands and the X server will do the real drawing.
    # 2. Direct rendering means that application can access hardware directly
    #    without communication with X first via mesa.  The direct rendering is
    #    faster because it does not require a change of context into the X server
    #    process.
    #
    # This workaround was discovered when running `glxinfo -B` while the
    # DISPLAY env variable was set in WSL to point at a VcXsrv Windows X Server,
    # as the command output showed that LIBGL_ALWAYS_INDIRECT was enabled.
    #
    # With this workaround, apps using raylib will work whether you are using
    # the built-in WSL 2 graphics server (aka WSLg; you must set DISPLAY=":0";
    # see https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps)
    # or a third-party X server such as VcXsrv, where you must set DISPLAY
    # to a different value than the default of `:0`:
    #
    #    $ export DISPLAY="$(grep nameserver /etc/resolv.conf | sed 's/nameserver //'):0"
    #
    # VcXsrv was run with `-wgl` (default) to enable the GLX extension to use
    # the native Windows WGL interface for hardware-accelerated OpenGL.
    #
    # Further references about this issue:
    # https://github.com/microsoft/WSL/issues/2855#issuecomment-613935650
    LIBGL_ALWAYS_INDIRECT=0
    # Enabling memory leak checking with Address Sanitizer (ASan) including
    # Leak Sanitizer
    ASAN_OPTIONS=detect_leaks=1
    # Suppress known false positives of ASan
    LSAN_OPTIONS=suppressions=lsan.supp
    {{examples_dir}}/Debug/{{binary}} {{args}}

# run a Release binary from the examples
examples-run-release binary *args: release
    LIBGL_ALWAYS_INDIRECT=0 \
    {{examples_dir}}/Release/{{binary}} {{args}}

# format source code (.c and .h files) with clang-format
format:
    @find examples src test \( -name "*.c" -o -name "*.h" \) -exec clang-format -i {} \;

# evaluate and print all just variables
just-vars:
    @just --evaluate

# build for Release
release:
    (cd {{project_dir}} && \
    CMAKE_BUILD_PARALLEL_LEVEL={{num_build_workers}} \
    cmake --build {{build_dir}} --config Release --target all)

# run a Debug binary
run binary *args: build
    # Enabling memory leak checking with Address Sanitizer (ASan) including
    # Leak Sanitizer
    ASAN_OPTIONS=detect_leaks=1 \
    # Suppress known false positives of ASan
    LSAN_OPTIONS=suppressions=lsan.supp \
    {{src_dir}}/Debug/{{binary}} {{args}}

# run a Release binary
run-release binary *args: release
    {{src_dir}}/Release/{{binary}} {{args}}

# print system information such as OS and architecture
system-info:
    @echo "architecture: {{arch()}}"
    @echo "os: {{os()}}"
    @echo "os family: {{os_family()}}"

# test all
test: test-unity

# test with unity
test-unity *args: build
    @echo "Running unity tests ..."
    {{test_dir}}/Debug/unity_testsuite {{args}}

# run clang-tidy (see .clang-tidy)
tidy:
    clang-tidy --version
    @find examples src test \( -name "*.c" -o -name "*.h" \) -exec clang-tidy {} -p build/ --quiet \;

# show configured checks of clang-tidy
tidy-checks:
    clang-tidy --list-checks

# show effective configuration of clang-tidy
tidy-config:
    clang-tidy --dump-config

# verify configuration of clang-tidy
tidy-verify-config:
    clang-tidy --verify-config

# test a debug binary with valgrind (requires valgrind; supported on Linux, but e.g., not on macOS)
[linux]
valgrind binary: clean configure-valgrind build
    valgrind -v --error-exitcode=1 --track-origins=yes --leak-check=full {{src_dir}}/Debug/{{binary}}

# show project version
version:
    @echo "{{project_version}}"
