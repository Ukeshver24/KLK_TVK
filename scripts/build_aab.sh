#!/bin/bash
set -e

# Find Java from Android Studio if not set
if [ -z "$JAVA_HOME" ]; then
  if [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  fi
fi

# Ensure flutter is in PATH
if ! command -v flutter &> /dev/null; then
  if [ -d "$HOME/Development/flutter/bin" ]; then
    export PATH="$HOME/Development/flutter/bin:$JAVA_HOME/bin:$PATH"
  fi
fi

echo "🚀 Building Release AAB (arm64-v8a + armeabi-v7a)..."
flutter build appbundle --release \
  --target-platform android-arm,android-arm64 \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
  echo "📦 Stripping BUNDLE-METADATA debug symbols to reduce AAB file size..."
  zip -d "$AAB_PATH" "BUNDLE-METADATA/com.android.tools.build.debugsymbols/*" 2>/dev/null || true
  echo "✅ AAB Build Complete!"
  ls -lh "$AAB_PATH"
fi
