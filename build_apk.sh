#!/bin/bash

# Script to build APK for deployment
# Usage: ./build_apk.sh

echo "🚀 Starting APK build process..."

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build APK
echo "🔨 Building APK..."
flutter build apk --release

# Check if build was successful
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ Build successful!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APK size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "💡 Next steps:"
    echo "1. Upload APK to Google Drive, Dropbox, or GitHub Releases"
    echo "2. Create a QR code for easy download"
    echo "3. Update API endpoint in lib/global_variables.dart if needed"
else
    echo "❌ Build failed!"
    exit 1
fi

