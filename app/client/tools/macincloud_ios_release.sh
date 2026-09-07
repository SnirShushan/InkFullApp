#!/bin/bash
# Run this ON the MacinCloud Mac (Terminal).
# Builds a signed IPA for App Store Connect, then opens Transporter / shows the path.
#
# Prereqs (once per MacinCloud account):
#   1. Xcode installed + opened once (accept license)
#   2. Flutter in PATH (see setup section below)
#   3. Signed into Xcode with your Apple ID (Team D6F46ZX5U6)
#   4. Repo cloned (this script lives in the ink project root)
#
# Usage:
#   chmod +x tools/macincloud_ios_release.sh
#   ./tools/macincloud_ios_release.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUNDLE_ID="com.itapp2u.inks"
TEAM_ID="D6F46ZX5U6"

echo "==> Project: $ROOT"
echo "==> Bundle:  $BUNDLE_ID"
echo "==> Team:    $TEAM_ID"
echo "==> Version: $(grep '^version:' pubspec.yaml | head -1)"

# --- optional one-time Flutter install (user home, no sudo) ---
if ! command -v flutter >/dev/null 2>&1; then
  echo ""
  echo "Flutter not in PATH."
  echo "Install once (no admin needed):"
  echo "  git clone https://github.com/flutter/flutter.git -b stable \$HOME/flutter"
  echo "  echo 'export PATH=\"\$HOME/flutter/bin:\$PATH\"' >> ~/.zshrc"
  echo "  source ~/.zshrc"
  echo "  flutter doctor"
  exit 1
fi

echo "==> Flutter: $(flutter --version | head -1)"

echo "==> flutter pub get"
flutter pub get

echo "==> pod install"
cd ios
if ! command -v pod >/dev/null 2>&1; then
  echo "CocoaPods (pod) not found."
  echo "On MacinCloud Managed/PAYG: open a support ticket to install CocoaPods,"
  echo "or upgrade to a Dedicated plan (admin/sudo) and run: sudo gem install cocoapods"
  exit 1
fi
pod install
cd ..

echo "==> Building IPA (App Store signing via Xcode automatic signing)"
echo "    Open Xcode once if this fails: open ios/Runner.xcworkspace"
echo "    Then: Runner → Signing & Capabilities → Team = your Apple team"
flutter build ipa --release

IPA="$(ls -1 build/ios/ipa/*.ipa 2>/dev/null | head -1 || true)"
if [[ -z "${IPA}" ]]; then
  echo "ERROR: No .ipa found under build/ios/ipa/"
  exit 1
fi

echo ""
echo "============================================================"
echo " IPA ready: $IPA"
echo "============================================================"
echo "Upload options:"
echo "  1) Open Transporter (Applications) → Deliver this IPA"
echo "  2) Or from Terminal (Apple ID + app-specific password):"
echo "     xcrun altool --upload-app -f \"$IPA\" -t ios -u YOUR_APPLE_ID -p APP_SPECIFIC_PASSWORD"
echo ""
echo "Then in App Store Connect → your app → TestFlight / new version."
echo "============================================================"

# Try to reveal in Finder / open Transporter if present
open -R "$IPA" 2>/dev/null || true
open -a Transporter 2>/dev/null || true
