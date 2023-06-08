#!/usr/bin/env bash
# shellcheck disable=SC2155

declare -r SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
declare -r PROJECT_DIR=$(realpath "$SCRIPT_DIR/../..")

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

# Import environment variables from .env
set -o allexport && source "$PROJECT_DIR/.env" && set +o allexport

declare -r HELLOC_VERSION="$("${PROJECT_DIR}/tools/version.sh")"
if [ $? -eq 0 ]; then
    declare -r DOCKER_IMAGE_TAG="${HELLOC_VERSION}"
else
    exit 1
fi

echo "Starting container for image '$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'"
docker run "$DOCKER_IMAGE_NAME":"$DOCKER_IMAGE_TAG"
