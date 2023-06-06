#!/usr/bin/env bash
# shellcheck disable=SC2155

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

# Import environment variables from .env
set -o allexport && source .env && set +o allexport

declare -r SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

declare -r HELLOC_VERSION="$("${SCRIPT_DIR}/version.sh")"
if [ $? -eq 0 ]; then
    declare -r DOCKER_IMAGE_TAG="${HELLOC_VERSION}"
else
    exit 1
fi

echo "Building image '$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'..."
# TIP: Add `--progress=plain` to see the full docker output when you are
# troubleshooting the build setup of your image.
declare -r DOCKER_OPTIONS=""
# Use BuildKit, i.e. `buildx build` instead of just `build`
# https://docs.docker.com/build/
docker buildx build $DOCKER_OPTIONS -t "$DOCKER_IMAGE_NAME":"$DOCKER_IMAGE_TAG" .
