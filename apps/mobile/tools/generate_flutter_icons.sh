#!/bin/bash

# Regenerates the app's launcher icon (Android + iOS) from one tenant's
# config in launcher_icons_configuration/, for local dev-mode icon swapping.
#
# We have no native Android/iOS build flavors (tenant switching is done via
# --dart-define-from-file, not flavors — see CLAUDE.md), so the copied
# config at the root must be named exactly "flutter_launcher_icons.yaml"
# (no "-<tenant>" suffix) — that suffix makes flutter_launcher_icons treat
# the tenant as a build flavor and write into an unused src/<flavor>/ dir
# instead of the real app icon.
#
# Usage: ./tools/generate_flutter_icons.sh <tenant>   e.g. ./tools/generate_flutter_icons.sh demo
set -e  # Exit on error

TENANT="$1"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$PROJECT_ROOT/launcher_icons_configuration"
CONFIG_FILE="$CONFIG_DIR/flutter_launcher_icons-$TENANT.yaml"
ROOT_CONFIG="$PROJECT_ROOT/flutter_launcher_icons.yaml"

if [ -z "$TENANT" ]; then
    echo "❌ Usage: ./tools/generate_flutter_icons.sh <tenant>"
    echo "Available tenants:"
    ls "$CONFIG_DIR" | sed -n 's/flutter_launcher_icons-\(.*\)\.yaml/  - \1/p'
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: $CONFIG_FILE not found"
    exit 1
fi

echo "📱 Generating launcher icon for tenant '$TENANT'..."
cp "$CONFIG_FILE" "$ROOT_CONFIG"

cd "$PROJECT_ROOT"
fvm flutter pub run flutter_launcher_icons:main

rm -f "$ROOT_CONFIG"
echo "✅ Launcher icon generated for '$TENANT'."
