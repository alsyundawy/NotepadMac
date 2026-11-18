#!/usr/bin/env bash
#
# This file is part of NotepadMac.
#
# Copyright 2025-2026 Harry Dertin Sutisna Alsyundawy <alsyundawy@gmail.com>
# https://github.com/alsyundawy/NotepadMac
# ALSYUNDAWY IT SOLUTION <https://alsyundawy.com>
#
# NotepadMac is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# NotepadMac is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NotepadMac.  If not, see <https://www.gnu.org/licenses/>.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/build"
APP_NAME="NotepadMac"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "=== Building ${APP_NAME} Universal Binary (arm64 + x86_64) ==="

cd "${REPO_ROOT}"

# Ensure icons are generated
if [[ ! -f "${REPO_ROOT}/Resources/AppIcon.icns" ]]; then
  echo ">> Generating application icon..."
  python3 "${REPO_ROOT}/scripts/generate_app_icon.py"
fi

echo ">> Compiling for arm64 (macOS 11.0)..."
swift build -c release --triple arm64-apple-macosx11.0

echo ">> Compiling for x86_64 (macOS 11.0)..."
swift build -c release --triple x86_64-apple-macosx11.0

ARM64_BIN="${REPO_ROOT}/.build/arm64-apple-macosx/release/${APP_NAME}"
X86_64_BIN="${REPO_ROOT}/.build/x86_64-apple-macosx/release/${APP_NAME}"

if [[ ! -f ${ARM64_BIN} ]]; then
  echo "Error: arm64 binary missing at ${ARM64_BIN}" >&2
  exit 1
fi

if [[ ! -f ${X86_64_BIN} ]]; then
  echo "Error: x86_64 binary missing at ${X86_64_BIN}" >&2
  exit 1
fi

echo ">> Creating universal fat binary..."
rm -rf "${BUILD_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

lipo -create "${ARM64_BIN}" "${X86_64_BIN}" -output "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo ">> Copying bundle resources..."
cp "${REPO_ROOT}/Resources/Info.plist" "${CONTENTS_DIR}/Info.plist"
cp "${REPO_ROOT}/Resources/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
printf 'APPL????' >"${CONTENTS_DIR}/PkgInfo"

echo ">> Signing application bundle..."
if [[ -f "${REPO_ROOT}/Resources/NotepadMac.entitlements" ]]; then
  codesign --force --deep --sign - \
    --entitlements "${REPO_ROOT}/Resources/NotepadMac.entitlements" \
    "${APP_BUNDLE}"
else
  codesign --force --deep --sign - "${APP_BUNDLE}"
fi

echo ">> Verifying application bundle..."
codesign --verify --deep --strict "${APP_BUNDLE}"
lipo -info "${MACOS_DIR}/${APP_NAME}"

echo ">> Creating distribution archive..."
cd "${BUILD_DIR}"
zip -qry "${APP_NAME}-1.0.0-macOS-Universal.zip" "${APP_NAME}.app"

echo "=== Successfully built ${APP_BUNDLE} ==="
echo "Archive: ${BUILD_DIR}/${APP_NAME}-1.0.0-macOS-Universal.zip"
