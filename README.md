# helloc [![CI workflow status](https://github.com/miguno/helloc/actions/workflows/ci.yml/badge.svg)](https://github.com/miguno/helloc/actions/workflows/ci.yml)

My template project writing in the C programming language in 2023.

As a C beginner, it took me longer than expected to come up with a base project,
after having enjoyed the modern toolchains of languages like Golang and Rust.
Maybe you find this useful, too. Enjoy!

## Features

* Works on macOS, Debian/Ubuntu, and Windows 11 with Ubuntu in WSL.
* Works with [neovim](https://neovim.io/) ![](https://img.shields.io/github/stars/neovim/neovim) and
  [Visual Studio Code](https://code.visualstudio.com/) ![](https://img.shields.io/github/stars/microsoft/vscode)
  as code editors, and likely with others, too.
* This project implements a [main.c](src/main.c) application that uses our toy
  library [miguno.h](src/miguno.h), implemented in [miguno.c](src/miguno.c).
* C language standard is C17, see `CMAKE_C_STANDARD` in
  [CMakeLists.txt](CMakeLists.txt).
* Uses [clang](https://clang.llvm.org/) ![](https://img.shields.io/github/stars/llvm/llvm-project)
  as the compiler, along with tools such as clang-format and clang-tidy.
* Build and dependency management:
  [cmake](https://cmake.org/cmake/help/latest/) with
  [vcpkg](https://github.com/microsoft/vcpkg) ![](https://img.shields.io/github/stars/microsoft/vcpkg) and
  [ninja](https://github.com/ninja-build/ninja) ![](https://img.shields.io/github/stars/ninja-build/ninja),
  using a [multi-config generator](https://cmake.org/cmake/help/latest/variable/CMAKE_CONFIGURATION_TYPES.html)
  setup [for ninja](https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html).
* Our toy library is tested with the multiple C test frameworks, so we can
  evaluate which of them is preferable to us:
    * [criterion_tests.c](test/criterion_tests.c) via
      [Criterion](https://github.com/Snaipe/Criterion) ![](https://img.shields.io/github/stars/Snaipe/Criterion)
    * [unity_tests.c](test/unity_tests.c) via
      [Unity](https://github.com/ThrowTheSwitch/Unity) ![](https://img.shields.io/github/stars/ThrowTheSwitch/Unity)
* Uses [just](https://github.com/casey/just) ![](https://img.shields.io/github/stars/casey/just)
  for running common commands conveniently, see [justfile](justfile).
* Uses [stb](https://github.com/nothings/stb) ![](https://img.shields.io/github/stars/nothings/stb)
  to demonstrate importing libraries via vcpkg.
* Code style guide uses [clang-format](https://clang.llvm.org/docs/ClangFormat.html)
  and is configured in [.clang-format](.clang-format).
* A [GitHub Actions](https://docs.github.com/en/actions) workflow is defined in
  [ci.yml](.github/workflows/ci.yml).

## Usage

See [justfile](justfile) if you want to run the commands manually, without
`just`.

```shell
# Show available commands, including build targets
$ just

# TL;DR
$ just clean configure build
$ just run main
$ just test
```
## Requirements

* Install the C toolchain used by this project.

    ```shell
    # macOS
    $ brew install cmake llvm criterion ninja

    # Debian/Ubuntu
    $ sudo apt-get install -y clang clang-tidy cmake libcriterion-dev lldb ninja-build
    ```

* [vcpkg](https://github.com/microsoft/vcpkg) must be installed, and an
  environment variable `VCPKG_ROOT` must exist and point to the install
  location.

    ```shell
    $ export VCPKG_ROOT="$HOME/vcpkg" # add to your shell configuration
    $ git clone https://github.com/microsoft/vcpkg $VCPKG_ROOT
    ```

* [Criterion](https://github.com/Snaipe/Criterion) must be installed
  system-wide.
    * Debian/Ubuntu: `sudo apt-get install libcriterion-dev`
    * macOS: `brew install criterion`


## Dependency management

### vcpkg

Where possible, vcpkg is used to manage dependencies.

[Baselines](https://github.com/microsoft/vcpkg/blob/master/docs/users/versioning.md#baselines)
define a global version floor for what versions will be considered. This
enables top-level manifests to keep the entire graph of dependencies up-to-date
without needing to individually specify direct `version>=` constraints.

Create the initial
[baseline](https://github.com/microsoft/vcpkg/blob/master/docs/commands/update-baseline.md),
if needed:

    $ vcpkg x-update-baseline --add-initial-baseline

Update an existing baseline:

    $ vcpkg x-update-baseline

See the [versioning
documentation](https://github.com/microsoft/vcpkg/blob/master/docs/users/versioning.md#baselines)
for more information about baselines.

### Manually-managed Dependencies

Manually managed dependencies are stored under the [external/](external/)
folder.  An example in this project is the
[Unity](https://github.com/ThrowTheSwitch/Unity) test framework.

### System-managed Dependencies

Some dependencies can also be installed via the operating system, e.g., with
apt on Debian/Ubunto or homebrew on macOS.  An example in this project is the
[Criterion](https://github.com/Snaipe/Criterion) test framework.

## Code Formatting

The code style is defined in [.clang-format](.clang-format).  See
[Clang-Format Style Options](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)
for details.

For example, if you want to indent your code with 4 spaces instead of the
default 2 spaces for the "Google" style, update [.clang-format](.clang-format)
as follows:

    # .clang-format
    BasedOnStyle: Google
    IndentWidth: 4
    TabWidth: 4

Some further interesting settings:

    AccessModifierOffset: 0
    IndentAccessModifiers: false # requires clang-format-13 or newer

## Visual Studio Code

* Configure the project: From the command palette in VS Code
  (<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>),
  run the `CMake: Configure` command.
* Build the project: From the command palette in VS Code
  (<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>),
  run the `CMake: Build` command, press the keyboard shortcut <kbd>F7</kbd>,
  or select the `Build` button in the status bar at the bottom.
