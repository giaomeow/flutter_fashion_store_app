#!/bin/bash

# Script để setup Android SDK environment variables trên macOS

echo "🔧 Setting up Android SDK environment variables..."

# Android SDK path mặc định trên macOS
ANDROID_SDK_PATH="$HOME/Library/Android/sdk"

# Kiểm tra xem Android SDK có tồn tại không
if [ ! -d "$ANDROID_SDK_PATH" ]; then
    echo "❌ Android SDK not found at: $ANDROID_SDK_PATH"
    echo ""
    echo "📥 Please install Android Studio first:"
    echo "   1. Download from: https://developer.android.com/studio"
    echo "   2. Install and open Android Studio"
    echo "   3. Go to Preferences → Android SDK"
    echo "   4. Install Android SDK and tools"
    echo ""
    echo "Or if SDK is in a different location, edit this script and update ANDROID_SDK_PATH"
    exit 1
fi

echo "✅ Android SDK found at: $ANDROID_SDK_PATH"
echo ""

# Xác định shell config file
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    echo "📝 Using .zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
    echo "📝 Using .bash_profile"
else
    SHELL_CONFIG="$HOME/.zshrc"
    touch "$SHELL_CONFIG"
    echo "📝 Created .zshrc"
fi

# Kiểm tra xem đã có ANDROID_HOME chưa
if grep -q "ANDROID_HOME" "$SHELL_CONFIG"; then
    echo "⚠️  ANDROID_HOME already exists in $SHELL_CONFIG"
    echo "   Please check manually or remove old entries"
else
    # Thêm vào shell config
    echo "" >> "$SHELL_CONFIG"
    echo "# Android SDK Configuration" >> "$SHELL_CONFIG"
    echo "export ANDROID_HOME=\"$ANDROID_SDK_PATH\"" >> "$SHELL_CONFIG"
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools\"" >> "$SHELL_CONFIG"
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/tools\"" >> "$SHELL_CONFIG"
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/tools/bin\"" >> "$SHELL_CONFIG"
    
    echo "✅ Added Android SDK configuration to $SHELL_CONFIG"
fi

# Set cho session hiện tại
export ANDROID_HOME="$ANDROID_SDK_PATH"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"

echo ""
echo "✅ Android SDK environment variables set!"
echo ""
echo "📋 Current configuration:"
echo "   ANDROID_HOME=$ANDROID_HOME"
echo ""
echo "⚠️  Please run the following to apply in current terminal:"
echo "   source $SHELL_CONFIG"
echo ""
echo "Or open a new terminal window."
echo ""
echo "🔍 Next steps:"
echo "   1. Run: flutter doctor"
echo "   2. Run: flutter doctor --android-licenses (accept all)"
echo "   3. Run: flutter build apk --release"

