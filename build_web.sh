#!/bin/bash

# Script to build Web version for deployment
# Usage: ./build_web.sh

echo "🚀 Starting Web build process..."

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build web
echo "🔨 Building Web..."
flutter build web --release

# Check if build was successful
if [ -d "build/web" ]; then
    echo "✅ Build successful!"
    echo "🌐 Web files location: build/web/"
    echo ""
    echo "💡 Next steps:"
    echo "1. Deploy to Vercel: cd build/web && vercel --prod"
    echo "2. Or deploy to Netlify: drag & drop build/web folder"
    echo "3. Or deploy to Firebase Hosting: firebase deploy"
    echo "4. Update API endpoint in lib/global_variables.dart if needed"
else
    echo "❌ Build failed!"
    exit 1
fi

