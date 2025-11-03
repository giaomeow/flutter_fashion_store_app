#!/bin/bash

echo "🔧 Kiểm tra Android SDK Command-line Tools..."

SDK_PATH="$HOME/Library/Android/sdk"
CMD_TOOLS="$SDK_PATH/cmdline-tools/latest"

# Kiểm tra SDK có tồn tại không
if [ ! -d "$SDK_PATH" ]; then
    echo "❌ Android SDK chưa được cài đặt tại: $SDK_PATH"
    echo ""
    echo "📥 Vui lòng cài Android Studio trước:"
    echo "   https://developer.android.com/studio"
    exit 1
fi

# Kiểm tra cmdline-tools
if [ -d "$CMD_TOOLS" ]; then
    echo "✅ Command-line tools đã được cài đặt tại: $CMD_TOOLS"
    echo ""
    echo "🔍 Kiểm tra version:"
    "$CMD_TOOLS/bin/sdkmanager" --version 2>/dev/null || echo "⚠️  Có thể cần cài đặt lại"
    echo ""
    echo "✅ Bạn có thể chạy: flutter doctor --android-licenses"
else
    echo "❌ Command-line tools CHƯA được cài đặt"
    echo ""
    echo "📥 Có 2 cách để cài:"
    echo ""
    echo "CÁCH 1: Qua Android Studio (Dễ nhất) ⭐"
    echo "   1. Mở Android Studio"
    echo "   2. Cmd + , (Preferences)"
    echo "   3. Appearance & Behavior → System Settings → Android SDK"
    echo "   4. Tab 'SDK Tools'"
    echo "   5. ✅ Check 'Android SDK Command-line Tools (latest)'"
    echo "   6. Click 'Apply' và đợi cài xong"
    echo ""
    echo "CÁCH 2: Download thủ công"
    echo "   1. Vào: https://developer.android.com/studio#command-tools"
    echo "   2. Download 'commandlinetools-mac'"
    echo "   3. Chạy các lệnh sau:"
    echo ""
    echo "   mkdir -p ~/Library/Android/sdk/cmdline-tools"
    echo "   unzip ~/Downloads/commandlinetools-mac-*_latest.zip -d ~/Library/Android/sdk/cmdline-tools"
    echo "   cd ~/Library/Android/sdk/cmdline-tools"
    echo "   mv cmdline-tools latest"
    echo ""
fi

