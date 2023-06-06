#!/usr/bin/env bash
# shellcheck disable=SC2155

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

# Import environment variables from .env
set -o allexport && source .env && set +o allexport

CMAKELISTS="CMakeLists.txt"
declare -r HELLOC_MAJOR_VERSION=$(grep -m 1 HELLOC_MAJOR_VERSION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
declare -r HELLOC_MINOR_VERSION=$(grep -m 1 HELLOC_MINOR_VERSION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
declare -r HELLOC_PATCH_VERSION=$(grep -m 1 HELLOC_PATCH_VERSION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
declare -r HELLOC_DEV_ITERATION=$(grep -m 1 HELLOC_DEV_ITERATION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
# IMPORTANT: Versioning logic must match with the logic in CMakeLists.txt!
declare -r HELLOC_VERSION="v${HELLOC_MAJOR_VERSION}.${HELLOC_MINOR_VERSION}.${HELLOC_PATCH_VERSION}-${HELLOC_DEV_ITERATION}"
DOCKER_IMAGE_TAG="${HELLOC_VERSION}"

echo "Building image '$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'..."
# TIP: Add `--progress=plain` to see the full docker output when you are
# troubleshooting the build setup of your image.
declare -r DOCKER_OPTIONS=""
# Use BuildKit, i.e. `buildx build` instead of just `build`
# https://docs.docker.com/build/
docker buildx build $DOCKER_OPTIONS -t "$DOCKER_IMAGE_NAME":"$DOCKER_IMAGE_TAG" .
