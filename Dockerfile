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

ENV CC="clang"

# Install C toolchain
RUN apt-get update && apt-get install -y \
    clang \
    clang-tidy \
    cmake \
    lldb \
    ninja-build \
    zip \
    # purge apt data
    && rm -rf /var/lib/apt/lists/*

# Clean
RUN rm -rf build/ && mkdir -p build/
# Configure
RUN cmake -B build/ -S . -G "Ninja Multi-Config"
# Run clang-tidy
RUN find examples src test \( -name "*.c" -o -name "*.h" \) -exec clang-tidy {} -p build/ --quiet \;
# Test using a Debug build, which has additional flags for better testing
RUN CMAKE_BUILD_PARALLEL_LEVEL="$NUM_BUILD_WORKERS" \
    cmake --build build/ --config Debug --target "$TARGET"
RUN build/src/Debug/main # to trigger ASan and friends
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
FROM alpine:3.18.0
# `gcompat`: adds shared libraries needed for running our non-static binary;
#            without it, running our binary will fail with the misleading error
#            message: "exec /usr/local/bin/main: no such file or directory"
RUN apk --no-cache add ca-certificates gcompat libgcc

# Create a dedicated non-root user to run the application
ARG USER_NAME="appuser"
ARG USER_ID="1000"
ARG GROUP_NAME="$USER_NAME"
ARG GROUP_ID="1000"
# TIP: To get `useradd` and `groupadd`, install the `shadow` package via apk.
RUN addgroup --gid $GROUP_ID $GROUP_NAME && \
    adduser --disabled-password --ingroup $GROUP_NAME --uid $USER_ID $USER_NAME

WORKDIR /home/$USER_NAME
USER $USER_NAME
COPY --from=builder /app/build/src/Release/main /usr/local/bin/main
CMD ["main"]
