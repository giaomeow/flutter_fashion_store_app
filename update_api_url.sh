#!/bin/bash

# Script to update API URL for production deployment
# Usage: ./update_api_url.sh <production_url>

if [ -z "$1" ]; then
    echo "❌ Error: Please provide production API URL"
    echo "Usage: ./update_api_url.sh <production_url>"
    echo "Example: ./update_api_url.sh https://api.yourdomain.com"
    echo "         ./update_api_url.sh http://your-server-ip:3000"
    exit 1
fi

PRODUCTION_URL=$1
FILE_PATH="lib/global_variables.dart"

# Backup original file
cp "$FILE_PATH" "${FILE_PATH}.backup"

# Update URI
sed -i '' "s|String uri = \".*\";|String uri = \"$PRODUCTION_URL\";|g" "$FILE_PATH"

echo "✅ Updated API URL to: $PRODUCTION_URL"
echo "📁 Backup saved to: ${FILE_PATH}.backup"
echo ""
echo "⚠️  Remember to build APK after updating:"
echo "   flutter clean && flutter pub get && flutter build apk --release"

