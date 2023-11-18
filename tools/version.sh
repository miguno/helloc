#!/usr/bin/env bash
# shellcheck disable=SC2155

# Prints the version of this project to STDOUT.

declare -r SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
declare -r PROJECT_DIR=$(readlink -f "$SCRIPT_DIR/..")

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

# Import environment variables from .env
set -o allexport && source "$PROJECT_DIR/.env" && set +o allexport

declare -r CMAKELISTS="${PROJECT_DIR}/CMakeLists.txt"

# IMPORTANT: Versioning logic here must match the logic in CMakeLists.txt!
declare -r PROJECT_VERSION=$(grep -m1 "^project(" ${CMAKELISTS} | sed -n 's/.*VERSION "\([0-9.]*\)".*/\1/p')
echo "${PROJECT_VERSION}"
