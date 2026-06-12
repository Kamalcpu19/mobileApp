#!/usr/bin/env bash
set -euo pipefail

echo "Installing Flutter..."
FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
curl -sL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web --no-analytics
flutter --version

# Generate web platform files (icons, etc.) if missing
flutter create . --project-name workshop_service_advisor --platforms=web

flutter pub get

API_URL="${API_BASE_URL:-https://your-api-url.com/api}"
echo "Building web app with API_BASE_URL=$API_URL"

flutter build web --release --dart-define=API_BASE_URL="$API_URL"

echo "Web build complete."
