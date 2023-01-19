# syntax=docker/dockerfile:1

# We use a multi-stage build setup.
# (https://docs.docker.com/build/building/multi-stage/)

# Stage 1 (to create a "build" image)
# ===================================
FROM ubuntu:22.04 AS builder
WORKDIR /app
COPY . .

# Configuration settings
ARG NUM_BUILD_WORKERS="4"
ARG TARGET="all"
ARG VCPKG_ROOT="/app/vcpkg"

ENV CC="clang"
# Required on 'arm' architectures such as macOS
ENV VCPKG_FORCE_SYSTEM_BINARIES=1
# VCPKG_ROOT environment variable is required for cmake setup
ENV VCPKG_ROOT="$VCPKG_ROOT"

# Prepare OS
RUN apt-get update && apt-get upgrade -y
# Install C toolchain
RUN apt-get install -y clang clang-tidy cmake libcriterion-dev lldb ninja-build zip \
                       curl git zip # required to install vcpkg

# Install vcpkg
RUN git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT" && \
    "$VCPKG_ROOT"/bootstrap-vcpkg.sh

# Clean
RUN rm -rf build/ && mkdir -p build/
# Configure
RUN cmake -B build/ -S . -G "Ninja Multi-Config"
# Test using a Debug build, which has additional flags for better testing
RUN CMAKE_BUILD_PARALLEL_LEVEL="$NUM_BUILD_WORKERS" \
    cmake --build build/ --config Debug --target "$TARGET"
RUN build/src/Debug/main # to trigger ASan and friends
RUN build/test/Debug/criterion_testsuite --short-filename --jobs "$NUM_BUILD_WORKERS"
RUN build/test/Debug/unity_testsuite
# Build release
RUN CMAKE_BUILD_PARALLEL_LEVEL="$NUM_BUILD_WORKERS" \
    cmake --build build/ --config Release --target "$TARGET"

# Stage 2 (to create a downsized "container executable", ~9MB)
# ============================================================
#
# NOTE: We cannot easily use `FROM scratch` because it is quite involved to
# (and often ill-advised) to build a completely static binary with C.
#
# Additionally, on macOS, static binaries are not allowed.  Trying to build
# with `-static` will fail with `ld: library not found for -lcrt0.o`.
# This is not affecting this Docker setup, but worth remembering when working
# with C on macOS.
# https://developer.apple.com/library/archive/qa/qa1118/_index.html
FROM alpine:3.17.1
# `gcompat`: adds shared libraries needed for running our non-static binary;
#            without it, running our binary will fail with the misleading error
#            message: "exec /usr/local/bin/main: no such file or directory"
RUN apk --no-cache add ca-certificates gcompat
WORKDIR /root/
COPY --from=builder /app/build/src/Release/main /usr/local/bin/main
CMD ["main"]
