#!/usr/bin/env bash
set -e

# Called from the GitHub Actions workflow before the flutter build step.
# Generates flutter_launcher_icons.yaml and flutter_native_splash.yaml from
# environment variables, then runs the generators.
#
# Required environment variables (set as GitHub Actions secrets/inputs):
#   TENANT_ID      — tenant slug, e.g. "demo"
#   APP_NAME       — display name, e.g. "Business Assistant"
#   PACKAGE_NAME   — Android applicationId, e.g. "com.businessassistant.demo"
#
# Assets must already exist in the repo at:
#   assets/tenants/$TENANT_ID/logo.png
#   assets/tenants/$TENANT_ID/app_icon.png
#   assets/tenants/$TENANT_ID/splash_logo.png
#
# Unlike the template (which downloaded assets from Firebase Storage),
# this script reads assets from the repository itself — no cloud storage needed.

TENANT_ID="${TENANT_ID:?TENANT_ID environment variable is required}"
APP_NAME="${APP_NAME:?APP_NAME environment variable is required}"
PACKAGE_NAME="${PACKAGE_NAME:?PACKAGE_NAME environment variable is required}"

# Resolve the repo root — the script can be called from any working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Applying branding for tenant: $TENANT_ID ==="
echo "  App Name: $APP_NAME"
echo "  Package:  $PACKAGE_NAME"
echo "  Build dir: $BUILD_DIR"

# ── Validate that required assets exist ──────────────────────────────────────

ASSET_DIR="$BUILD_DIR/assets/tenants/$TENANT_ID"

if [ ! -f "$ASSET_DIR/logo.png" ]; then
  echo "  [ERROR] Missing: $ASSET_DIR/logo.png"
  exit 1
fi

if [ ! -f "$ASSET_DIR/app_icon.png" ]; then
  echo "  [ERROR] Missing: $ASSET_DIR/app_icon.png"
  exit 1
fi

if [ ! -f "$ASSET_DIR/splash_logo.png" ]; then
  echo "  [ERROR] Missing: $ASSET_DIR/splash_logo.png"
  exit 1
fi

echo "  [OK] All required assets found"

# ── Ensure pubspec.yaml lists the tenant asset directory ─────────────────────

PUBSPEC="$BUILD_DIR/pubspec.yaml"
ASSET_ENTRY="    - assets/tenants/$TENANT_ID/"
if ! grep -qF "assets/tenants/$TENANT_ID/" "$PUBSPEC"; then
  # Insert the entry below the existing assets/tenants/ line
  sed -i'' -e "/assets\/tenants\//a\\
$ASSET_ENTRY" "$PUBSPEC"
  echo "  [OK] Added $TENANT_ID asset directory to pubspec.yaml"
else
  echo "  [OK] $TENANT_ID asset directory already in pubspec.yaml"
fi

# ── Android: namespace is fixed in build.gradle, applicationId comes from env ─

echo "  [OK] Android applicationId will be set to $PACKAGE_NAME via PACKAGE_NAME env var"

# ── Generate flutter_launcher_icons.yaml ─────────────────────────────────────

cat > "$BUILD_DIR/flutter_launcher_icons.yaml" << ICON_EOF
flutter_launcher_icons:
  android: true
  ios: false
  image_path: assets/tenants/$TENANT_ID/app_icon.png
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: assets/tenants/$TENANT_ID/app_icon.png
ICON_EOF

echo "  [OK] flutter_launcher_icons.yaml generated"

cd "$BUILD_DIR"
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
echo "  [OK] Launcher icons generated"

# ── Generate flutter_native_splash.yaml ──────────────────────────────────────

cat > "$BUILD_DIR/flutter_native_splash.yaml" << SPLASH_EOF
flutter_native_splash:
  color: "#ffffff"
  image_android: assets/tenants/$TENANT_ID/splash_logo.png
  android: true
  ios: false
  android_12:
    image: assets/tenants/$TENANT_ID/splash_logo.png
    color: "#ffffff"
SPLASH_EOF

echo "  [OK] flutter_native_splash.yaml generated"

dart run flutter_native_splash:create --path=flutter_native_splash.yaml
echo "  [OK] Native splash screen generated"

echo "=== Branding applied successfully for $TENANT_ID ==="
