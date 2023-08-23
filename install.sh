#!/usr/bin/env bash

function echo_red() {
  echo -e "\033[1;31m$1\033[0m"
}

function echo_bold() {
  echo -e "\033[1m$1\033[0m"
}

OS_NAME="$(uname)"

if [[ "${OS_NAME}" == "Darwin" ]]; then
  echo "Detected macOS"
  USER_NAME=$(scutil <<<"show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
  REMOTE_DIR="/Users/${USER_NAME}/Library/Application Support/Propellerhead Software/Remote"
elif [[ "${OS_NAME}" == MINGW* ]] || [[ "${OS_NAME}" == MSYS* ]] || [[ "${OS_NAME}" == "Windows_NT" ]]; then
  echo "Detected Windows"
  REMOTE_DIR="/c/ProgramData/Propellerhead Software/Remote"
else
  echo_red "Unsupported OS"
  exit 1
fi

if [ -z "$1" ]; then
  echo_bold "Using default configuration (custom)"
  CONFIG="custom"
else
  CONFIG="$1"
fi

# Validate the CONFIG value
VALID_CONFIGS=("custom" "original" "from-scratch")

if ! printf '%s\n' "${VALID_CONFIGS[@]}" | grep -q "^${CONFIG}$"; then
  echo_red "Error: Invalid configuration '${CONFIG}'. Valid configurations are: ${VALID_CONFIGS[*]}"
  exit 1
else
  echo_bold "Using configuration '${CONFIG}'"
fi

# Set VENDOR variable
VENDOR="Novation"

echo ""

if [ ! -d "${REMOTE_DIR}" ]; then
  echo_red "Error – no Reason!"
  echo "Reason does not seem to be installed on this system – directory not found:"
  echo "${REMOTE_DIR}"
  exit 1
else
  echo_bold "Reason is installed, using remote dir:"
  echo "${REMOTE_DIR}"
fi

echo ""

CODECS_TARGET_DIR="${REMOTE_DIR}/Codecs/Lua Codecs/${VENDOR}"

if [ ! -d "${CODECS_TARGET_DIR}" ]; then
  echo_bold "Creating codecs dir:"
  echo "${CODECS_TARGET_DIR}"
  mkdir -p "${CODECS_TARGET_DIR}"
else
  echo_bold "Using existing codecs dir:"
  echo "${CODECS_TARGET_DIR}"
fi

echo ""

MAPS_TARGET_DIR="${REMOTE_DIR}/Maps/${VENDOR}"

if [ ! -d "${MAPS_TARGET_DIR}" ]; then
  echo_bold "Creating maps dir:"
  echo "${MAPS_TARGET_DIR}"
  mkdir -p "${MAPS_TARGET_DIR}"
else
  echo_bold "Using existing maps dir:"
  echo "${MAPS_TARGET_DIR}"
fi

echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

DIST_DIR="${SCRIPT_DIR}/dist"
SRC_DIR="${SCRIPT_DIR}/src"
CODECS_SOURCE_DIR="${SRC_DIR}/${CONFIG}/codecs"
MAPS_SOURCE_DIR="${SRC_DIR}/${CONFIG}/maps"
CODECS_DIST_DIR="${DIST_DIR}/codecs"
MAPS_DIST_DIR="${DIST_DIR}/maps"

echo_bold "Setting up dist dir ${DIST_DIR}"
rm -rf "${DIST_DIR}"
mkdir "${DIST_DIR}"

echo_bold "Copying files to dist dir"

cp -vR "${CODECS_SOURCE_DIR}" "${DIST_DIR}/"
cp -vR "${MAPS_SOURCE_DIR}" "${DIST_DIR}/"

echo_bold "Bundling Lua code"

luabundler bundle "${CODECS_DIST_DIR}/SL MkIII.lua" -p "${SRC_DIR}/lib/?.lua" -o "${CODECS_DIST_DIR}/SL MkIII.lua"

echo_bold "Copying files to Reason remote dirs:"

cp -v "${CODECS_DIST_DIR}/"* "${CODECS_TARGET_DIR}/"
cp -v "${MAPS_DIST_DIR}/"* "${MAPS_TARGET_DIR}/"

