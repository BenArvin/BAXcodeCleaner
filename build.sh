#!/bin/sh

CONFIGURATION=$1

ROOT=`pwd`
PROJECT_NAME=BAXcodeCleaner
BUILD_DIR="${ROOT}/build/${CONFIGURATION}"

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

xcodebuild -project ${PROJECT_NAME}.xcodeproj -scheme "${PROJECT_NAME}" -configuration ${CONFIGURATION} CODE_SIGNING_REQUIRED=NO CONFIGURATION_BUILD_DIR="${BUILD_DIR}" clean build

rm -rf "${BUILD_DIR}/${PROJECT_NAME}.swiftmodule"
ln -s /Applications "${BUILD_DIR}/Applications"
hdiutil create "${BUILD_DIR}/${PROJECT_NAME}.dmg" -ov -volname "${PROJECT_NAME}" -fs HFS+ -srcfolder "${BUILD_DIR}"
# - hdiutil convert ./BAXcodeCleaner.dmg -format UDZO -o ./BAXcodeCleaner-install.dmg