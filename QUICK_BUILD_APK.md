# Hướng dẫn Nhanh: Build APK để Test trên Điện Thoại Android

## ⚠️ Vấn đề hiện tại

Bạn đang gặp lỗi: `No Android SDK found`

Cần cài Android SDK trước khi build APK.

---

## 🚀 Giải pháp Nhanh (3 bước)

### Bước 1: Cài Android Studio

1. **Download Android Studio:**

   - Vào: https://developer.android.com/studio
   - Download cho macOS
   - Cài đặt bình thường

2. **Mở Android Studio lần đầu:**

   - Chọn "Standard" installation
   - Android Studio sẽ tự cài Android SDK

3. **Đảm bảo SDK đã cài:**
   - Mở Android Studio
   - Vào: **Preferences** (Cmd + ,) → **Appearance & Behavior** → **System Settings** → **Android SDK**
   - Tab **SDK Platforms**: Chọn Android 14 hoặc Android 15
   - Tab **SDK Tools**: Đảm bảo có:
     - ✅ Android SDK Build-Tools
     - ✅ Android SDK Platform-Tools
   - Click **Apply** và đợi cài xong

### Bước 2: Set Biến Môi Trường

Mở Terminal và chạy:

```bash
# Thêm vào ~/.zshrc (hoặc ~/.bash_profile)
echo '' >> ~/.zshrc
echo '# Android SDK' >> ~/.zshrc
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.zshrc

# Reload config
source ~/.zshrc
```

**Hoặc dùng script tự động:**

```bash
./setup_android_sdk.sh
```

### Bước 3: Cấu hình Flutter và Build

```bash
# Kiểm tra Flutter có nhận Android SDK chưa
flutter doctor

# Chấp nhận Android licenses (quan trọng!)
flutter doctor --android-licenses
# Nhấn 'y' để chấp nhận tất cả

# Nếu Flutter vẫn chưa nhận, chỉ định thủ công:
flutter config --android-sdk ~/Library/Android/sdk

# Build APK
flutter clean
flutter pub get
flutter build apk --release
```

**APK sẽ ở:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Cách Transfer APK sang Điện Thoại

### Cách 1: USB Cable (Nhanh nhất)

1. **Kết nối điện thoại với Mac qua USB**
2. **Enable USB Debugging trên điện thoại:**

   - Vào Settings → About Phone
   - Tap "Build Number" 7 lần để enable Developer Mode
   - Vào Settings → Developer Options
   - Enable "USB Debugging"

3. **Kiểm tra kết nối:**

```bash
adb devices
```

4. **Install APK trực tiếp:**

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Cách 2: Email/Cloud (Dễ nhất)

1. **Upload APK lên Google Drive:**

   - Mở Google Drive trên Mac
   - Upload file `app-release.apk`
   - Chọn "Get link" → "Anyone with the link"

2. **Trên điện thoại:**
   - Mở link Google Drive
   - Download APK
   - Cài đặt (có thể cần enable "Install from Unknown Sources")

### Cách 3: AirDrop (Chỉ Mac)

1. **Chọn file APK:**

   - Right-click `app-release.apk`
   - Chọn "Share" → "AirDrop"
   - Chọn điện thoại của bạn

2. **Trên điện thoại:**
   - Accept file
   - Cài đặt

### Cách 4: QR Code

1. **Tạo QR Code từ link Google Drive:**
   - Upload APK lên Google Drive
   - Tạo QR code từ link (dùng https://qr-code-generator.com)
2. **Trên điện thoại:**
   - Scan QR code
   - Download và cài đặt

---

## 🔧 Troubleshooting

### Lỗi: "adb: command not found"

```bash
# Kiểm tra ANDROID_HOME đã set chưa
echo $ANDROID_HOME

# Nếu rỗng, set lại:
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Lỗi: "No devices found" (adb devices)

- Đảm bảo USB Debugging đã enable
- Thử unplug và plug lại USB
- Chọn "Allow USB Debugging" trên popup điện thoại

### Lỗi: "Android licenses not accepted"

```bash
flutter doctor --android-licenses
# Nhấn 'y' cho tất cả
```

### APK không cài được trên điện thoại

- Vào Settings → Security → Enable "Install from Unknown Sources"
- Hoặc Settings → Apps → Special Access → "Install unknown apps"

---

## ⚡ Quick Commands

```bash
# Setup Android SDK (chạy 1 lần)
./setup_android_sdk.sh

# Build APK
flutter clean && flutter pub get && flutter build apk --release

# Install lên điện thoại qua USB
adb install build/app/outputs/flutter-apk/app-release.apk

# Hoặc chỉ check APK đã build chưa
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## 📋 Checklist

- [ ] Cài Android Studio
- [ ] Set ANDROID_HOME
- [ ] Run `flutter doctor` và thấy ✅ Android toolchain
- [ ] Accept Android licenses
- [ ] Build APK thành công
- [ ] Transfer APK sang điện thoại
- [ ] Cài đặt và test app

---

## 💡 Tips

1. **Build Debug APK (nhỏ hơn, nhanh hơn) nếu chỉ để test:**

```bash
flutter build apk --debug
```

2. **Build Split APK (nhỏ hơn):**

```bash
flutter build apk --split-per-abi
```

Sẽ tạo nhiều file APK theo architecture (arm64-v8a, armeabi-v7a, etc.)

3. **Test trước trên Emulator:**

```bash
# Mở Android Emulator từ Android Studio
# Sau đó:
flutter run
```
