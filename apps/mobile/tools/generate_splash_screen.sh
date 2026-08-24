#!/bin/bash

# Regenerates the app's native splash screen (Android + iOS) from one
# tenant's config in splash_screen_configuration/, for local dev-mode
# icon swapping. Same reasoning as generate_flutter_icons.sh: no native
# build flavors here, so the copied root config must be named exactly
# "flutter_native_splash.yaml" (no "-<tenant>" suffix).
#
# Usage: ./tools/generate_splash_screen.sh <tenant>   e.g. ./tools/generate_splash_screen.sh demo
set -e  # Exit on error

TENANT="$1"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$PROJECT_ROOT/splash_screen_configuration"
CONFIG_FILE="$CONFIG_DIR/flutter_native_splash-$TENANT.yaml"
ROOT_CONFIG="$PROJECT_ROOT/flutter_native_splash.yaml"

if [ -z "$TENANT" ]; then
    echo "❌ Usage: ./tools/generate_splash_screen.sh <tenant>"
    echo "Available tenants:"
    ls "$CONFIG_DIR" | sed -n 's/flutter_native_splash-\(.*\)\.yaml/  - \1/p'
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: $CONFIG_FILE not found"
    exit 1
fi

echo "🎨 Generating splash screen for tenant '$TENANT'..."
cp "$CONFIG_FILE" "$ROOT_CONFIG"

cd "$PROJECT_ROOT"
fvm dart run flutter_native_splash:create

rm -f "$ROOT_CONFIG"
echo "✅ Splash screen generated for '$TENANT'."
