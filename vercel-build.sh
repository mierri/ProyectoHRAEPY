#!/bin/bash
set -e

echo "==> Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter_sdk
export PATH="$PATH:$(pwd)/flutter_sdk/bin"
flutter --version

echo "==> Creating .env from Vercel environment variables..."
cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
EOF

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web..."
flutter build web --release

echo "==> Build complete. Output in build/web"
