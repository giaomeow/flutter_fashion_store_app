# Fix Lỗi: Android sdkmanager not found

## Lỗi hiện tại:

```
Android sdkmanager not found. Update to the latest Android SDK and ensure that the
cmdline-tools are installed to resolve this.
```

## Giải pháp: Cài đặt Command Line Tools

### Cách 1: Cài qua Android Studio (Dễ nhất)

1. **Mở Android Studio**
2. **Vào Preferences:**
   - Cmd + , (hoặc Android Studio → Preferences)
   - Appearance & Behavior → System Settings → Android SDK
3. **Tab "SDK Tools":**

   - ✅ Check vào "Android SDK Command-line Tools (latest)"
   - Click **Apply** và đợi cài xong

4. **Kiểm tra lại:**

```bash
flutter doctor --android-licenses
```

---

### Cách 2: Cài thủ công (Nếu cách 1 không được)

#### Bước 1: Download Command Line Tools

1. Vào: https://developer.android.com/studio#command-tools
2. Tải file: **"commandlinetools-mac"** (dòng "macOS" ở cuối trang)

#### Bước 2: Giải nén và cài đặt

```bash
# Tạo thư mục cmdline-tools
mkdir -p ~/Library/Android/sdk/cmdline-tools

# Giải nén file đã tải (thay XXXX bằng version số)
unzip ~/Downloads/commandlinetools-mac-XXXXX_latest.zip -d ~/Library/Android/sdk/cmdline-tools

# Đổi tên thư mục thành "latest" (quan trọng!)
cd ~/Library/Android/sdk/cmdline-tools
mv cmdline-tools latest
```

#### Bước 3: Kiểm tra

```bash
# Kiểm tra sdkmanager có chạy không
~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --version

# Nếu chạy được, tiếp tục accept licenses
flutter doctor --android-licenses
```

---

### Cách 3: Sửa PATH để Flutter tìm được sdkmanager

Nếu đã cài cmdline-tools nhưng vẫn lỗi, thêm vào ~/.zshrc:

```bash
# Mở file
nano ~/.zshrc

# Thêm dòng này (nếu chưa có)
export PATH=$PATH:$HOME/Library/Android/sdk/cmdline-tools/latest/bin

# Lưu (Ctrl+O, Enter, Ctrl+X)
# Reload
source ~/.zshrc
```

---

## Sau khi cài xong cmdline-tools:

```bash
# Accept licenses
flutter doctor --android-licenses

# Nhấn 'y' cho tất cả licenses
# Sau đó kiểm tra lại
flutter doctor -v
```

Bạn sẽ thấy:

```
[✓] Android toolchain - develop for Android devices
```

---

## Quick Fix Script

Chạy script này để tự động cài đặt:

```bash
# Tạo script
cat > fix_cmdline_tools.sh << 'EOF'
#!/bin/bash

echo "🔧 Checking Android SDK command-line tools..."

SDK_PATH="$HOME/Library/Android/sdk"
CMD_TOOLS="$SDK_PATH/cmdline-tools/latest"

# Kiểm tra xem đã có chưa
if [ -d "$CMD_TOOLS" ]; then
    echo "✅ Command-line tools đã được cài đặt tại: $CMD_TOOLS"
    echo "🔍 Version:"
    "$CMD_TOOLS/bin/sdkmanager" --version
else
    echo "❌ Command-line tools chưa được cài đặt"
    echo ""
    echo "📥 Vui lòng:"
    echo "   1. Mở Android Studio"
    echo "   2. Preferences → Android SDK → SDK Tools"
    echo "   3. Check 'Android SDK Command-line Tools (latest)'"
    echo "   4. Click Apply"
    echo ""
    echo "Hoặc download thủ công từ:"
    echo "   https://developer.android.com/studio#command-tools"
fi
EOF

chmod +x fix_cmdline_tools.sh
./fix_cmdline_tools.sh
```
