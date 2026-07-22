#!/bin/bash
# Build script for BlackHoleSaver — macOS 27 compatible
# Prerequisites: Xcode (for Metal compiler), xcodegen, and an Apple ID
# signed into Xcode for automatic code signing.
set -eu
cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==> Checking prerequisites"

# 1. Xcode + metal compiler
if ! xcrun -f metal &>/dev/null; then
    echo -e "${RED}ERROR: Xcode is required (the 'metal' compiler is not in Command Line Tools).${NC}"
    echo "Install Xcode from https://developer.apple.com/download/applications/"
    echo "or from the App Store, then run:  sudo xcode-select -s /Applications/Xcode.app"
    exit 1
fi

# 2. xcodegen
if ! command -v xcodegen &>/dev/null; then
    echo "==> Installing xcodegen via Homebrew..."
    brew install xcodegen
fi

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Building BlackHoleSaver.saver"
xcodebuild -project BlackHoleSaver.xcodeproj \
           -scheme BlackHoleSaver \
           -configuration Release \
           -derivedDataPath build \
           build -quiet

echo "==> Building BlackHoleTimer.app"
xcodebuild -project BlackHoleSaver.xcodeproj \
           -scheme BlackHoleTimer \
           -configuration Release \
           -derivedDataPath build \
           build -quiet

# Find the built products
SAVER=$(find build -name "BlackHoleSaver.saver" -type d | head -1)
APP=$(find build -name "BlackHoleTimer.app" -type d | head -1)

if [ -z "$SAVER" ]; then
    echo -e "${RED}ERROR: Could not find built .saver bundle${NC}"
    exit 1
fi

echo "==> Installing to ~/Library/Screen Savers/"
# Kill any running instance first
killall WallpaperAgent 2>/dev/null || true
cp -R "$SAVER" ~/Library/Screen\ Savers/
# Re-sign after copy to prevent CODE SIGNING mtime mismatch errors
codesign --force --sign - ~/Library/Screen\ Savers/BlackHoleSaver.saver 2>/dev/null || true

echo ""
echo -e "${GREEN}Done! BlackHoleSaver installed.${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  Screen Recording Permission — macOS 27${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "On macOS 27 the screensaver runs inside WallpaperLegacyExtension,"
echo "NOT legacyScreenSaver. Grant permission to the correct process:"
echo ""
echo -e "  ${GREEN}Method A (recommended): Add WallpaperAgent.app${NC}"
echo "  1. System Settings → Privacy & Security"
echo "     → Screen & System Audio Recording"
echo "  2. Click '+' → browse to /System/Library/CoreServices/"
echo "  3. Select WallpaperAgent.app → Open → toggle ON"
echo ""
echo "  Method B: Use fix-permissions.sh for more options"
echo "  ./fix-permissions.sh"
echo ""
echo "Without permission, the saver shows a lensed starfield instead"
echo "of your desktop — it still works, just less fun."
echo ""
if [ -n "$APP" ]; then
    echo "Optional — BlackHoleTimer.app:"
    echo "  cp -R \"$APP\" /Applications/"
fi
