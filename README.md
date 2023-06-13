# helloc
[![helloc GitHub repository](https://img.shields.io/github/stars/miguno/helloc)](https://github.com/miguno/helloc)
[![CI workflow status](https://github.com/miguno/helloc/actions/workflows/ci.yml/badge.svg)](https://github.com/miguno/helloc/actions/workflows/ci.yml)
[![Docker workflow status](https://github.com/miguno/helloc/actions/workflows/docker-image.yml/badge.svg)](https://github.com/miguno/helloc/actions/workflows/docker-image.yml)
[![Code Style Guide Check workflow status](https://github.com/miguno/helloc/actions/workflows/clang-format-check.yml/badge.svg)](https://github.com/miguno/helloc/actions/workflows/clang-format-check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

My template project for writing in the C programming language in 2023.

As a C beginner, it took me longer than expected to come up with a base project,
after having enjoyed the modern toolchains of languages like Golang and Rust.
Maybe you find this useful, too. Enjoy!

## Features

* Works on macOS, Debian/Ubuntu, and Windows 11 with Ubuntu in WSL.
* Works with [neovim](https://neovim.io/) and
  [Visual Studio Code](https://code.visualstudio.com/)
  as code editors, and likely with others, too.
* This project implements a [main.c](src/main.c) application that uses our toy
  library [helloc.h](src/helloc.h), implemented in [helloc.c](src/helloc.c).
    * For starters there are also additional [examples](examples/).
* C language standard is [C17](https://en.cppreference.com/w/c/17)
  (a bug-fix version of the C11 standard), see
  `CMAKE_C_STANDARD` in [CMakeLists.txt](CMakeLists.txt).
* Uses [clang](https://clang.llvm.org/) as the pre-configured compiler (see
  [.env](.env)), along with tools such as
  [clang-format](https://clang.llvm.org/docs/ClangFormat.html) and
  [clang-tidy](https://clang.llvm.org/extra/clang-tidy/).
    * You can also use [gcc](https://gcc.gnu.org/) as the compiler.  Simply set
      the environment variable `CC` accordingly, e.g. in [.env](.env) or
      in the shell environment with `CC=gcc` or `CC=gcc-13`.
* Build and dependency management:
  [cmake](https://github.com/Kitware/CMake) with
  [ninja](https://github.com/ninja-build/ninja) ![](https://img.shields.io/github/stars/ninja-build/ninja),
  using a [multi-config generator](https://cmake.org/cmake/help/latest/variable/CMAKE_CONFIGURATION_TYPES.html)
  setup [for ninja](https://cmake.org/cmake/help/latest/generator/Ninja%20Multi-Config.html).
* Our toy library is tested with [Unity](https://github.com/ThrowTheSwitch/Unity)
  ![](https://img.shields.io/github/stars/ThrowTheSwitch/Unity), see
  [unity_tests.c](test/unity_tests.c).
* Detects memory leaks, undefined behavior, and more with tools such as
  [AddressSanitizer (ASAN)](https://clang.llvm.org/docs/AddressSanitizer.html)
  [UndefinedBehaviorSanitizer (UBSan)](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html),
  and [valgrind](https://valgrind.org/) (valgrind is only supported on Linux).
  See the [valgrind.yml](.github/workflows/valgrind.yml).
* Uses [just](https://github.com/casey/just) ![](https://img.shields.io/github/stars/casey/just)
  for running common commands conveniently, see [justfile](justfile). Think:
  a modern version of `make`, written in Rust.
* [GitHub Action workflows](https://github.com/miguno/helloc/actions)
  for CI/CD support. See [workflow definitions](.github/workflows/).
* Code style guide uses
  [clang-format](https://clang.llvm.org/docs/ClangFormat.html)
  and is configured in [.clang-format](.clang-format).  The workflow definition
  at [clang-format-check.yml](.github/workflows/clang-format-check.yml) checks
  (but does not enforce) this project's formatting conventions for source code
  automatically when code is pushed to the repository or when a pull request
  is created.
* Code linting with [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) as
  configured in [.clang-tidy](.clang-tidy).
* Uses [Doxygen](https://www.doxygen.nl/) for code documentation, see
  [Doxyfile](Doxyfile).
* Code coverage reports can be generated locally, see
  [coverage.sh](tools/coverage.sh) and the section below.
* Create and run Docker images for your C app.
  The [Docker build](Dockerfile) uses a
  [multi-stage build setup](https://docs.docker.com/build/building/multi-stage/)
  to minimize the size of the generated Docker image, which is only 9MB.

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
    $ brew install cmake llvm ninja
    $ brew install gcc lcov # optional, for generating coverage reports
    $ brew install doxygen # optional, for generating documentation

    # Debian/Ubuntu
    $ sudo apt-get install -y clang clang-tidy cmake lldb ninja-build
    $ sudo apt-get install -y build-essential lcov # optional, for generating coverage reports
    $ sudo apt-get install -y doxygen # optional, for generating documentation
    $ sudo apt-get install -y valgrind # optional, for detecting errors with valgrind
    ```

## Dependency management for source code

Dependencies are managed with cmake.  The entry point is the top-level
[CMakeLists.txt](CMakeLists.txt).

### Manually-managed Dependencies

Manually managed dependencies are stored under the [external/](external/)
folder.  An example in this project is the
[Unity](https://github.com/ThrowTheSwitch/Unity) test framework.

### System-managed Dependencies

Some dependencies can also be installed via the operating system, e.g., with
apt on Debian/Ubuntu or homebrew on macOS.  This project does not use any such
dependencies at the moment.

## Code Formatting

The code style is defined in [.clang-format](.clang-format).  See
[Clang-Format Style Options](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)
for details.

For example, if you want to indent your code with 2 spaces instead of the
default 4 spaces for the "LLVM" style, update [.clang-format](.clang-format)
as follows:

    # .clang-format
    BasedOnStyle: LLVM
    IndentWidth: 2
    TabWidth: 2

Some further interesting settings:

    AccessModifierOffset: 0
    IndentAccessModifiers: false # requires clang-format-13 or newer

## Code Coverage Reports with gcov/lcov

> Try `just coverage` first before manually running
> [coverage.sh](tools/coverage.sh).
> Most likely, it will work out-of-the-box for you.

You can generate code coverage reports with [coverage.sh](tools/coverage.sh).
Even though this project defaults to `clang` as the compiler, generating code
coverage requires the `gcc` toolchain as well as
[lcov](https://github.com/linux-test-project/lcov).

Install via:

```shell
# macOS
$ brew install gcc lcov

# Debian/Ubuntu
$ sudo apt-get install -y build-essential lcov
```

Then run the coverage script with the `CC` environment variable set to your
GCC installation:

```shell
$ CC=gcc-13 ./tools/coverage.sh
```

Example output:

```
$ ./tools/coverage.sh
...
Generating output.
Processing file src/helloc.c
Writing directory view page.
Overall coverage rate:
  lines......: 100.0% (1 of 1 line)
  functions..: 100.0% (1 of 1 function)
Reading tracefile coverage.info
            |Lines       |Functions  |Branches
Filename    |Rate     Num|Rate    Num|Rate     Num
==================================================
[/home/miguno/git/helloc/src/]
helloc.c    | 100%      1| 100%     1|    -      0
==================================================
      Total:| 100%      1| 100%     1|    -      0
```

The script also generates a report in HTML format.

## Code Documentation with Doxygen

Generate the documentation as per [Doxyfile](Doxyfile):

```shell
$ just docs
```
Then browse the documentation under `generated-docs/`.

Man pages can be displayed with:

```shell
$ man generated-docs/man/man3/helloc.h.3
```

## Docker

See [Dockerfile](Dockerfile) for details.
Requires [Docker](https://www.docker.com/) to be installed locally.

**Step 1:** Create the Docker image.

```shell
# Alternatively, run `./tools/docker/create_image.sh`.
$ just docker-image-create
```

Optionally, you can check the size of the generated Docker image:

```shell
# Alternatively, run `docker images miguno/helloc`.
$ just docker-image-size
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
miguno/helloc   latest    0e55e8877994   31 minutes ago   8.45MB
```

**Step 2:** Run a container for the image.

```shell
# Alternatively, run `./tools/docker/start_container.sh`.
$ just docker-image-run
```

## Visual Studio Code

* Configure the project: From the command palette in VS Code
  (<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>),
  run the `CMake: Configure` command.
* Build the project: From the command palette in VS Code
  (<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>),
  run the `CMake: Build` command, press the keyboard shortcut <kbd>F7</kbd>,
  or select the `Build` button in the status bar at the bottom.

## References

* [Getting the maximum of your C compiler, for
  security](https://airbus-seclab.github.io/c-compiler-security/clang_compilation.html)
  — security-related flags and options for C compilers
