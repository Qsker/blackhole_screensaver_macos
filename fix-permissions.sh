#!/bin/bash
# macOS 27 Screen Recording Permission Helper for BlackHoleSaver
#
# On macOS 27, the screen saver runs inside WallpaperLegacyExtension.appex
# (NOT legacyScreenSaver.appex). This script helps you grant the correct
# Screen Recording permission.
set -eu

echo "============================================="
echo " BlackHoleSaver — Screen Recording Permission"
echo " macOS 27"
echo "============================================="
echo ""

# The actual process that needs permission on macOS 27
EXTENSION_PATH="/System/Library/ExtensionKit/Extensions/WallpaperLegacyExtension.appex"
EXTENSION_BUNDLE="com.apple.wallpaper.extension.legacy"
AGENT_PATH="/System/Library/CoreServices/WallpaperAgent.app"
AGENT_BUNDLE="com.apple.wallpaper.agent"

echo "On macOS 27, the screensaver runs as:"
echo "  Process:   WallpaperLegacyExtension.appex"
echo "  Bundle ID: $EXTENSION_BUNDLE"
echo "  Parent:    WallpaperAgent.app"
echo "  Parent ID: $AGENT_BUNDLE"
echo ""
echo "Choose ONE of the following methods:"
echo ""

cat << 'METHOD1'
--- Method 1: Add WallpaperAgent.app via System Settings ---
 (WallpaperAgent is a regular .app, so the '+' picker accepts it)

 1. Open System Settings → Privacy & Security
    → Screen & System Audio Recording
 2. Click the '+' button
 3. Navigate to /System/Library/CoreServices/
 4. Select WallpaperAgent.app and click Open
 5. Toggle the switch ON
 6. Run: killall WallpaperAgent

METHOD1

echo ""
cat << 'METHOD2'
--- Method 2: Reset TCC to trigger a re-prompt ---
 (This will force macOS to ask for permission again next launch)

 1. Run the following command (you'll need your password):
    sudo tccutil reset ScreenCapture com.apple.wallpaper.extension.legacy
    sudo tccutil reset ScreenCapture com.apple.wallpaper.agent

 2. Start the screensaver from System Settings preview — you should
    see a permission prompt

METHOD2

echo ""
cat << 'METHOD3'
--- Method 3: Grant via Terminal (if SIP is disabled) ---
 (Only works if System Integrity Protection is disabled)

 1. Open Terminal
 2. Run:
    sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db \
      "INSERT OR REPLACE INTO access \
       VALUES('kTCCServiceScreenCapture',\
       'com.apple.wallpaper.extension.legacy',0,2,4,1,NULL,NULL,NULL,'UNUSED',NULL,NULL,1684790277);"

 3. Restart WallpaperAgent: killall WallpaperAgent

METHOD3

echo ""
echo "If none of the above works, BlackHoleSaver will still run —"
echo "it just shows a lensed starfield instead of your desktop."
