#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

declare -r IMAGE_NAME="miguno/helloc"
declare -r IMAGE_TAG="latest"

echo "Starting container for image '$IMAGE_NAME:$IMAGE_TAG'"
docker run "$IMAGE_NAME":"$IMAGE_TAG"

