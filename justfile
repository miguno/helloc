timestamp := `date +%s`
semver := "0.1.0-alpha"
commit := `git show -s --format=%h`
# Must match version setting in vcpkg.json
version := semver + "+" + commit

project_dir := justfile_directory()
build_dir := project_dir + "/build"
src_dir := build_dir + "/src"
test_dir := build_dir + "/test"
default_binary := "main"
# You should set the environment variable CMAKE_BUILD_PARALLEL_LEVEL according
# to the number of available CPU cores on your machine.
# https://cmake.org/cmake/help/latest/envvar/CMAKE_BUILD_PARALLEL_LEVEL.html
num_build_workers := env_var_or_default("CMAKE_BUILD_PARALLEL_LEVEL", "12")

# print available targets
default:
    @just --list --justfile {{justfile()}}

# clean
clean:
    rm -rf {{build_dir}}

# configure a build
configure:
    # https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
    # https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html
    #
    # Set compiler with CC to 'clang' to ensure that macOS does not pick up
    # the default XCode clang version, which has a `cc` symlink or hardcopy,
    # which cmake prefers.
    (cd {{project_dir}} && \
    CC=clang \
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
run binary=default_binary: build
    {{src_dir}}/Debug/{{binary}}

# run a Release binary
run-release binary=default_binary: release
    {{src_dir}}/Release/{{binary}}

# clang-tidy (see .clang-tidy)
tidy:
    fd '\.(c|h)$' -X clang-tidy {} -p {{build_dir}} --quiet

# test all
test: test-criterion test-unity

# test with criterion
test-criterion: build
    @echo "Running criterion tests ..."
    # `--short-filename` is needed to make the filenames of failed tests Ctrl-clickable in vscode.
    {{test_dir}}/Debug/criterion_testsuite --short-filename

# test with unity
test-unity: build
    @echo "Running unity tests ..."
    {{test_dir}}/Debug/unity_testsuite

# test with ctest (requires adding tests via `add_test()` in CMakeLists.txt)
ctest: build
    @echo "Running tests via ctest ..."
    (cd build && ninja test)
