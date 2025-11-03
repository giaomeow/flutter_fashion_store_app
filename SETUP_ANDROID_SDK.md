# Hướng dẫn Cài đặt Android SDK để Build APK

## Lỗi hiện tại:

```
[!] No Android SDK found.
Try setting the ANDROID_HOME environment variable.
```

---

## Giải pháp: Cài đặt Android Studio

### Bước 1: Tải và cài đặt Android Studio

1. **Tải Android Studio:**

   - Vào: https://developer.android.com/studio
   - Download cho macOS
   - Cài đặt như ứng dụng bình thường

2. **Mở Android Studio lần đầu:**

   - Chọn "Standard" installation
   - Android Studio sẽ tự động tải và cài Android SDK

3. **Cài đặt SDK Components:**
   - Mở Android Studio
   - Vào: **Preferences/Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**
   - Tab **SDK Platforms**: Chọn Android SDK (latest version, thường là Android 14/15)
   - Tab **SDK Tools**: Đảm bảo có:
     - ✅ Android SDK Build-Tools
     - ✅ Android SDK Command-line Tools
     - ✅ Android SDK Platform-Tools
     - ✅ Android Emulator (optional)
   - Click **Apply** để cài đặt

### Bước 2: Set biến môi trường ANDROID_HOME

**Trên macOS, Android SDK thường ở:**

```
~/Library/Android/sdk
```

#### Cách 1: Set cho terminal hiện tại (Tạm thời)

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

#### Cách 2: Set vĩnh viễn (Khuyên dùng)

**Với Zsh (macOS mặc định):**

1. Mở file `.zshrc`:

```bash
nano ~/.zshrc
```

2. Thêm vào cuối file:

```bash
# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

3. Lưu file (Ctrl+O, Enter, Ctrl+X trong nano)

4. Reload shell config:

```bash
source ~/.zshrc
```

**Hoặc dùng script tự động:**

```bash
# Chạy script setup_android_sdk.sh (xem bên dưới)
```

### Bước 3: Cấu hình Flutter

Sau khi set ANDROID_HOME, chạy:

```bash
flutter doctor
```

Flutter sẽ tự động nhận diện Android SDK.

Nếu vẫn không nhận, có thể chỉ định thủ công:

```bash
flutter config --android-sdk $ANDROID_HOME
```

### Bước 4: Chấp nhận Android licenses

```bash
flutter doctor --android-licenses
```

Nhấn `y` để chấp nhận tất cả licenses.

### Bước 5: Kiểm tra lại

```bash
flutter doctor -v
```

Bạn sẽ thấy:

```
[✓] Android toolchain - develop for Android devices
```

### Bước 6: Build APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## Alternative: Chỉ cài Command Line Tools (Không cần Android Studio)

Nếu không muốn cài toàn bộ Android Studio, có thể chỉ cài command line tools:

### Bước 1: Tải Android Command Line Tools

1. Vào: https://developer.android.com/studio#command-tools
2. Tải "commandlinetools-mac" cho macOS

### Bước 2: Giải nén và di chuyển

```bash
# Tạo thư mục
mkdir -p ~/Library/Android/sdk/cmdline-tools

# Giải nén file đã tải vào
unzip commandlinetools-mac-XXXXX_latest.zip -d ~/Library/Android/sdk/cmdline-tools

# Đổi tên thành latest
mv ~/Library/Android/sdk/cmdline-tools/cmdline-tools ~/Library/Android/sdk/cmdline-tools/latest
```

### Bước 3: Set ANDROID_HOME (giống như trên)

### Bước 4: Cài đặt SDK components

```bash
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

---

## Troubleshooting

### Android SDK không ở vị trí mặc định

Nếu bạn cài Android SDK ở vị trí khác, tìm đường dẫn:

**Trên macOS:**

- Mở Android Studio
- Preferences → Android SDK
- Xem "Android SDK Location"

Sau đó set:

```bash
export ANDROID_HOME=/path/to/your/android/sdk
```

### Flutter vẫn không nhận Android SDK

```bash
# Chỉ định thủ công
flutter config --android-sdk ~/Library/Android/sdk

# Kiểm tra lại
flutter doctor
```

### Lỗi "Android SDK not found" sau khi cài

1. Đảm bảo đã set ANDROID_HOME
2. Reload terminal hoặc mở terminal mới
3. Chạy `flutter doctor` lại

---

## Quick Setup Script

Chạy script này để tự động set ANDROID_HOME:

```bash
# Xem file setup_android_sdk.sh (tạo bên dưới)
```
