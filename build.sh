#!/bin/bash

# Netlify build script for Flutter web
set -e

echo "🚀 Starting Flutter web build process..."

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter..."
    
    # Download and install Flutter
    cd /tmp
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz
    tar xf flutter_linux_3.24.3-stable.tar.xz
    export PATH="$PATH:/tmp/flutter/bin"
    
    # Configure Flutter
    flutter config --no-analytics
    flutter precache --web
    
    echo "✅ Flutter installation completed"
else
    echo "✅ Flutter already available"
fi

# Return to build directory
cd $NETLIFY_BUILD_BASE

echo "🔧 Flutter doctor check..."
flutter doctor

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🏗️ Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

echo "✅ Flutter web build completed successfully!"

# List build output for debugging
echo "📂 Build output:"
ls -la build/web/