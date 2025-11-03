# Hướng dẫn Deploy Flutter App

## 1. Build APK cho Android (Dễ nhất - Cho CV)

### Chuẩn bị:

```bash
# Đảm bảo đã có Flutter SDK và các dependencies
flutter doctor
flutter pub get
```

### Build APK Release:

```bash
# Build APK release (file .apk có thể cài đặt trực tiếp trên Android)
flutter build apk --release

# Hoặc build app bundle cho Play Store
flutter build appbundle --release
```

**File output:**

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

**Cách sử dụng cho CV:**

- Upload APK lên Google Drive, Dropbox, hoặc GitHub Releases
- Hoặc submit App Bundle lên Google Play Store Internal Testing
- Có thể tạo QR code để download trực tiếp

---

## 2. Build IPA cho iOS (Cần Apple Developer Account)

### Chuẩn bị:

1. Cần Apple Developer Account ($99/năm)
2. Xcode đã cài đặt trên macOS
3. Cấu hình signing trong Xcode

### Build IPA:

```bash
# Build iOS release
flutter build ipa --release
```

**Hoặc qua Xcode:**

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Chọn Product > Archive
3. Upload to App Store hoặc Export IPA

**File output:**

- IPA: `build/ios/ipa/[app-name].ipa`

**Cách sử dụng cho CV:**

- Submit lên TestFlight (miễn phí với Apple Developer account)
- Share TestFlight link
- Hoặc distribute qua Ad Hoc/Distribution (cần UDID của thiết bị)

---

## 3. Build cho Web (Miễn phí - Dễ share)

```bash
# Build web version
flutter build web --release

# File output: build/web/
# Upload folder này lên hosting (Vercel, Netlify, Firebase Hosting, etc.)
```

**Cách deploy web:**

- **Vercel**: Kéo thả folder `build/web` vào Vercel
- **Netlify**: Tương tự
- **Firebase Hosting**: `firebase deploy`
- **GitHub Pages**: Upload folder `build/web`

---

## 4. Các bước cụ thể cho Android APK

### A. Cập nhật version:

Mở `pubspec.yaml`:

```yaml
version: 1.0.0+1 # format: version+buildNumber
```

### B. Thay đổi app name và icon:

- App name: `android/app/src/main/AndroidManifest.xml` (android:label)
- Icon: `android/app/src/main/res/mipmap-*/`

### C. Build APK:

```bash
cd /Volumes/DevSpace/GiaoVan/Flutter/mac_store_app_new
flutter clean
flutter pub get
flutter build apk --release
```

### D. Kiểm tra file:

```bash
# File sẽ ở đây:
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### E. Upload để share:

- Google Drive: Upload APK, share link
- GitHub Releases: Tạo release, upload APK
- Firebase App Distribution: Free, tốt cho testing
- Direct download: Host trên server của bạn

---

## 5. Các bước cụ thể cho iOS

### A. Cấu hình signing:

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Chọn Runner > Signing & Capabilities
3. Chọn Team (Apple Developer account)
4. Xcode sẽ tự động tạo provisioning profile

### B. Cập nhật Bundle ID:

- Trong Xcode: Runner > General > Bundle Identifier
- Đổi thành unique ID: `com.yourname.macstoreapp`

### C. Build và Upload:

```bash
flutter build ipa --release
```

Hoặc qua Xcode:

1. Product > Archive
2. Distribute App
3. App Store Connect hoặc TestFlight

---

## 6. Tạo QR Code để share APK

Sau khi upload APK lên Google Drive/GitHub:

1. Lấy direct download link
2. Tạo QR code tại: https://www.qr-code-generator.com/
3. Bỏ QR code vào CV/Portfolio

---

## 7. Checklist trước khi deploy

- [ ] Thay đổi app name và package name
- [ ] Thay đổi app icon
- [ ] Cập nhật version trong `pubspec.yaml`
- [ ] Test app trên thiết bị thật
- [ ] Kiểm tra API endpoint (đảm bảo backend đang chạy hoặc dùng production API)
- [ ] Xóa debug prints/logs nếu cần
- [ ] Test trên cả Android và iOS (nếu có thể)

---

## 8. Các lưu ý cho CV

### Nên làm:

- Upload APK/IPA lên GitHub Releases
- Tạo README với screenshots
- Deploy web version để demo trực tiếp
- Ghi rõ công nghệ: Flutter, Dart, Riverpod, etc.

### Tránh:

- Để API endpoint localhost trong production build
- Commit API keys/secrets vào Git
- Upload APK quá lớn (nên tối ưu assets)

---

## 9. Commands nhanh

```bash
# Clean và build APK
flutter clean && flutter pub get && flutter build apk --release

# Build với split APK (nhỏ hơn)
flutter build apk --split-per-abi --release

# Build web
flutter build web --release

# Build iOS
flutter build ios --release
flutter build ipa --release
```

---

## 10. Deploy Web với Vercel (Nhanh nhất)

```bash
# Install Vercel CLI
npm i -g vercel

# Build web
flutter build web --release

# Deploy
cd build/web
vercel --prod
```

Sẽ có URL như: `https://your-app.vercel.app`

---

## Tips:

- APK size thường 20-50MB (có thể tối ưu xuống 15-30MB)
- Web version tốt nhất để demo nhanh
- TestFlight cho iOS là cách dễ nhất để share iOS app
- Firebase App Distribution: Free, không cần Play Store
