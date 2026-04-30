#!/bin/bash
# Script to inject Google Maps API key into Info.plist for iOS
# Run this script before building iOS app

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}"

# Check if local.properties exists
if [ ! -f "$PROJECT_DIR/local.properties" ]; then
    echo "❌ Error: local.properties not found!"
    echo "📋 Please copy local.properties.example to local.properties and add your API keys."
    exit 1
fi

# Read the API key from local.properties
IOS_API_KEY=$(grep GOOGLE_MAPS_IOS_API_KEY "$PROJECT_DIR/local.properties" | cut -d'=' -f2)

if [ -z "$IOS_API_KEY" ]; then
    echo "⚠️  Warning: GOOGLE_MAPS_IOS_API_KEY not set in local.properties"
    echo "ℹ️  Skipping iOS API key injection. Maps may not work on iOS."
    exit 0
fi

# Path to Info.plist
PLIST_PATH="$PROJECT_DIR/ios/Runner/Info.plist"

if [ ! -f "$PLIST_PATH" ]; then
    echo "❌ Error: Info.plist not found at $PLIST_PATH"
    exit 1
fi

# Use plutil to set the key in Info.plist (macOS)
if command -v plutil &> /dev/null; then
    /usr/libexec/PlistBuddy -c "Add :com.google.ios.maps.API_KEY string" "$PLIST_PATH" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :com.google.ios.maps.API_KEY $IOS_API_KEY" "$PLIST_PATH"
    echo "✅ iOS Google Maps API key injected successfully!"
else
    echo "⚠️  plutil not available. Please add the key manually to ios/Runner/Info.plist:"
    echo "   <key>com.google.ios.maps.API_KEY</key>"
    echo "   <string>$IOS_API_KEY</string>"
fi
