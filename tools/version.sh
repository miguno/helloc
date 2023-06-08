#!/usr/bin/env bash
# shellcheck disable=SC2155

# Prints the version of this project to STDOUT.

declare -r SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
declare -r PROJECT_DIR=$(readlink -f "$SCRIPT_DIR/..")

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

# Import environment variables from .env
set -o allexport && source "$PROJECT_DIR/.env" && set +o allexport

CMAKELISTS="${PROJECT_DIR}/CMakeLists.txt"
declare -r HELLOC_MAJOR_VERSION=$(grep -m 1 HELLOC_MAJOR_VERSION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
declare -r HELLOC_MINOR_VERSION=$(grep -m 1 HELLOC_MINOR_VERSION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
declare -r HELLOC_PATCH_VERSION=$(grep -m 1 HELLOC_PATCH_VERSION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
declare -r HELLOC_DEV_ITERATION=$(grep -m 1 HELLOC_DEV_ITERATION ${CMAKELISTS} | sed -rn 's/^(.*) (.*)\)/\2/p')
# IMPORTANT: Versioning logic here must match the logic in CMakeLists.txt!
declare -r HELLOC_VERSION="${HELLOC_MAJOR_VERSION}.${HELLOC_MINOR_VERSION}.${HELLOC_PATCH_VERSION}-${HELLOC_DEV_ITERATION}"
echo "${HELLOC_VERSION}"
