# Load environment variables from `.env` file.
set dotenv-load

project_dir := justfile_directory()
build_dir := project_dir + "/build"
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

# print available targets
default:
    @just --list --justfile {{justfile()}}

# evaluate and print all just variables
just-vars:
    @just --evaluate

# print system information such as OS and architecture
system-info:
  @echo "architecture: {{arch()}}"
  @echo "os: {{os()}}"
  @echo "os family: {{os_family()}}"

# print clang details, including environment and architecture
clang-details:
    clang -E -x c - -v < /dev/null

# run a clangd check on a single file
clangd-check filename:
    clangd --check={{filename}} --log=verbose 2>&1

# clean
clean:
    rm -rf {{build_dir}}

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
    (cd {{project_dir}} && \
    CC="$CC" \
    cmake -B {{build_dir}} -S . -G "Ninja Multi-Config")

# build for Debug
build:
    (cd {{project_dir}} && mkdir -p {{build_dir}} && \
    CMAKE_BUILD_PARALLEL_LEVEL={{num_build_workers}} \
    cmake --build {{build_dir}} --config Debug --target all)

# build for Release
release:
    (cd {{project_dir}} && \
    CMAKE_BUILD_PARALLEL_LEVEL={{num_build_workers}} \
    cmake --build {{build_dir}} --config Release --target all)

# clean, compile, build for Debug
do: clean configure build

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

# run a Debug binary from the examples
examples-run binary *args: build
    # Enabling memory leak checking with Address Sanitizer (ASan) including
    # Leak Sanitizer
    ASAN_OPTIONS=detect_leaks=1 \
    # Suppress known false positives of ASan
    LSAN_OPTIONS=suppressions=lsan.supp \
    {{examples_dir}}/Debug/{{binary}} {{args}}

# run a Release binary from the examples
examples-run-release binary *args: release
    {{examples_dir}}/Release/{{binary}} {{args}}

# format source code (.c and .h files) with clang-format
format:
    @find examples src test \( -name "*.c" -o -name "*.h" \) -exec clang-format -i {} \;

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

# test all
test: test-unity

# test with unity
test-unity *args: build
    @echo "Running unity tests ..."
    {{test_dir}}/Debug/unity_testsuite {{args}}

# test with ctest (requires adding tests via `add_test()` in CMakeLists.txt)
ctest *args: build
    @echo "Running tests via ctest ..."
    (cd build && ninja test {{args}})

# generate code coverage report
coverage:
    @echo "Generating code coverage report ..."
    @echo "gcc is {{gcc}}"
    (cd {{project_dir}} && \
    CC={{gcc}} GCOV={{gcov}} \
    ./coverage.sh)

# generated documentation (requires Doxygen)
docs:
    rm -rf {{docs_dir}} && \
    doxygen Doxyfile && \
    echo "---------------------------------------------------------------" && \
    echo "HTML docs are at {{docs_dir}}/html/index.html" && \
    echo "---------------------------------------------------------------"

# create a docker image (requires Docker)
docker-image-create:
    @echo "Creating a docker image ..."
    ./create_image.sh

# size of the docker image (requires Docker)
docker-image-size:
    docker images $DOCKER_IMAGE_NAME

# run the docker image (requires Docker)
docker-image-run:
    @echo "Running container from docker image ..."
    ./start_container.sh
