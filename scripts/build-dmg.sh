#!/usr/bin/env bash
#
# build-dmg.sh
# Production universal DMG disk image builder for NotepadMac
# Target: macOS 11.0+ (Big Sur)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/build"
APP_NAME="NotepadMac"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-1.0.0-macOS-Universal.dmg"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"
DMG_TEMP="${BUILD_DIR}/dmg_staging"

echo "=== Packaging ${APP_NAME} into Universal DMG Disk Image ==="

if [[ ! -d ${APP_BUNDLE} ]]; then
  echo ">> Application bundle not found. Building first via build-app.sh..."
  "${REPO_ROOT}/scripts/build-app.sh"
fi

echo ">> Preparing DMG staging folder..."
rm -rf "${DMG_TEMP}" "${DMG_PATH}"
mkdir -p "${DMG_TEMP}"

# Copy App to staging
cp -R "${APP_BUNDLE}" "${DMG_TEMP}/"

# Add standard Applications symlink for drag-and-drop install
ln -s /Applications "${DMG_TEMP}/Applications"

echo ">> Creating compressed UDZO disk image..."
hdiutil create \
  -volname "${APP_NAME}" \
  -srcfolder "${DMG_TEMP}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

echo ">> Cleaning staging folder..."
rm -rf "${DMG_TEMP}"

echo ">> Verifying disk image..."
hdiutil verify "${DMG_PATH}"

echo "=== Successfully built ${DMG_PATH} ==="
