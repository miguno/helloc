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
    rm -rf .cache/
    rm -rf {{build_dir}}
    rm -rf {{build_debug_dir}}
    rm -rf {{coverage_build_dir}}
    rm -rf {{coverage_report_dir}}
    rm -rf {{docs_dir}}

# configure a build
configure *args:
    # https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
    # https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html
    #
    # The `CC` environment variable is pre-defined in the `.env` file, but you
    # can override it in the shell environment; e.g., `CC=gcc just configure`.
    # Set compiler with CC to 'clang' to ensure that macOS does not pick up
    # the default XCode clang version, which has a `cc` symlink or hardcopy,
    # which cmake prefers.
    CC="$CC" cmake -B {{build_dir}} -S . -G "Ninja Multi-Config" {{args}}

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
    #!/usr/bin/env bash
    #
    # IMPORTANT: There's some buggy behavior when both ASan and UBSan are
    # enabled together, at least when using clang.  One such example is
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=94328.  Another example
    # that we run into is that setting `verbosity=1` in ASAN_OPTIONS and then
    # setting `verbosity=2` in UBSAN_OPTIONS makes ASan use `verbosity=2`
    # instead of `verbosity=1`.  Or, the ubsan.supp file is seemingly also read
    # by ASan, even though ASan fails to parse UBSan-related suppressions when
    # you put them directly into asan.supp.
    # So there's some weird behavior going on where the environment variable
    # for one sanitizer is read and applied by another sanitizer.  Oh my!
    #
    # TIP: Add `verbosity=1` or higher numbers to get more verbose output from
    # the sanitizers.
    #
    # TIP: Add `help=1` to print out the supported settings of the respective
    # sanitizer.
    #
    # detect_leaks=1 (ASan)
    #   enable memory leak checking with Address Sanitizer (ASan) including
    #   Leak Sanitizer
    #
    # allocator_frees_and_returns_null_on_realloc_zero=0 (ASan)
    #   (To detect uses of realloc() where behavior was changed in C23.)
    #   realloc(p, 0) is equivalent to free(p) by default. If set to false,
    #   realloc(p, 0) will return a pointer to an allocated space which can not
    #   be used.
    #
    # report_error_type=1 (UBSan)
    #  Print the exact name of the rule that was violated, which allows us, for
    #  example, to suppress that rule for a specific file via an entry in
    #  `sanitizers.supp`.
    #
    export  ASAN_OPTIONS=suppressions={{project_dir}}/asan.supp:detect_leaks=1:halt_on_error=false:allocator_frees_and_returns_null_on_realloc_zero=0
    export  LSAN_OPTIONS=suppressions={{project_dir}}/lsan.supp
    export UBSAN_OPTIONS=suppressions={{project_dir}}/ubsan.supp:report_error_type=1
    # To prevent the warning:
    # "malloc: nano zone abandoned due to inability to preallocate reserved vm space"
    #
    # Background:
    # The nano_malloc routine in libmalloc tries to pre-allocate the
    # pre-calculated sized memory for pre-calculated memory addresses.
    # Because we are injecting Address Sanitizer hooks into the binary,
    # the addresses are not usable to calculate the exact size for
    # preallocation, which in turn means that the pre-determination of how much
    # space is needed at which bands in the virtual memory is not working.
    #
    # Source: https://stackoverflow.com/questions/69861144/
    export MallocNanoZone=0
    {{examples_dir}}/Debug/{{binary}} {{args}}

# run a Release binary from the examples
examples-run-release binary *args: release
    {{examples_dir}}/Release/{{binary}} {{args}}

# format source code (.c and .h files) with clang-format
format:
    @find examples src test \( -name "*.c" -o -name "*.h" \) -exec clang-format -i {} \;

# evaluate and print all just variables
just-vars:
    @just --evaluate

# build for Release
release:
    CMAKE_BUILD_PARALLEL_LEVEL={{num_build_workers}} \
    cmake --build {{build_dir}} --config Release --target all

# run a Debug binary (e.g. 'run main')
run binary *args: build
    #!/usr/bin/env bash
    #
    # IMPORTANT: There's some buggy behavior when both ASan and UBSan are
    # enabled together, at least when using clang.  One such example is
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=94328.  Another example
    # that we run into is that setting `verbosity=1` in ASAN_OPTIONS and then
    # setting `verbosity=2` in UBSAN_OPTIONS makes ASan use `verbosity=2`
    # instead of `verbosity=1`.  Or, the ubsan.supp file is seemingly also read
    # by ASan, even though ASan fails to parse UBSan-related suppressions when
    # you put them directly into asan.supp.
    # So there's some weird behavior going on where the environment variable
    # for one sanitizer is read and applied by another sanitizer.  Oh my!
    #
    # TIP: Add `verbosity=1` or higher numbers to get more verbose output from
    # the sanitizers.
    #
    # TIP: Add `help=1` to print out the supported settings of the respective
    # sanitizer.
    #
    # detect_leaks=1 (ASan)
    #   enable memory leak checking with Address Sanitizer (ASan) including
    #   Leak Sanitizer
    #
    # allocator_frees_and_returns_null_on_realloc_zero=0 (ASan)
    #   (To detect uses of realloc() where behavior was changed in C23.)
    #   realloc(p, 0) is equivalent to free(p) by default. If set to false,
    #   realloc(p, 0) will return a pointer to an allocated space which can not
    #   be used.
    #
    # report_error_type=1 (UBSan)
    #  Print the exact name of the rule that was violated, which allows us, for
    #  example, to suppress that rule for a specific file via an entry in
    #  `sanitizers.supp`.
    #
    export  ASAN_OPTIONS=suppressions={{project_dir}}/asan.supp:detect_leaks=1:halt_on_error=false:allocator_frees_and_returns_null_on_realloc_zero=0
    export  LSAN_OPTIONS=suppressions={{project_dir}}/lsan.supp
    export UBSAN_OPTIONS=suppressions={{project_dir}}/ubsan.supp:report_error_type=1
    # To prevent the warning:
    # "malloc: nano zone abandoned due to inability to preallocate reserved vm space"
    #
    # Background:
    # The nano_malloc routine in libmalloc tries to pre-allocate the
    # pre-calculated sized memory for pre-calculated memory addresses.
    # Because we are injecting Address Sanitizer hooks into the binary,
    # the addresses are not usable to calculate the exact size for
    # preallocation, which in turn means that the pre-determination of how much
    # space is needed at which bands in the virtual memory is not working.
    #
    # Source: https://stackoverflow.com/questions/69861144/
    export MallocNanoZone=0
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

# test all, including tidy
test-with-tidy: tidy test-unity

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
