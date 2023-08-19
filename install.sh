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
VALID_CONFIGS=("custom" "original")

if ! printf '%s\n' "${VALID_CONFIGS[@]}" | grep -q -P "^${CONFIG}$"; then
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

CODECS_SOURCE_DIR="${SCRIPT_DIR}/src/${CONFIG}/codecs"
MAPS_SOURCE_DIR="${SCRIPT_DIR}/src/${CONFIG}/maps"

echo_bold "Copying files:"

cp -v "${CODECS_SOURCE_DIR}/"* "${CODECS_TARGET_DIR}/"
cp -v "${MAPS_SOURCE_DIR}/"* "${MAPS_TARGET_DIR}/"

