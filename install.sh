#!/bin/zsh

DEBUG_MODE=false

if [[ $1 == "debug" ]]; then
    echo "Debug mode: deploying codec with extra output port for debug messages"
    DEBUG_MODE=true
fi

set -euo pipefail

function echo_red() {
  echo "\033[31m$1\033[0m"
}

function echo_green() {
  echo "\033[32m$1\033[0m"
}

function echo_bold() {
  echo "\033[1m$1\033[0m"
}

USER_NAME=$(scutil <<<"show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
REMOTE_DIR="/Users/${USER_NAME}/Library/Application Support/Propellerhead Software/Remote"

# Set VENDOR variable
VENDOR="Novation"

if [ ! -d "${REMOTE_DIR}" ]; then
  echo_red "Error – no Reason!"
  echo "Reason does not seem to be installed on this system – directory not found:"
  echo "${REMOTE_DIR}"
  exit 1
else
  echo_bold "Reason is installed, using remote dir:"
  echo "${REMOTE_DIR}"
fi

CODECS_TARGET_DIR="${REMOTE_DIR}/Codecs/Lua Codecs/${VENDOR}"

if [ ! -d "${CODECS_TARGET_DIR}" ]; then
  echo_bold "Creating codecs dir:"
  echo "${CODECS_TARGET_DIR}"
  mkdir -p "${CODECS_TARGET_DIR}"
else
  echo_bold "Using existing codecs dir:"
  echo "${CODECS_TARGET_DIR}"
fi

MAPS_TARGET_DIR="${REMOTE_DIR}/Maps/${VENDOR}"

if [ ! -d "${MAPS_TARGET_DIR}" ]; then
  echo_bold "Creating maps dir:"
  echo "${MAPS_TARGET_DIR}"
  mkdir -p "${MAPS_TARGET_DIR}"
else
  echo_bold "Using existing maps dir:"
  echo "${MAPS_TARGET_DIR}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

DIST_DIR="${SCRIPT_DIR}/dist"
SRC_DIR="${SCRIPT_DIR}/src"
CODECS_SOURCE_DIR="${SRC_DIR}/codecs"
MAPS_SOURCE_DIR="${SRC_DIR}/maps"
CODECS_DIST_DIR="${DIST_DIR}/codecs"
MAPS_DIST_DIR="${DIST_DIR}/maps"

echo_bold "Setting up dist dir ${DIST_DIR}"
rm -rf "${DIST_DIR}"
mkdir "${DIST_DIR}"

echo_bold "Copying files to dist dir"

cp -vR "${CODECS_SOURCE_DIR}" "${DIST_DIR}/"
cp -vR "${MAPS_SOURCE_DIR}" "${DIST_DIR}/"

echo_bold "Bundling Lua code"

if ! luabundler bundle "${CODECS_DIST_DIR}/SL MkIII.lua" -p "?.lua" -o "${CODECS_DIST_DIR}/SL MkIII.lua"; then
    echo_red "Error bundling the Lua script. Did you install luabundler? Please refer to the readme file for instructions."
    exit 1
fi

if ! luabundler bundle "${CODECS_DIST_DIR}/SL MkIII Mixer.lua" -p "?.lua" -o "${CODECS_DIST_DIR}/SL MkIII Mixer.lua"; then
    echo_red "Error bundling the Lua script. Did you install luabundler? Please refer to the readme file for instructions."
    exit 1
fi

if $DEBUG_MODE; then
  echo_bold "Using debug versions of .luacodec files, replacing production versions:"
  mv -v "${CODECS_DIST_DIR}/SL MkIII.debug.luacodec" "${CODECS_DIST_DIR}/SL MkIII.luacodec"
  mv -v "${CODECS_DIST_DIR}/SL MkIII Mixer.debug.luacodec" "${CODECS_DIST_DIR}/SL MkIII Mixer.luacodec"
else
  echo_bold "Using production versions of .luacodec files, removing debug versions:"
  rm -v "${CODECS_DIST_DIR}/SL MkIII.debug.luacodec"
  rm -v "${CODECS_DIST_DIR}/SL MkIII Mixer.debug.luacodec"
fi

echo_bold "Copying files to Reason remote dirs:"

cp -v "${CODECS_DIST_DIR}/"* "${CODECS_TARGET_DIR}/"
cp -v "${MAPS_DIST_DIR}/"* "${MAPS_TARGET_DIR}/"

echo_green "Installation successful!"
